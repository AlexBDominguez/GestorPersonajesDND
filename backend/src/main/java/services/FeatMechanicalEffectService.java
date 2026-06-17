package services;

import entities.ActiveEffect;
import entities.CharacterActiveEffect;
import entities.CharacterSpell;
import entities.Feat;
import entities.PlayerCharacter;
import entities.Spell;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.ActiveEffectRepository;
import repositories.CharacterActiveEffectRepository;
import repositories.CharacterSpellRepository;

/**
 * Applies the generic numeric bonus a Feat may declare (effectModifierType/effectModifierValue)
 * as a permanent CharacterActiveEffect, so it's picked up by the same getArmorClass()/getCurrentSpeed()
 * style getters that already consume CharacterActiveEffects for spells/buffs. Also grants any
 * fixed spells declared on the feat (Feat.grantedSpells) — mirrors how Race.grantedSpells is
 * already applied in PlayerCharacterService.applyRaceSpells.
 *
 * This is a fallback for feats without dedicated logic in PendingTaskService.applyFeatEffects
 * (mainly Aurora-sourced feats, which aren't in that hardcoded PHB switch).
 */
@Service
public class FeatMechanicalEffectService {

    private final ActiveEffectRepository activeEffectRepository;
    private final CharacterActiveEffectRepository characterActiveEffectRepository;
    private final CharacterSpellRepository characterSpellRepository;

    public FeatMechanicalEffectService(ActiveEffectRepository activeEffectRepository,
                                       CharacterActiveEffectRepository characterActiveEffectRepository,
                                       CharacterSpellRepository characterSpellRepository) {
        this.activeEffectRepository = activeEffectRepository;
        this.characterActiveEffectRepository = characterActiveEffectRepository;
        this.characterSpellRepository = characterSpellRepository;
    }

    @Transactional
    public void applyFeatSpells(PlayerCharacter character, Feat feat) {
        if (feat.getGrantedSpells() == null) return;
        for (Spell spell : feat.getGrantedSpells()) {
            boolean alreadyHas = characterSpellRepository
                    .findByCharacterIdAndSpellId(character.getId(), spell.getId())
                    .isPresent();
            if (!alreadyHas) {
                characterSpellRepository.save(new CharacterSpell(character, spell, "FEAT"));
            }
        }
    }

    @Transactional
    public void applyFeatModifier(PlayerCharacter character, Feat feat) {
        if (feat.getEffectModifierType() == null || feat.getIndexName() == null) return;

        String effectIndexName = "feat-" + feat.getIndexName();
        ActiveEffect effect = activeEffectRepository.findByIndexName(effectIndexName)
                .orElseGet(() -> {
                    ActiveEffect e = new ActiveEffect();
                    e.setIndexName(effectIndexName);
                    e.setName(feat.getName());
                    e.setModifierTypes(java.util.List.of(feat.getEffectModifierType()));
                    e.setModifierValue(feat.getEffectModifierValue());
                    e.setDuration("Permanent");
                    e.setSource("Feat");
                    return activeEffectRepository.save(e);
                });

        boolean alreadyApplied = characterActiveEffectRepository
                .findByCharacterAndEffectAndActive(character, effect, true)
                .isPresent();
        if (!alreadyApplied) {
            characterActiveEffectRepository.save(new CharacterActiveEffect(character, effect));
        }
    }

    @Transactional
    public void removeFeatModifier(PlayerCharacter character, Feat feat) {
        if (feat.getIndexName() == null) return;
        String effectIndexName = "feat-" + feat.getIndexName();
        activeEffectRepository.findByIndexName(effectIndexName).ifPresent(effect ->
                characterActiveEffectRepository.findByCharacterAndEffectAndActive(character, effect, true)
                        .ifPresent(characterActiveEffectRepository::delete));
    }
}
