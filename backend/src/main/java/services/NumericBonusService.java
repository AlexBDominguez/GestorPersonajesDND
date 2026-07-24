package services;

import entities.CharacterSkill;
import entities.ClassFeature;
import entities.NumericBonus;
import entities.PlayerCharacter;
import entities.RacialTrait;
import entities.SubclassFeature;
import org.springframework.stereotype.Service;
import repositories.ClassFeatureRepository;
import repositories.NumericBonusRepository;
import repositories.SubclassFeatureRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * #8.2 NUMERIC_BONUS: sums the active NumericBonus rows for a given target field (e.g.
 * "SAVING_THROW_ALL") across every ClassFeature/SubclassFeature a character currently has
 * (level-gated) that declares a grantsBonusKey. Mirrors CharacterClassResourceService's role
 * for RESOURCE_POOL, but numeric bonuses don't need per-character persisted state (unlike a
 * resource's currentAmount) -- the value is just recomputed each time from the character's
 * current class/subclass/level/ability scores, same as item bonuses already were.
 */
@Service
public class NumericBonusService {

    private final ClassFeatureRepository classFeatureRepository;
    private final SubclassFeatureRepository subclassFeatureRepository;
    private final NumericBonusRepository numericBonusRepository;
    private final PendingChoiceService pendingChoiceService;
    private final CharacterFormulaService formulaService;

    public NumericBonusService(ClassFeatureRepository classFeatureRepository,
                               SubclassFeatureRepository subclassFeatureRepository,
                               NumericBonusRepository numericBonusRepository,
                               PendingChoiceService pendingChoiceService,
                               CharacterFormulaService formulaService) {
        this.classFeatureRepository = classFeatureRepository;
        this.subclassFeatureRepository = subclassFeatureRepository;
        this.numericBonusRepository = numericBonusRepository;
        this.pendingChoiceService = pendingChoiceService;
        this.formulaService = formulaService;
    }

    public int bonusFor(PlayerCharacter character, String targetField) {
        int total = 0;
        for (String bonusKey : activeBonusKeys(character)) {
            NumericBonus bonus = numericBonusRepository.findByBonusKey(bonusKey).orElse(null);
            if (bonus != null && targetField.equals(bonus.getTargetField())) {
                total += formulaService.evaluate(character, bonus.getFormula());
            }
        }
        return total;
    }

    // Física = Fuerza/Destreza/Constitución. La única condición hoy soportada más allá de "el
    // personaje tiene la feature": Remarkable Athlete (Fighter Champion) solo aplica a pruebas de
    // característica física en las que el personaje NO es competente (si ya es competente, el
    // bono de competencia completo ya es mejor que la mitad). No es una condición genérica
    // evaluable desde datos -- es un caso con nombre propio, igual que las tablas de nivel del
    // DSL de RESOURCE_POOL (barbarian_rage_table, etc.) no son fórmulas puramente declarativas.
    private static final Set<String> PHYSICAL_ABILITIES = Set.of("str", "dex", "con");

    public int conditionalSkillBonus(PlayerCharacter character, CharacterSkill skill) {
        if (skill.isProficient()) return 0;
        if (!PHYSICAL_ABILITIES.contains(skill.getSkill().getAbilityScore().toLowerCase())) return 0;

        int total = 0;
        for (String bonusKey : activeBonusKeys(character)) {
            NumericBonus bonus = numericBonusRepository.findByBonusKey(bonusKey).orElse(null);
            if (bonus != null && "ABILITY_CHECK_PHYSICAL_UNPROFICIENT".equals(bonus.getTargetField())) {
                total += formulaService.evaluate(character, bonus.getFormula());
            }
        }
        return total;
    }

    // Ascendencia dracónica -> tipo de daño. Mismos 10 pares que
    // frontend/lib/config/dnd_choice_options.dart's kDraconicAncestries -- duplicado a propósito
    // (igual que la lista de tipos de daño válidos ya vive por su cuenta en
    // AuroraSpellCombatParser): es la única feature que necesita esta tabla hoy, no vale la pena
    // una fuente compartida todavía para 10 pares nombre->tipo.
    private static final Map<String, String> DRACONIC_ANCESTRY_DAMAGE_TYPE = Map.ofEntries(
            Map.entry("black", "acid"), Map.entry("copper", "acid"),
            Map.entry("blue", "lightning"), Map.entry("bronze", "lightning"),
            Map.entry("brass", "fire"), Map.entry("gold", "fire"), Map.entry("red", "fire"),
            Map.entry("green", "poison"),
            Map.entry("silver", "cold"), Map.entry("white", "cold")
    );

    // Bonificador de daño de hechizo que solo aplica si damageType coincide con un tipo elegido
    // por el jugador en otra parte (p.ej. Elemental Affinity del Hechicero Dracónico: coincide
    // con el tipo de daño de su Draconic Ancestry). bonus_condition tiene el formato
    // "MATCH_DAMAGE_TYPE_FROM_CHOICE:<taskType>" -- hoy solo se resuelve DRACONIC_ANCESTRY; un
    // futuro caso similar con otra elección necesitaría su propio mapeo aquí, mismo criterio que
    // conditionalSkillBonus/las tablas de nivel con nombre propio del DSL de recursos.
    public int spellDamageBonusFor(PlayerCharacter character, String damageType) {
        if (damageType == null || damageType.isEmpty()) return 0;

        int total = 0;
        for (String bonusKey : activeBonusKeys(character)) {
            NumericBonus bonus = numericBonusRepository.findByBonusKey(bonusKey).orElse(null);
            if (bonus == null || !"SPELL_DAMAGE_MATCHING_CHOSEN_TYPE".equals(bonus.getTargetField())) continue;

            String resolvedType = resolveChosenDamageType(character, bonus.getCondition());
            if (resolvedType != null && resolvedType.equalsIgnoreCase(damageType)) {
                total += formulaService.evaluate(character, bonus.getFormula());
            }
        }
        return total;
    }

    private String resolveChosenDamageType(PlayerCharacter character, String condition) {
        if (condition == null || !condition.startsWith("MATCH_DAMAGE_TYPE_FROM_CHOICE:")) return null;
        String taskType = condition.substring("MATCH_DAMAGE_TYPE_FROM_CHOICE:".length());
        if (!"DRACONIC_ANCESTRY".equals(taskType)) return null;

        String choice = pendingChoiceService.resolvedSingleChoice(character, taskType);
        return choice == null ? null : DRACONIC_ANCESTRY_DAMAGE_TYPE.get(choice.toLowerCase());
    }

    // Bonificador de daño de hechizo que solo aplica si school coincide con una escuela fija
    // (p.ej. Empowered Evocation del Mago de Escuela de Evocación: cualquier hechizo de escuela
    // "evocation"). A diferencia de Elemental Affinity, la escuela no depende de ninguna elección
    // del jugador -- es fija por el propio feature -- así que bonus_condition es directamente el
    // nombre de la escuela en minúsculas, sin prefijo ni resolución de PendingTask.
    public int spellDamageBonusForSchool(PlayerCharacter character, String school) {
        if (school == null || school.isEmpty()) return 0;

        int total = 0;
        for (String bonusKey : activeBonusKeys(character)) {
            NumericBonus bonus = numericBonusRepository.findByBonusKey(bonusKey).orElse(null);
            if (bonus == null || !"SPELL_DAMAGE_MATCHING_SCHOOL".equals(bonus.getTargetField())) continue;
            if (school.equalsIgnoreCase(bonus.getCondition())) {
                total += formulaService.evaluate(character, bonus.getFormula());
            }
        }
        return total;
    }

    // Bonificador de daño restringido a UN hechizo concreto por nombre (hoy solo Agonizing Blast
    // -> Eldritch Blast), condicionado a que el valor exacto aparezca entre las elecciones
    // resueltas de una tarea multi-selección (p.ej. Eldritch Invocations, guardadas como
    // "Agonizing Blast,Devil's Sight,..." en el mismo formato comma-separated que Battle Master
    // Maneuvers -- ver PendingTaskService.resolveTask()).
    //
    // A diferencia de bonusFor/conditionalSkillBonus/spellDamageBonusFor*, este NO pasa por
    // activeBonusKeys(): Agonizing Blast no está atado a ninguna fila de ClassFeature/
    // SubclassFeature (Eldritch Invocations es una lista de opciones, no features individuales
    // sincronizadas), así que se busca el NumericBonus directamente por su bonusKey. Es el mismo
    // problema que Fighting Style (#8.2 "sin tocar"), resuelto aquí con este patrón alternativo
    // -- una feature elegida entre varias, no una feature que el personaje simplemente "tiene".
    private static final Map<String, String> SPECIFIC_SPELL_BONUS_KEYS = Map.of(
            "eldritch blast", "agonizing-blast"
    );

    public int spellDamageBonusForNamedSpell(PlayerCharacter character, String spellName) {
        if (spellName == null) return 0;
        String bonusKey = SPECIFIC_SPELL_BONUS_KEYS.get(spellName.toLowerCase());
        if (bonusKey == null) return 0;

        NumericBonus bonus = numericBonusRepository.findByBonusKey(bonusKey).orElse(null);
        if (bonus == null || !"SPELL_DAMAGE_IF_MULTI_CHOICE_CONTAINS".equals(bonus.getTargetField())) return 0;
        if (!pendingChoiceService.matchesMultiChoiceCondition(character, bonus.getCondition())) return 0;

        return formulaService.evaluate(character, bonus.getFormula());
    }

    // Fighting Style: igual que Agonizing Blast, ninguna fila de ClassFeature/SubclassFeature
    // (Fighting Style es una única feature con nombre "Fighting Style" que el personaje elige,
    // no una fila por estilo) -- se escanean todos los NumericBonus de un targetField y se
    // resuelve la elección directamente (misma tarea "FIGHTING_STYLE" que ya usa
    // PlayerCharacterService para exponer dto.setFightingStyle()). wearingArmor solo lo usa
    // Defense (condition con sufijo ";REQUIRES_ARMOR"); singleOneHandedMeleeWeaponEquipped solo
    // lo usa Dueling (";REQUIRES_SINGLE_ONE_HANDED_MELEE_WEAPON") -- cada flag es ignorado por
    // los estilos que no llevan su sufijo.
    public int fightingStyleBonusFor(PlayerCharacter character, String targetField, boolean wearingArmor,
                                      boolean singleOneHandedMeleeWeaponEquipped) {
        int total = 0;
        for (NumericBonus bonus : numericBonusRepository.findByTargetField(targetField)) {
            String condition = bonus.getCondition();
            boolean requiresArmor = condition != null && condition.contains(";REQUIRES_ARMOR");
            boolean requiresSingleWeapon = condition != null
                    && condition.contains(";REQUIRES_SINGLE_ONE_HANDED_MELEE_WEAPON");
            if (pendingChoiceService.matchesSingleChoiceCondition(character, condition)
                    && (!requiresArmor || wearingArmor)
                    && (!requiresSingleWeapon || singleOneHandedMeleeWeaponEquipped)) {
                total += formulaService.evaluate(character, bonus.getFormula());
            }
        }
        return total;
    }

    private List<String> activeBonusKeys(PlayerCharacter character) {
        List<String> keys = new ArrayList<>();

        if (character.getDndClass() != null) {
            for (ClassFeature f : classFeatureRepository
                    .findByDndClassAndLevelLessThanEqual(character.getDndClass(), character.getLevel())) {
                if (f.getGrantsBonusKey() != null) keys.add(f.getGrantsBonusKey());
            }
        }

        if (character.getSubclass() != null) {
            for (SubclassFeature f : subclassFeatureRepository
                    .findBySubclassAndLevelLessThanEqual(character.getSubclass(), character.getLevel())) {
                if (f.getGrantsBonusKey() != null) keys.add(f.getGrantsBonusKey());
            }
        }

        // #9: rasgos raciales homebrew con NUMERIC_BONUS -- sin gating por nivel, a diferencia
        // de ClassFeature/SubclassFeature (race_traits/subrace_traits no tienen columna de
        // nivel, ver RacialTrait.java).
        if (character.getRace() != null) {
            for (RacialTrait t : character.getRace().getTraits()) {
                if (t.getGrantsBonusKey() != null) keys.add(t.getGrantsBonusKey());
            }
        }
        if (character.getSubrace() != null) {
            for (RacialTrait t : character.getSubrace().getTraits()) {
                if (t.getGrantsBonusKey() != null) keys.add(t.getGrantsBonusKey());
            }
        }

        return keys;
    }
}
