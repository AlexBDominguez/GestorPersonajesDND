package services;

import dto.CharacterFeatDto;
import entities.CharacterFeat;
import entities.PlayerCharacter;
import entities.Feat;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterFeatRepository;
import repositories.PlayerCharacterRepository;
import repositories.FeatRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CharacterFeatService {

    private final CharacterFeatRepository characterFeatRepository;
    private final PlayerCharacterRepository characterRepository;
    private final FeatRepository featRepository;

    public CharacterFeatService(CharacterFeatRepository characterFeatRepository,
                               PlayerCharacterRepository characterRepository,
                               FeatRepository featRepository) {
        this.characterFeatRepository = characterFeatRepository;
        this.characterRepository = characterRepository;
        this.featRepository = featRepository;
    }

    public List<CharacterFeatDto> getCharacterFeats(Long characterId) {
        return characterFeatRepository.findByCharacterId(characterId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CharacterFeatDto assignFeatToCharacter(Long characterId, Long featId, String notes) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Feat feat = featRepository.findById(featId)
                .orElseThrow(() -> new RuntimeException("Feat not found with ID: " + featId));

        // Verificar que el personaje no tenga ya este feat
        if (characterFeatRepository.existsByCharacterAndFeat(character, feat)) {
            throw new RuntimeException("Character already has this feat");
        }

        CharacterFeat characterFeat = new CharacterFeat(character, feat, character.getLevel());
        characterFeat.setNotes(notes);

        characterFeatRepository.save(characterFeat);

        return toDto(characterFeat);
    }

    @Transactional
    public void removeFeatFromCharacter(Long characterId, Long featId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Feat feat = featRepository.findById(featId)
                .orElseThrow(() -> new RuntimeException("Feat not found with ID: " + featId));

        CharacterFeat characterFeat = characterFeatRepository.findByCharacterAndFeat(character, feat)
                .orElseThrow(() -> new RuntimeException("Character does not have this feat"));

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