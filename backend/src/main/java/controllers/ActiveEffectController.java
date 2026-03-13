package controllers;

import dto.CharacterActiveEffectDto;
import entities.CharacterActiveEffect;
import entities.PlayerCharacter;
import entities.ActiveEffect;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterActiveEffectRepository;
import repositories.PlayerCharacterRepository;
import repositories.ActiveEffectRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ActiveEffectController {

    private final CharacterActiveEffectRepository characterActiveEffectRepository;
    private final PlayerCharacterRepository characterRepository;
    private final ActiveEffectRepository activeEffectRepository;

    public ActiveEffectController(CharacterActiveEffectRepository characterActiveEffectRepository,
                                       PlayerCharacterRepository characterRepository,
                                       ActiveEffectRepository activeEffectRepository) {
        this.characterActiveEffectRepository = characterActiveEffectRepository;
        this.characterRepository = characterRepository;
        this.activeEffectRepository = activeEffectRepository;
    }

    public List<CharacterActiveEffectDto> getCharacterEffects(Long characterId, Boolean activeOnly) {
        List<CharacterActiveEffect> effects;
        
        if (activeOnly != null && activeOnly) {
            effects = characterActiveEffectRepository.findByCharacterIdAndActive(characterId, true);
        } else {
            effects = characterActiveEffectRepository.findByCharacterId(characterId);
        }
        
        return effects.stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CharacterActiveEffectDto applyEffect(
            Long characterId,
            Long effectId,
            Integer remainingRounds,
            Integer casterLevel,
            String notes) {
        
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        ActiveEffect effect = activeEffectRepository.findById(effectId)
                .orElseThrow(() -> new RuntimeException("ActiveEffect not found with ID: " + effectId));

        // Si el efecto requiere concentración, verificar que no haya otro efecto de concentración activo
        if (effect.isRequiresConcentration()) {
            List<CharacterActiveEffect> concentrationEffects = 
                    characterActiveEffectRepository.findByCharacterIdAndActiveAndEffect_RequiresConcentration(
                            characterId, true, true);
            
            if (!concentrationEffects.isEmpty()) {
                throw new RuntimeException("Character is already concentrating on another effect: " + 
                        concentrationEffects.get(0).getEffect().getName());
            }
        }

        // Verificar si ya tiene este efecto activo (no permitir duplicados)
        if (characterActiveEffectRepository.findByCharacterAndEffectAndActive(character, effect, true).isPresent()) {
            throw new RuntimeException("Character already has this effect active");
        }

        CharacterActiveEffect characterEffect = new CharacterActiveEffect(character, effect);
        characterEffect.setRemainingRounds(remainingRounds);
        characterEffect.setCasterLevel(casterLevel);
        characterEffect.setNotes(notes);

        characterActiveEffectRepository.save(characterEffect);

        return toDto(characterEffect);
    }

    @Transactional
    public CharacterActiveEffectDto toggleEffect(Long characterEffectId) {
        CharacterActiveEffect characterEffect = characterActiveEffectRepository.findById(characterEffectId)
                .orElseThrow(() -> new RuntimeException("CharacterActiveEffect not found with ID: " + characterEffectId));

        characterEffect.setActive(!characterEffect.isActive());
        characterActiveEffectRepository.save(characterEffect);

        return toDto(characterEffect);
    }

    @Transactional
    public CharacterActiveEffectDto updateRemainingRounds(Long characterEffectId, int remainingRounds) {
        CharacterActiveEffect characterEffect = characterActiveEffectRepository.findById(characterEffectId)
                .orElseThrow(() -> new RuntimeException("CharacterActiveEffect not found with ID: " + characterEffectId));

        characterEffect.setRemainingRounds(remainingRounds);

        // Si llega a 0 o menos, desactivar
        if (remainingRounds <= 0) {
            characterEffect.setActive(false);
        }

        characterActiveEffectRepository.save(characterEffect);

        return toDto(characterEffect);
    }

    @Transactional
    public void decrementAllEffectRounds(Long characterId) {
        List<CharacterActiveEffect> activeEffects = 
                characterActiveEffectRepository.findByCharacterIdAndActive(characterId, true);

        for (CharacterActiveEffect effect : activeEffects) {
            if (effect.getRemainingRounds() != null) {
                int remaining = effect.getRemainingRounds() - 1;
                effect.setRemainingRounds(remaining);

                if (remaining <= 0) {
                    effect.setActive(false);
                }

                characterActiveEffectRepository.save(effect);
            }
        }
    }

    @Transactional
    public void removeEffect(Long characterId, Long effectId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        ActiveEffect effect = activeEffectRepository.findById(effectId)
                .orElseThrow(() -> new RuntimeException("ActiveEffect not found"));

        CharacterActiveEffect characterEffect = characterActiveEffectRepository
                .findByCharacterAndEffectAndActive(character, effect, true)
                .orElseThrow(() -> new RuntimeException("Character does not have this effect active"));

        // Marcar como inactivo en lugar de eliminar (para historial)
        characterEffect.setActive(false);
        characterActiveEffectRepository.save(characterEffect);
    }

    @Transactional
    public void removeAllEffects(Long characterId) {
        List<CharacterActiveEffect> effects = 
                characterActiveEffectRepository.findByCharacterIdAndActive(characterId, true);

        for (CharacterActiveEffect effect : effects) {
            effect.setActive(false);
            characterActiveEffectRepository.save(effect);
        }
    }

    private CharacterActiveEffectDto toDto(CharacterActiveEffect characterEffect) {
        CharacterActiveEffectDto dto = new CharacterActiveEffectDto();
        dto.setId(characterEffect.getId());
        dto.setCharacterId(characterEffect.getCharacter().getId());
        dto.setCharacterName(characterEffect.getCharacter().getName());
        dto.setEffectId(characterEffect.getEffect().getId());
        dto.setEffectName(characterEffect.getEffect().getName());
        dto.setEffectDescription(characterEffect.getEffect().getDescription());
        dto.setModifierValue(characterEffect.getEffect().getModifierValue());
        dto.setDuration(characterEffect.getEffect().getDuration());
        dto.setRequiresConcentration(characterEffect.getEffect().isRequiresConcentration());
        dto.setActive(characterEffect.isActive());
        dto.setAppliedAt(characterEffect.getAppliedAt());
        dto.setRemainingRounds(characterEffect.getRemainingRounds());
        dto.setCasterLevel(characterEffect.getCasterLevel());
        dto.setNotes(characterEffect.getNotes());
        return dto;
    }
}