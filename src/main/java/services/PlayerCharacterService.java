package services;

import dto.PlayerCharacterDto;
import entities.PlayerCharacter;
import entities.Race;
import entities.DndClass;
import org.springframework.stereotype.Service;
import repositories.PlayerCharacterRepository;
import repositories.RaceRepository;
import repositories.DndClassRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlayerCharacterService {

    private final PlayerCharacterRepository characterRepository;
    private final RaceRepository raceRepository;
    private final DndClassRepository dndClassRepository;

    public PlayerCharacterService(PlayerCharacterRepository characterRepository,
                                  RaceRepository raceRepository,
                                  DndClassRepository dndClassRepository) {
        this.characterRepository = characterRepository;
        this.raceRepository = raceRepository;
        this.dndClassRepository = dndClassRepository;
    }

    public List<PlayerCharacterDto> getAll() {
        return characterRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public PlayerCharacterDto getById(Long id) {
        PlayerCharacter playerCharacter = characterRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("PlayerCharacter not found with ID: " + id));

        return toDto(playerCharacter);
    }

    public PlayerCharacterDto create(PlayerCharacterDto dto) {
        PlayerCharacter playerCharacter = new PlayerCharacter();

        playerCharacter.setName(dto.getName());
        playerCharacter.setLevel(dto.getLevel());
        playerCharacter.setAbilityScores(dto.getAbilityScores());
        playerCharacter.setBackstory(dto.getBackstory());
        playerCharacter.setCurrentHP(dto.getCurrentHp());
        playerCharacter.setMaxHP(dto.getMaxHp());

        Race race = raceRepository.findById(dto.getRaceId())
                .orElseThrow(() -> new RuntimeException("Race not found"));
        playerCharacter.setRace(race);

        DndClass dndClass = dndClassRepository.findById(dto.getDndClassId())
                .orElseThrow(() -> new RuntimeException("DndClass not found"));
        playerCharacter.setDndClass(dndClass);

        playerCharacter.setProficiencyBonus((int) Math.ceil((2 + (dto.getLevel() - 1) / 4.0)));

        characterRepository.save(playerCharacter);

        return toDto(playerCharacter);
    }

    private PlayerCharacterDto toDto(PlayerCharacter playerCharacter) {

        PlayerCharacterDto dto = new PlayerCharacterDto();

        dto.setId(playerCharacter.getId());
        dto.setName(playerCharacter.getName());
        dto.setLevel(playerCharacter.getLevel());
        dto.setAbilityScores(playerCharacter.getAbilityScores());
        dto.setProficiencyBonus(playerCharacter.getProficiencyBonus());
        dto.setBackstory(playerCharacter.getBackstory());
        dto.setCurrentHp(playerCharacter.getCurrentHP());
        dto.setMaxHp(playerCharacter.getMaxHP());

        if (playerCharacter.getRace() != null) {
            dto.setRaceId(playerCharacter.getRace().getId());
            dto.setRaceName(playerCharacter.getRace().getName());
        }

        if (playerCharacter.getDndClass() != null) {
            dto.setDndClassId(playerCharacter.getDndClass().getId());
            dto.setDndClassName(playerCharacter.getDndClass().getName());
        }

        return dto;
    }
}
