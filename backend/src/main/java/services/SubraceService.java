package services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dto.SubraceDto;
import entities.Race;
import entities.Subrace;
import repositories.RaceRepository;
import repositories.SubraceRepository;

@Service
public class SubraceService {
    private final SubraceRepository subraceRepository;
    private final RaceRepository raceRepository;

    public SubraceService(SubraceRepository subraceRepository, RaceRepository raceRepository) {
        this.subraceRepository = subraceRepository;
        this.raceRepository = raceRepository;
    }

    public List<SubraceDto> getByRaceId(Long raceId) {
        return subraceRepository.findByRaceId(raceId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());   
    }

    public SubraceDto getById(Long id) {
        return subraceRepository.findById(id)
                .map(this::toDto)
                .orElseThrow(() -> new RuntimeException("Subrace not found with ID: " + id));
    }

    public SubraceDto create(SubraceDto dto) {
        Race race = raceRepository.findById(dto.getRaceId())
                .orElseThrow(() -> new RuntimeException("Race not found"));
        Subrace s = new Subrace();
        s.setIndexName(dto.getIndexName());
        s.setName(dto.getName());
        s.setRace(race);
        s.setDescription(dto.getDescription());
        s.setAbilityBonuses(dto.getAbilityBonuses());
        // Traits are managed via sync; skip setting from DTO
        return toDto(subraceRepository.save(s));
    }

    private SubraceDto toDto(Subrace s) {
        SubraceDto dto = new SubraceDto();
        dto.setId(s.getId());
        dto.setIndexName(s.getIndexName());
        dto.setName(s.getName());
        dto.setRaceId(s.getRace().getId());
        dto.setRaceName(s.getRace().getName());
        dto.setDescription(s.getDescription());
        dto.setAbilityBonuses(s.getAbilityBonuses() != null
                ? s.getAbilityBonuses() : new java.util.HashMap<>());
        dto.setTraits(s.getTraits() != null
                ? s.getTraits().stream().map(t -> t.getName()).collect(Collectors.toList())
                : new java.util.ArrayList<>());
        return dto;        
    }
}
