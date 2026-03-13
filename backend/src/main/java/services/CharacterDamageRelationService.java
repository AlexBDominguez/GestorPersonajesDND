package services;

import dto.CharacterDamageRelationDto;
import entities.CharacterDamageRelation;
import entities.PlayerCharacter;
import entities.DamageType;
import enumeration.DamageRelationType;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterDamageRelationRepository;
import repositories.PlayerCharacterRepository;
import repositories.DamageTypeRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CharacterDamageRelationService {

    private final CharacterDamageRelationRepository characterDamageRelationRepository;
    private final PlayerCharacterRepository characterRepository;
    private final DamageTypeRepository damageTypeRepository;

    public CharacterDamageRelationService(CharacterDamageRelationRepository characterDamageRelationRepository,
                                         PlayerCharacterRepository characterRepository,
                                         DamageTypeRepository damageTypeRepository) {
        this.characterDamageRelationRepository = characterDamageRelationRepository;
        this.characterRepository = characterRepository;
        this.damageTypeRepository = damageTypeRepository;
    }

    public List<CharacterDamageRelationDto> getCharacterDamageRelations(Long characterId) {
        return characterDamageRelationRepository.findByCharacterId(characterId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<CharacterDamageRelationDto> getCharacterDamageRelationsByType(
            Long characterId, DamageRelationType relationType) {
        return characterDamageRelationRepository.findByCharacterIdAndRelationType(characterId, relationType).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CharacterDamageRelationDto addDamageRelationToCharacter(
            Long characterId,
            Long damageTypeId,
            DamageRelationType relationType,
            String source,
            boolean temporary,
            String conditions,
            String notes) {
        
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        DamageType damageType = damageTypeRepository.findById(damageTypeId)
                .orElseThrow(() -> new RuntimeException("DamageType not found with ID: " + damageTypeId));

        // Verificar que no exista ya esta relación
        if (characterDamageRelationRepository.existsByCharacterAndDamageTypeAndRelationType(
                character, damageType, relationType)) {
            throw new RuntimeException("Character already has this damage relation");
        }

        CharacterDamageRelation relation = new CharacterDamageRelation(
                character, damageType, relationType, source);
        relation.setTemporary(temporary);
        relation.setConditions(conditions);
        relation.setNotes(notes);

        characterDamageRelationRepository.save(relation);

        return toDto(relation);
    }

    @Transactional
    public void removeDamageRelationFromCharacter(Long characterId, Long damageTypeId, DamageRelationType relationType) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        DamageType damageType = damageTypeRepository.findById(damageTypeId)
                .orElseThrow(() -> new RuntimeException("DamageType not found with ID: " + damageTypeId));

        CharacterDamageRelation relation = characterDamageRelationRepository
                .findByCharacterAndDamageTypeAndRelationType(character, damageType, relationType)
                .orElseThrow(() -> new RuntimeException("Character does not have this damage relation"));

        characterDamageRelationRepository.delete(relation);
    }

    @Transactional
    public void removeAllTemporaryRelations(Long characterId) {
        List<CharacterDamageRelation> temporaryRelations = 
                characterDamageRelationRepository.findByCharacterIdAndTemporary(characterId, true);
        
        characterDamageRelationRepository.deleteAll(temporaryRelations);
    }

    private CharacterDamageRelationDto toDto(CharacterDamageRelation relation) {
        CharacterDamageRelationDto dto = new CharacterDamageRelationDto();
        dto.setId(relation.getId());
        dto.setCharacterId(relation.getCharacter().getId());
        dto.setCharacterName(relation.getCharacter().getName());
        dto.setDamageTypeId(relation.getDamageType().getId());
        dto.setDamageTypeName(relation.getDamageType().getName());
        dto.setRelationType(relation.getRelationType());
        dto.setSource(relation.getSource());
        dto.setTemporary(relation.isTemporary());
        dto.setConditions(relation.getConditions());
        dto.setNotes(relation.getNotes());
        return dto;
    }
}