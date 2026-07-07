package services;

import entities.CharacterSkill;
import entities.ClassFeature;
import entities.NumericBonus;
import entities.PlayerCharacter;
import entities.SubclassFeature;
import org.springframework.stereotype.Service;
import repositories.ClassFeatureRepository;
import repositories.NumericBonusRepository;
import repositories.PendingTaskRepository;
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
    private final PendingTaskRepository pendingTaskRepository;
    private final CharacterFormulaService formulaService;

    public NumericBonusService(ClassFeatureRepository classFeatureRepository,
                               SubclassFeatureRepository subclassFeatureRepository,
                               NumericBonusRepository numericBonusRepository,
                               PendingTaskRepository pendingTaskRepository,
                               CharacterFormulaService formulaService) {
        this.classFeatureRepository = classFeatureRepository;
        this.subclassFeatureRepository = subclassFeatureRepository;
        this.numericBonusRepository = numericBonusRepository;
        this.pendingTaskRepository = pendingTaskRepository;
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

        return pendingTaskRepository.findByCharacterAndCompleted(character, true).stream()
                .filter(t -> taskType.equals(t.getTaskType()) && t.getMetadata() != null)
                .map(t -> extractChoiceFromMetadata(t.getMetadata()))
                .filter(choice -> choice != null)
                .findFirst()
                .map(choice -> DRACONIC_ANCESTRY_DAMAGE_TYPE.get(choice.toLowerCase()))
                .orElse(null);
    }

    /** Extrae el valor "choice" del metadata JSON de una tarea. Formato: {"choice":"Black",...}
     *  Copia de PlayerCharacterService.extractChoiceFromMetadata() -- mismo formato, distinto
     *  servicio; no vale la pena una dependencia cruzada por 6 líneas. */
    private String extractChoiceFromMetadata(String metadata) {
        int idx = metadata.indexOf("\"choice\":\"");
        if (idx == -1) return null;
        int start = idx + 10;
        int end = metadata.indexOf("\"", start);
        return (end > start) ? metadata.substring(start, end) : null;
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

        return keys;
    }
}
