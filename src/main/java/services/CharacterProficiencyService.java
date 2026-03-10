package services;

import dto.CharacterProficiencyDto;
import entities.CharacterProficiency;
import entities.PlayerCharacter;
import entities.Proficiency;
import enumeration.ProficiencyType;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterProficiencyRepository;
import repositories.PlayerCharacterRepository;
import repositories.ProficiencyRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CharacterProficiencyService {

    private final CharacterProficiencyRepository characterProficiencyRepository;
    private final PlayerCharacterRepository characterRepository;
    private final ProficiencyRepository proficiencyRepository;

    public CharacterProficiencyService(CharacterProficiencyRepository characterProficiencyRepository,
                                      PlayerCharacterRepository characterRepository,
                                      ProficiencyRepository proficiencyRepository) {
        this.characterProficiencyRepository = characterProficiencyRepository;
        this.characterRepository = characterRepository;
        this.proficiencyRepository = proficiencyRepository;
    }

    public List<CharacterProficiencyDto> getCharacterProficiencies(Long characterId) {
        return characterProficiencyRepository.findByCharacterId(characterId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<CharacterProficiencyDto> getCharacterProficienciesByType(Long characterId, ProficiencyType type) {
        return characterProficiencyRepository.findByCharacterIdAndType(characterId, type).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CharacterProficiencyDto assignProficiencyToCharacter(Long characterId, Long proficiencyId, String source, String notes) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Proficiency proficiency = proficiencyRepository.findById(proficiencyId)
                .orElseThrow(() -> new RuntimeException("Proficiency not found with ID: " + proficiencyId));

        // Verificar que el personaje no tenga ya esta proficiency
        if (characterProficiencyRepository.existsByCharacterAndProficiency(character, proficiency)) {
            throw new RuntimeException("Character already has this proficiency");
        }

        CharacterProficiency characterProficiency = new CharacterProficiency(character, proficiency, source);
        characterProficiency.setNotes(notes);

        characterProficiencyRepository.save(characterProficiency);

        return toDto(characterProficiency);
    }

    @Transactional
    public void removeProficiencyFromCharacter(Long characterId, Long proficiencyId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found with ID: " + characterId));

        Proficiency proficiency = proficiencyRepository.findById(proficiencyId)
                .orElseThrow(() -> new RuntimeException("Proficiency not found with ID: " + proficiencyId));

        CharacterProficiency characterProficiency = characterProficiencyRepository
                .findByCharacterAndProficiency(character, proficiency)
                .orElseThrow(() -> new RuntimeException("Character does not have this proficiency"));

        characterProficiencyRepository.delete(characterProficiency);
    }

    private CharacterProficiencyDto toDto(CharacterProficiency characterProficiency) {
        CharacterProficiencyDto dto = new CharacterProficiencyDto();
        dto.setId(characterProficiency.getId());
        dto.setCharacterId(characterProficiency.getCharacter().getId());
        dto.setCharacterName(characterProficiency.getCharacter().getName());
        dto.setProficiencyId(characterProficiency.getProficiency().getId());
        dto.setProficiencyName(characterProficiency.getProficiency().getName());
        dto.setProficiencyType(characterProficiency.getProficiency().getType());
        dto.setCategory(characterProficiency.getProficiency().getCategory());
        dto.setSource(characterProficiency.getSource());
        dto.setNotes(characterProficiency.getNotes());
        return dto;
    }
}