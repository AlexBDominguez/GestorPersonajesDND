package services;

import entities.*;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterProficiencyRepository;
import repositories.CharacterSpellRepository;
import repositories.RacialTraitProficiencyRepository;
import repositories.RacialTraitSpellRepository;

import java.util.ArrayList;
import java.util.List;

@Service
public class RacialTraitService {

    private final CharacterProficiencyRepository characterProficiencyRepository;
    private final CharacterSpellRepository characterSpellRepository;
    private final RacialTraitSpellRepository racialTraitSpellRepository;
    private final RacialTraitProficiencyRepository racialTraitProficiencyRepository;

    public RacialTraitService(CharacterProficiencyRepository characterProficiencyRepository,
                              CharacterSpellRepository characterSpellRepository,
                              RacialTraitSpellRepository racialTraitSpellRepository,
                              RacialTraitProficiencyRepository racialTraitProficiencyRepository) {
        this.characterProficiencyRepository = characterProficiencyRepository;
        this.characterSpellRepository = characterSpellRepository;
        this.racialTraitSpellRepository = racialTraitSpellRepository;
        this.racialTraitProficiencyRepository = racialTraitProficiencyRepository;
    }

    /**
     * Applies automatic (non-choice) racial trait effects to a character: spells and
     * proficiencies granted by a racial trait, both fully data-driven (racial_trait_spells /
     * racial_trait_proficiencies — see GRANT_SPELL/GRANT_PROFICIENCY in Aurora_Fixes.md #8.2).
     * No per-trait hardcoding here anymore: PHB traits that used to be a switch/case
     * (natural-illusionist, dwarven-armor-training, drow-weapon-training, drow-magic) are now
     * seeded rows, same table Aurora-sourced traits already used via AuroraRaceMapper.
     * Safe to call multiple times — all grants are idempotent. Respects each spell's required
     * level (e.g. Drow Magic: Dancing Lights at 1st, Faerie Fire at 3rd, Darkness at 5th).
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
        if (allTraits.isEmpty()) return;
        applyGrantedSpells(character, allTraits);
        applyGrantedProficiencies(character, allTraits);
    }

    private void applyGrantedSpells(PlayerCharacter character, List<RacialTrait> traits) {
        for (RacialTraitSpell entry : racialTraitSpellRepository
                .findByRacialTraitInAndRequiredLevelLessThanEqual(traits, character.getLevel())) {
            boolean alreadyHas = characterSpellRepository
                    .findByCharacterIdAndSpellId(character.getId(), entry.getSpell().getId())
                    .isPresent();
            if (!alreadyHas) {
                characterSpellRepository.save(new CharacterSpell(character, entry.getSpell(), "RACE"));
            }
        }
    }

    private void applyGrantedProficiencies(PlayerCharacter character, List<RacialTrait> traits) {
        for (RacialTraitProficiency entry : racialTraitProficiencyRepository.findByRacialTraitIn(traits)) {
            Proficiency prof = entry.getProficiency();
            if (!characterProficiencyRepository.existsByCharacterAndProficiency(character, prof)) {
                characterProficiencyRepository.save(new CharacterProficiency(character, prof, "RACE"));
            }
        }
    }
}
