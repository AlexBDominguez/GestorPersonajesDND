package services;

import dto.CharacterConditionDto;
import entities.CharacterCondition;
import entities.PlayerCharacter;
import entities.Condition;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterConditionRepository;
import repositories.PlayerCharacterRepository;
import repositories.ConditionRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CharacterConditionService {

    private final CharacterConditionRepository characterConditionRepository;
    private final PlayerCharacterRepository characterRepository;
    private final ConditionRepository conditionRepository;

    public CharacterConditionService(CharacterConditionRepository characterConditionRepository,
                                    PlayerCharacterRepository characterRepository,
                                    ConditionRepository conditionRepository) {
        this.characterConditionRepository = characterConditionRepository;
        this.characterRepository = characterRepository;
        this.conditionRepository = conditionRepository;
    }

    public List<CharacterConditionDto> getCharacterConditions(Long characterId, Boolean activeOnly) {
        List<CharacterCondition> conditions;
        
        if (activeOnly != null && activeOnly) {
            conditions = characterConditionRepository.findByCharacterIdAndActive(characterId, true);
        } else {
            conditions = characterConditionRepository.findByCharacterId(characterId);
        }
        
        return conditions.stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CharacterConditionDto applyConditionToCharacter(
            Long characterId, 
            Long conditionId, 
            String source,
            Integer durationRounds,
            boolean hasSavingThrow,
            Integer savingThrowDC,
            String savingThrowAbility,
            String notes) {
        
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Condition condition = conditionRepository.findById(conditionId)
                .orElseThrow(() -> new RuntimeException("Condition not found with ID: " + conditionId));

        // Verificar que el personaje no tenga ya esta condición activa
        if (characterConditionRepository.existsByCharacterAndConditionAndActive(character, condition, true)) {
            throw new RuntimeException("Character already has this condition active");
        }

        CharacterCondition characterCondition = new CharacterCondition(character, condition, source);
        characterCondition.setDurationRounds(durationRounds);
        characterCondition.setRemainingRounds(durationRounds);
        characterCondition.setHasSavingThrow(hasSavingThrow);
        characterCondition.setSavingThrowDC(savingThrowDC);
        characterCondition.setSavingThrowAbility(savingThrowAbility);
        characterCondition.setNotes(notes);

        characterConditionRepository.save(characterCondition);

        return toDto(characterCondition);
    }

    @Transactional
    public CharacterConditionDto updateRemainingRounds(Long characterConditionId, int remainingRounds) {
        CharacterCondition characterCondition = characterConditionRepository.findById(characterConditionId)
                .orElseThrow(() -> new RuntimeException("Character condition not found with ID: " + characterConditionId));

        characterCondition.setRemainingRounds(remainingRounds);

        // Si llega a 0 o menos, marcar como inactiva
        if (remainingRounds <= 0) {
            characterCondition.setActive(false);
        }

        characterConditionRepository.save(characterCondition);

        return toDto(characterCondition);
    }

    @Transactional
    public void removeConditionFromCharacter(Long characterId, Long conditionId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Condition condition = conditionRepository.findById(conditionId)
                .orElseThrow(() -> new RuntimeException("Condition not found with ID: " + conditionId));

        CharacterCondition characterCondition = characterConditionRepository
                .findByCharacterAndConditionAndActive(character, condition, true)
                .orElseThrow(() -> new RuntimeException("Character does not have this condition active"));

        // Marcar como inactiva en lugar de eliminar (para historial)
        characterCondition.setActive(false);
        characterConditionRepository.save(characterCondition);
    }

    @Transactional
    public void decrementAllConditionRounds(Long characterId) {
        List<CharacterCondition> activeConditions = 
                characterConditionRepository.findByCharacterIdAndActive(characterId, true);

        for (CharacterCondition condition : activeConditions) {
            if (condition.getRemainingRounds() != null) {
                int remaining = condition.getRemainingRounds() - 1;
                condition.setRemainingRounds(remaining);

                if (remaining <= 0) {
                    condition.setActive(false);
                }

                characterConditionRepository.save(condition);
            }
        }
    }

    private CharacterConditionDto toDto(CharacterCondition characterCondition) {
        CharacterConditionDto dto = new CharacterConditionDto();
        dto.setId(characterCondition.getId());
        dto.setCharacterId(characterCondition.getCharacter().getId());
        dto.setCharacterName(characterCondition.getCharacter().getName());
        dto.setConditionId(characterCondition.getCondition().getId());
        dto.setConditionName(characterCondition.getCondition().getName());
        dto.setDurationRounds(characterCondition.getDurationRounds());
        dto.setRemainingRounds(characterCondition.getRemainingRounds());
        dto.setHasSavingThrow(characterCondition.isHasSavingThrow());
        dto.setSavingThrowDC(characterCondition.getSavingThrowDC());
        dto.setSavingThrowAbility(characterCondition.getSavingThrowAbility());
        dto.setSource(characterCondition.getSource());
        dto.setNotes(characterCondition.getNotes());
        dto.setAppliedAt(characterCondition.getAppliedAt());
        dto.setActive(characterCondition.isActive());
        return dto;
    }
}