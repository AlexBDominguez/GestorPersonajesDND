package services;

import dto.DndClassDto;
import entities.DndClass;
import org.springframework.stereotype.Service;
import repositories.DndClassRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class DndClassService {

    private final DndClassRepository dndClassRepository;

    public DndClassService(DndClassRepository dndClassRepository){
        this.dndClassRepository = dndClassRepository;
    }

    public List<DndClassDto> getAll(){
        return dndClassRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public DndClassDto getById(Long id){
        DndClass dndClass = dndClassRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("DndClass not found with ID: " + id));
        return toDto(dndClass);
    }

    public DndClassDto create(DndClassDto dto){
        DndClass dndClass = new DndClass();
        dndClass.setName(dto.getName());
        dndClass.setIndexName(dto.getIndexName());
        dndClass.setHitDie(dto.getHitDie());
        dndClass.setProficiencies(dto.getProficiencies());
        dndClass.setDescription(dto.getDescription());

        dndClassRepository.save(dndClass);

        return toDto(dndClass);
    }

    private DndClassDto toDto(DndClass dndClass){
        DndClassDto dto = new DndClassDto();
        dto.setId(dndClass.getId());
        dto.setName(dndClass.getName());
        dto.setIndexName(dndClass.getIndexName());
        dto.setHitDie(dndClass.getHitDie());
        dto.setProficiencies(dndClass.getProficiencies());
        dto.setDescription(dndClass.getDescription());

        return dto;
    }
}
