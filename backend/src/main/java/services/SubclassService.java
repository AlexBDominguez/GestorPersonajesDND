package services;

import java.util.List;
import java.util.stream.Collectors;

import entities.DndClass;
import entities.Subclass;

import org.springframework.stereotype.Service;

import dto.SubclassDto;
import repositories.DndClassRepository;
import repositories.SubclassRepository;

@Service
public class SubclassService {

    private final SubclassRepository subclassRepository;
    private final DndClassRepository dndClassRepository;


    public SubclassService(SubclassRepository subclassRepository, DndClassRepository dndClassRepository) {
        this.subclassRepository = subclassRepository;
        this.dndClassRepository = dndClassRepository;
    }

    public List<SubclassDto> getAll(){
        return subclassRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public SubclassDto getById(Long id) {
        Subclass subclass = subclassRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Subclass not found with ID: " + id));
        return toDto(subclass);
    }

    public List<SubclassDto> getByClassId(Long classId) {
        DndClass dndClass = dndClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found with ID: " + classId));                
        return subclassRepository.findByDndClass(dndClass).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public SubclassDto create(SubclassDto dto){
        Subclass subclass = new Subclass();
        subclass.setIndexName(dto.getIndexName());
        subclass.setName(dto.getName());
        subclass.setSubclassFlavor(dto.getSubClassFlavor());
        subclass.setDescription(dto.getDescription());
        subclass.setSpellcastingAbility(dto.getSpellcastingAbility());

        if(dto.getClassId()!= null) {
            DndClass dndClass = dndClassRepository.findById(dto.getClassId())
                    .orElseThrow(() -> new RuntimeException("Class not found with ID: " + dto.getClassId()));
            subclass.setDndClass(dndClass);
        }
        subclassRepository.save(subclass);
        return toDto(subclass);
    }

    private SubclassDto toDto(Subclass subclass) {
        SubclassDto dto = new SubclassDto();
        dto.setId(subclass.getId());
        dto.setIndexName(subclass.getIndexName());
        dto.setName(subclass.getName());
        dto.setSubClassFlavor(subclass.getSubclassFlavor());
        dto.setDescription(subclass.getDescription());
        dto.setSpellcastingAbility(subclass.getSpellcastingAbility());

        if(subclass.getDndClass() != null) {
            dto.setClassId(subclass.getDndClass().getId());
            dto.setClassName(subclass.getDndClass().getName());
        }
        return dto;
    }

    
}
