package services;

import entities.*;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterProficiencyRepository;
import repositories.CharacterSpellRepository;
import repositories.ProficiencyRepository;
import repositories.SpellRepository;

import java.util.ArrayList;
import java.util.List;

@Service
public class RacialTraitService {

    private final CharacterProficiencyRepository characterProficiencyRepository;
    private final ProficiencyRepository proficiencyRepository;
    private final CharacterSpellRepository characterSpellRepository;
    private final SpellRepository spellRepository;

    public RacialTraitService(CharacterProficiencyRepository characterProficiencyRepository,
                              ProficiencyRepository proficiencyRepository,
                              CharacterSpellRepository characterSpellRepository,
                              SpellRepository spellRepository) {
        this.characterProficiencyRepository = characterProficiencyRepository;
        this.proficiencyRepository = proficiencyRepository;
        this.characterSpellRepository = characterSpellRepository;
        this.spellRepository = spellRepository;
    }

    /**
     * Applies automatic (non-choice) racial trait effects to a character.
     * Safe to call multiple times — all grants are idempotent.
     * Also handles level-gated racial spells (e.g. Drow Magic).
     */
    @Transactional
    public void applyAutomaticRacialTraits(PlayerCharacter character) {
        List<RacialTrait> allTraits = new ArrayList<>();
        if (character.getRace() != null && character.getRace().getTraits() != null) {
            allTraits.addAll(character.getRace().getTraits());
        }
        if (character.getSubrace() != null && character.getSubrace().getTraits() != null) {
            allTraits.addAll(character.getSubrace().getTraits());
        }
        for (RacialTrait trait : allTraits) {
            applyTrait(character, trait.getIndexName());
        }
    }

    private void applyTrait(PlayerCharacter character, String indexName) {
        if (indexName == null) return;
        switch (indexName) {
            case "natural-illusionist":
                // Forest Gnome: learns Minor Illusion automatically
                grantSpell(character, "minor-illusion");
                break;

            case "dwarven-armor-training":
                // Mountain Dwarf: proficiency with heavy armor
                grantProficiency(character, "armor-heavy");
                break;

            case "drow-weapon-training":
                // Drow: proficiency with rapier, shortsword, hand crossbow
                grantProficiency(character, "rapier");
                grantProficiency(character, "shortswords");
                grantProficiency(character, "hand-crossbow");
                break;

            case "drow-magic":
                // Drow: Dancing Lights at level 1, Faerie Fire at 3, Darkness at 5
                grantSpell(character, "dancing-lights");
                if (character.getLevel() >= 3) grantSpell(character, "faerie-fire");
                if (character.getLevel() >= 5) grantSpell(character, "darkness");
                break;

            default:
                break;
        }
    }

    private void grantSpell(PlayerCharacter character, String indexApi) {
        spellRepository.findByIndexApi(indexApi).ifPresent(spell -> {
            boolean alreadyHas = characterSpellRepository
                    .findByCharacterIdAndSpellId(character.getId(), spell.getId())
                    .isPresent();
            if (!alreadyHas) {
                characterSpellRepository.save(new CharacterSpell(character, spell, "RACE"));
            }
        });
    }

    private void grantProficiency(PlayerCharacter character, String indexName) {
        proficiencyRepository.findByIndexName(indexName).ifPresent(prof -> {
            if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, prof)) {
                characterProficiencyRepository.save(new CharacterProficiency(character, prof, "RACE"));
            }
        });
    }
}
