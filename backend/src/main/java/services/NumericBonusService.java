package services;

import entities.CharacterSkill;
import entities.ClassFeature;
import entities.NumericBonus;
import entities.PlayerCharacter;
import entities.SubclassFeature;
import org.springframework.stereotype.Service;
import repositories.ClassFeatureRepository;
import repositories.NumericBonusRepository;
import repositories.SubclassFeatureRepository;

import java.util.ArrayList;
import java.util.List;
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
    private final CharacterFormulaService formulaService;

    public NumericBonusService(ClassFeatureRepository classFeatureRepository,
                               SubclassFeatureRepository subclassFeatureRepository,
                               NumericBonusRepository numericBonusRepository,
                               CharacterFormulaService formulaService) {
        this.classFeatureRepository = classFeatureRepository;
        this.subclassFeatureRepository = subclassFeatureRepository;
        this.numericBonusRepository = numericBonusRepository;
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
