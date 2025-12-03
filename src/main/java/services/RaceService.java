package services;

import dto.RaceDto;
import entities.Race;
import repositories.RaceRepository;

import java.util.List;
import java.util.stream.Collectors;

public class RaceService {
    private final RaceRepository raceRepository;

    public RaceService(RaceRepository raceRepository) {
        this.raceRepository = raceRepository;
    }

    public List<RaceDto> getAllRaces(){
        return raceRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public RaceDto getRace(Long id){
        Race race = raceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Race not found"));

        return toDto(race);
    }

    public Race save(Race race) {
        return raceRepository.save(race);
    }

    private RaceDto toDto(Race race){
        RaceDto raceDto = new RaceDto();
        raceDto.setId(race.getId());
        raceDto.setIndexName(race.getIndexName());
        raceDto.setName(race.getName());
        raceDto.setSize(race.getSize());
        raceDto.setSpeed(race.getSpeed());
        raceDto.setAbilityBonuses(race.getAbilityBonuses());
        raceDto.setDescription(race.getDescription());
        return raceDto;
    }

}
