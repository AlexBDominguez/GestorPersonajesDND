package repositories;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dto.CharacterFeatDto;
import entities.CharacterFeat;
import entities.Feat;
import entities.PlayerCharacter;
import jakarta.transaction.Transactional;

@Service
public class CharacterFeatService {
    
    private final CharacterFeatRepository characterFeatRepository;
    private final PlayerCharacterRepository characterRepository;
    private final FeatRepository featRepository;

    public CharacterFeatService(CharacterFeatRepository characterFeatRepository, PlayerCharacterRepository playerCharacterRepository, FeatRepository featRepository) {
        this.characterFeatRepository = characterFeatRepository;
        this.characterRepository = playerCharacterRepository;
        this.featRepository = featRepository;
    }

    public List<CharacterFeatDto> getCharacterFeat(Long characterId) {
        return characterFeatRepository.findByCharacterId(characterId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CharacterFeatDto assignFeatToCharacter(Long characterId, Long featId, String notes) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with id: " + characterId));

        Feat feat = featRepository.findById(featId)
                .orElseThrow(() -> new RuntimeException("Feat not found with id: " + featId));

        // Verificar que el personaje no tenga ya asignado ese feat
        if (characterFeatRepository.existsByCharacterAndFeat(character, feat)){
            throw new RuntimeException("Character already has this feat assigned.");
        }

        CharacterFeat characterFeat = new CharacterFeat(character, feat, character.getLevel());
        characterFeat.setNotes(notes);

        characterFeatRepository.save(characterFeat);
        
        return toDto(characterFeat);
    }

    @Transactional
    public void removeFeatFromCharacter(Long characterId, Long featId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with id: " + characterId));

        Feat feat = featRepository.findById(featId)
                .orElseThrow(() -> new RuntimeException("Feat not found with id: " + featId));
        
        CharacterFeat characterFeat = characterFeatRepository.findByCharacterAndFeat(character, feat)
                .orElseThrow(() -> new RuntimeException("Character does not have this feat assigned."));

        characterFeatRepository.delete(characterFeat);
    }

    private CharacterFeatDto toDto(CharacterFeat characterFeat) {
        CharacterFeatDto dto = new CharacterFeatDto();
        dto.setId(characterFeat.getId());
        dto.setCharacterId(characterFeat.getCharacter().getId());
        dto.setCharacterName(characterFeat.getCharacter().getName());
        dto.setFeatId(characterFeat.getFeat().getId());
        dto.setFeatName(characterFeat.getFeat().getName());
        dto.setFeatDescription(characterFeat.getFeat().getDescription());
        dto.setLevelObtained(characterFeat.getLevelObtained());
        dto.setNotes(characterFeat.getNotes());
        return dto;
    }


}
