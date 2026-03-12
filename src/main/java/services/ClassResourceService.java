package services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dto.ClassResourceDto;
import entities.ClassResource;
import entities.DndClass;
import repositories.ClassResourceRepository;
import repositories.DndClassRepository;

@Service
public class ClassResourceService {

    private final ClassResourceRepository classResourceRepository;
    private final DndClassRepository dndClassRepository;

    public ClassResourceService(ClassResourceRepository classResourceRepository, DndClassRepository dndClassRepository) {
        this.classResourceRepository = classResourceRepository;
        this.dndClassRepository = dndClassRepository;
    }

    public List<ClassResourceDto> getAll() {
        return classResourceRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ClassResourceDto getById(Long id) {
        ClassResource resource = classResourceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Class resource not found with ID: " + id));
        return toDto(resource);
    }

    public List<ClassResourceDto> getByClassId(Long classId) {
        DndClass dndClass = dndClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Dnd class not found with ID: " + classId));

        return classResourceRepository.findByDndClass(dndClass).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ClassResourceDto create(ClassResourceDto dto) {
        ClassResource resource = new ClassResource();
        resource.setName(dto.getName());
        resource.setIndexName(dto.getIndexName());
        resource.setDescription(dto.getDescription());
        resource.setMaxFormula(dto.getMaxFormula());
        resource.setRecoveryType(dto.getRecoveryType());
        resource.setLevelUnlocked(dto.getLevelUnlocked());

        if(dto.getClassId() != null) {
            DndClass dndClass = dndClassRepository.findById(dto.getClassId())
                    .orElseThrow(() -> new RuntimeException("Dnd class not found with ID: " + dto.getClassId()));
            resource.setDndClass(dndClass);
        }

        classResourceRepository.save(resource);
        return toDto(resource);
    }

    private ClassResourceDto toDto(ClassResource resource) {
        ClassResourceDto dto = new ClassResourceDto();
        dto.setId(resource.getId());
        dto.setName(resource.getName());
        dto.setIndexName(resource.getIndexName());
        dto.setDescription(resource.getDescription());
        dto.setMaxFormula(resource.getMaxFormula());
        dto.setRecoveryType(resource.getRecoveryType());
        dto.setLevelUnlocked(resource.getLevelUnlocked());

        if(resource.getDndClass() != null) {
            dto.setClassId(resource.getDndClass().getId());
            dto.setClassName(resource.getDndClass().getName());
        }

        return dto;
    }

}
