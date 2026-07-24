package services;

import dto.RaceDto;
import dto.RacialTraitDto;
import entities.Race;
import entities.RacialTrait;
import repositories.RaceRepository;
import repositories.SubraceRepository;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

@Service
public class RaceService {
    private final RaceRepository raceRepository;
    private final SubraceRepository subraceRepository;

    public RaceService(RaceRepository raceRepository, SubraceRepository subraceRepository) {
        this.raceRepository = raceRepository;
        this.subraceRepository = subraceRepository;
    }

    public List<RaceDto> getAllRaces(List<String> sources) {
        List<Race> races = (sources == null || sources.isEmpty())
                ? raceRepository.findAll()
                : raceRepository.findBySourceIn(sources);
        return races.stream().map(this::toDto).collect(Collectors.toList());
    }

    public RaceDto getRace(Long id) {
        Race race = raceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Race not found"));
        return toDto(race);
    }

    /** Traits de una raza (base). */
    public List<RacialTraitDto> getTraits(Long raceId) {
        Race race = raceRepository.findById(raceId)
                .orElseThrow(() -> new RuntimeException("Race not found"));
        return race.getTraits().stream()
                .map(this::traitToDto)
                .collect(Collectors.toList());
    }

    /** Traits de una subraza. */
    public List<RacialTraitDto> getSubraceTraits(Long subraceId) {
        return subraceRepository.findById(subraceId)
                .map(s -> s.getTraits().stream()
                        .map(this::traitToDto)
                        .collect(Collectors.toList()))
                .orElseThrow(() -> new RuntimeException("Subrace not found"));
    }

    public Race save(Race race) {
        return raceRepository.save(race);
    }

    // #9: creación manual desde el panel de admin. Igual que SubraceService.create(), los
    // traits/hechizos otorgados se gestionan vía sync, no desde este DTO -- una raza nueva
    // creada aquí empieza sin traits, se añaden después si hace falta.
    public RaceDto create(RaceDto dto) {
        Race race = new Race();
        race.setIndexName(dto.getIndexName());
        race.setName(dto.getName());
        race.setSize(dto.getSize());
        race.setSpeed(dto.getSpeed());
        race.setAbilityBonuses(dto.getAbilityBonuses());
        race.setDescription(dto.getDescription());
        race.setSource(dto.getSource() != null && !dto.getSource().isBlank() ? dto.getSource() : "Homebrew");
        return toDto(raceRepository.save(race));
    }

    private RaceDto toDto(Race race) {
        RaceDto dto = new RaceDto();
        dto.setId(race.getId());
        dto.setIndexName(race.getIndexName());
        dto.setName(race.getName());
        dto.setSize(race.getSize());
        dto.setSpeed(race.getSpeed());
        dto.setAbilityBonuses(race.getAbilityBonuses());
        dto.setDescription(race.getDescription());
        dto.setSource(race.getSource());
        return dto;
    }

    private RacialTraitDto traitToDto(RacialTrait t) {
        RacialTraitDto dto = new RacialTraitDto();
        dto.setId(t.getId());
        dto.setIndexName(t.getIndexName());
        dto.setName(t.getName());
        dto.setDescription(t.getDescription());
        dto.setTraitType(t.getTraitType());
        dto.setConsumesResourceIndexName(t.getConsumesResourceIndexName());
        dto.setGrantsBonusKey(t.getGrantsBonusKey());
        return dto;
    }
}