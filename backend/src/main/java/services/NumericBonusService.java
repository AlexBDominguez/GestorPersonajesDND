package services;

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
