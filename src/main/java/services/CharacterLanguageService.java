package services;

import dto.CharacterLanguageDto;
import entities.CharacterLanguage;
import entities.PlayerCharacter;
import entities.Language;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterLanguageRepository;
import repositories.PlayerCharacterRepository;
import repositories.LanguageRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CharacterLanguageService {

    private final CharacterLanguageRepository characterLanguageRepository;
    private final PlayerCharacterRepository characterRepository;
    private final LanguageRepository languageRepository;

    public CharacterLanguageService(CharacterLanguageRepository characterLanguageRepository,
                                   PlayerCharacterRepository characterRepository,
                                   LanguageRepository languageRepository) {
        this.characterLanguageRepository = characterLanguageRepository;
        this.characterRepository = characterRepository;
        this.languageRepository = languageRepository;
    }

    public List<CharacterLanguageDto> getCharacterLanguages(Long characterId) {
        return characterLanguageRepository.findByCharacterId(characterId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CharacterLanguageDto assignLanguageToCharacter(Long characterId, Long languageId, String source, String notes) {
        PlayerCharacter character = characterRepository.findById(Long.valueOf(characterId))
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Language language = languageRepository.findById(Long.valueOf(languageId))
                .orElseThrow(() -> new RuntimeException("Language not found with ID: " + languageId));

        // Verificar que el personaje no conozca ya este idioma
        if (characterLanguageRepository.existsByCharacterAndLanguage(character, language)) {
            throw new RuntimeException("Character already knows this language");
        }

        CharacterLanguage characterLanguage = new CharacterLanguage(character, language, source);
        characterLanguage.setNotes(notes);

        characterLanguageRepository.save(characterLanguage);

        return toDto(characterLanguage);
    }

    @Transactional
    public void removeLanguageFromCharacter(Long characterId, Long languageId) {
        PlayerCharacter character = characterRepository.findById(Long.valueOf(characterId))
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Language language = languageRepository.findById(Long.valueOf(languageId))
                .orElseThrow(() -> new RuntimeException("Language not found with ID: " + languageId));

        CharacterLanguage characterLanguage = characterLanguageRepository
                .findByCharacterAndLanguage(character, language)
                .orElseThrow(() -> new RuntimeException("Character does not know this language"));

        characterLanguageRepository.delete(characterLanguage);
    }

    private CharacterLanguageDto toDto(CharacterLanguage characterLanguage) {
        CharacterLanguageDto dto = new CharacterLanguageDto();
        dto.setId(characterLanguage.getId());
        dto.setCharacterId(characterLanguage.getCharacter().getId());
        dto.setCharacterName(characterLanguage.getCharacter().getName());
        dto.setLanguageId(characterLanguage.getLanguage().getId());
        dto.setLanguageName(characterLanguage.getLanguage().getName());
        dto.setLanguageType(characterLanguage.getLanguage().getType());
        dto.setScript(characterLanguage.getLanguage().getScript());
        dto.setSource(characterLanguage.getSource());
        dto.setNotes(characterLanguage.getNotes());
        return dto;
    }
}