package services;

import entities.CharacterSpell;
import entities.PlayerCharacter;
import entities.Subclass;
import entities.SubclassSpell;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterSpellRepository;
import repositories.SpellRepository;
import repositories.SubclassSpellRepository;

import java.util.ArrayList;
import java.util.List;

@Service
public class SubclassSpellService {

    private final SubclassSpellRepository subclassSpellRepository;
    private final CharacterSpellRepository characterSpellRepository;
    private final SpellRepository spellRepository;

    public SubclassSpellService(SubclassSpellRepository subclassSpellRepository,
                                CharacterSpellRepository characterSpellRepository,
                                SpellRepository spellRepository) {
        this.subclassSpellRepository = subclassSpellRepository;
        this.characterSpellRepository = characterSpellRepository;
        this.spellRepository = spellRepository;
    }

    /** Grants all subclass spells from the DB table for spells unlocked at or below characterLevel. */
    @Transactional
    public void applySubclassSpells(PlayerCharacter character, Subclass subclass, int characterLevel) {
        if (subclass == null) return;
        List<SubclassSpell> entries = subclassSpellRepository
                .findBySubclassAndRequiredLevelLessThanEqual(subclass, characterLevel);
        for (SubclassSpell entry : entries) {
            boolean alreadyHas = characterSpellRepository
                    .findByCharacterIdAndSpellId(character.getId(), entry.getSpell().getId())
                    .isPresent();
            if (!alreadyHas) {
                characterSpellRepository.save(new CharacterSpell(character, entry.getSpell(), "SUBCLASS"));
            }
        }
    }

    /** Grants Circle of the Land spells for the chosen land type, up to characterLevel. */
    @Transactional
    public void applyLandCircleSpells(PlayerCharacter character, String landType, int characterLevel) {
        List<String> indexes = getLandCircleSpellsUpToLevel(landType.toLowerCase(), characterLevel);
        for (String indexApi : indexes) {
            spellRepository.findByIndexApi(indexApi).ifPresent(spell -> {
                boolean alreadyHas = characterSpellRepository
                        .findByCharacterIdAndSpellId(character.getId(), spell.getId())
                        .isPresent();
                if (!alreadyHas) {
                    characterSpellRepository.save(new CharacterSpell(character, spell, "SUBCLASS"));
                }
            });
        }
    }

    private List<String> getLandCircleSpellsUpToLevel(String landType, int characterLevel) {
        List<String> spells = new ArrayList<>();
        if (characterLevel >= 3) spells.addAll(landSpellsAtTier(landType, 3));
        if (characterLevel >= 5) spells.addAll(landSpellsAtTier(landType, 5));
        if (characterLevel >= 7) spells.addAll(landSpellsAtTier(landType, 7));
        if (characterLevel >= 9) spells.addAll(landSpellsAtTier(landType, 9));
        return spells;
    }

    private List<String> landSpellsAtTier(String landType, int tier) {
        return switch (landType) {
            case "arctic" -> switch (tier) {
                case 3 -> List.of("hold-person", "spike-growth");
                case 5 -> List.of("sleet-storm", "slow");
                case 7 -> List.of("freedom-of-movement", "ice-storm");
                case 9 -> List.of("commune-with-nature", "cone-of-cold");
                default -> List.of();
            };
            case "coast" -> switch (tier) {
                case 3 -> List.of("mirror-image", "misty-step");
                case 5 -> List.of("water-breathing", "water-walk");
                case 7 -> List.of("control-water", "freedom-of-movement");
                case 9 -> List.of("conjure-elemental", "scrying");
                default -> List.of();
            };
            case "desert" -> switch (tier) {
                case 3 -> List.of("blur", "silence");
                case 5 -> List.of("create-food-and-water", "protection-from-energy");
                case 7 -> List.of("blight", "hallucinatory-terrain");
                case 9 -> List.of("insect-plague", "wall-of-stone");
                default -> List.of();
            };
            case "forest" -> switch (tier) {
                case 3 -> List.of("barkskin", "spider-climb");
                case 5 -> List.of("call-lightning", "plant-growth");
                case 7 -> List.of("divination", "freedom-of-movement");
                case 9 -> List.of("commune-with-nature", "tree-stride");
                default -> List.of();
            };
            case "grassland" -> switch (tier) {
                case 3 -> List.of("invisibility", "pass-without-trace");
                case 5 -> List.of("daylight", "haste");
                case 7 -> List.of("divination", "freedom-of-movement");
                case 9 -> List.of("dream", "insect-plague");
                default -> List.of();
            };
            case "mountain" -> switch (tier) {
                case 3 -> List.of("spider-climb", "spike-growth");
                case 5 -> List.of("lightning-bolt", "meld-into-stone");
                case 7 -> List.of("stone-shape", "stoneskin");
                case 9 -> List.of("passwall", "wall-of-stone");
                default -> List.of();
            };
            case "swamp" -> switch (tier) {
                case 3 -> List.of("darkness", "melfs-acid-arrow");
                case 5 -> List.of("water-walk", "stinking-cloud");
                case 7 -> List.of("freedom-of-movement", "locate-creature");
                case 9 -> List.of("insect-plague", "scrying");
                default -> List.of();
            };
            case "underdark" -> switch (tier) {
                case 3 -> List.of("spider-climb", "web");
                case 5 -> List.of("gaseous-form", "stinking-cloud");
                case 7 -> List.of("greater-invisibility", "stone-shape");
                case 9 -> List.of("cloudkill", "insect-plague");
                default -> List.of();
            };
            default -> List.of();
        };
    }
}
