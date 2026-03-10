package services;

import java.util.List;
import java.util.stream.Collectors;

import dto.ProficiencyDto;
import entities.Proficiency;
import enumeration.ProficiencyType;
import repositories.ProficiencyRepository;
 

public class ProficiencyService {

    private final ProficiencyRepository proficiencyRepository;

    public ProficiencyService(ProficiencyRepository proficiencyRepository) {
        this.proficiencyRepository = proficiencyRepository;
    }

    public List<ProficiencyDto> getAll(){
        return proficiencyRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ProficiencyDto getById(Long id){
        Proficiency proficiency = proficiencyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Proficiency not found with id: " + id));
        return toDto(proficiency);
    }

    public List<ProficiencyDto> getByType(ProficiencyType type){
        return proficiencyRepository.findByType(type).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<ProficiencyDto> searchByName(String name){
        return proficiencyRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ProficiencyDto create(ProficiencyDto dto){
        Proficiency proficiency = new Proficiency();
        proficiency.setIndexName(dto.getIndexName());
        proficiency.setName(dto.getName());
        proficiency.setType(dto.getType());
        proficiency.setDescription(dto.getDescription());
        proficiency.setCategory(dto.getCategory());
        proficiency.setApiUrl(dto.getApiUrl());

        proficiencyRepository.save(proficiency);
        return toDto(proficiency);
    }

    private ProficiencyDto toDto(Proficiency proficiency){
        ProficiencyDto dto = new ProficiencyDto();
        dto.setId(proficiency.getId());
        dto.setIndexName(proficiency.getIndexName());
        dto.setName(proficiency.getName());
        dto.setType(proficiency.getType());
        dto.setDescription(proficiency.getDescription());
        dto.setCategory(proficiency.getCategory());
        dto.setApiUrl(proficiency.getApiUrl());
        return dto;

    }
    
}
