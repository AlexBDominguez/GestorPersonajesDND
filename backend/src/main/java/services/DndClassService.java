package services;

import dto.ClassFeatureDto;
import dto.DndClassDto;
import dto.SubclassDto;
import entities.ClassFeature;
import entities.DndClass;
import entities.Subclass;
import org.springframework.stereotype.Service;
import repositories.ClassFeatureRepository;
import repositories.DndClassRepository;
import repositories.SubclassRepository;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class DndClassService {

    private final DndClassRepository dndClassRepository;
    private final ClassFeatureRepository classFeatureRepository;
    private final SubclassRepository subclassRepository;

    public DndClassService(
            DndClassRepository dndClassRepository,
            ClassFeatureRepository classFeatureRepository,
            SubclassRepository subclassRepository) {
        this.dndClassRepository = dndClassRepository;
        this.classFeatureRepository = classFeatureRepository;
        this.subclassRepository = subclassRepository;
    }

    public List<DndClassDto> getAll() {
        return dndClassRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public DndClassDto getById(Long id) {
        DndClass dndClass = dndClassRepository.findById(Objects.requireNonNull(id))
                .orElseThrow(() -> new RuntimeException("DndClass not found with ID: " + id));
        return toDto(dndClass);
    }

    public DndClassDto create(DndClassDto dto) {
        DndClass dndClass = new DndClass();
        dndClass.setIndexName(dto.getIndexName());
        dndClass.setName(dto.getName());
        dndClass.setHitDie(dto.getHitDie());
        dndClass.setProficiencies(dto.getProficiencies());
        dndClass.setDescription(dto.getDescription());
        return toDto(dndClassRepository.save(dndClass));
    }

    public List<ClassFeatureDto> getFeaturesByClassId(Long classId) {
        DndClass dndClass = dndClassRepository.findById(Objects.requireNonNull(classId))
                .orElseThrow(() -> new RuntimeException("DndClass not found with ID: " + classId));
        return classFeatureRepository.findByDndClass(dndClass).stream()
                .sorted((a, b) -> Integer.compare(a.getLevel(), b.getLevel()))
                .map(this::toFeatureDto)
                .collect(Collectors.toList());
    }

    public List<SubclassDto> getSubclassesByClassId(Long classId) {
        DndClass dndClass = dndClassRepository.findById(Objects.requireNonNull(classId))
                .orElseThrow(() -> new RuntimeException("DndClass not found with ID: " + classId));
        return subclassRepository.findByDndClass(dndClass).stream()
                .map(this::toSubclassDto)
                .collect(Collectors.toList());
    }

    private DndClassDto toDto(DndClass dndClass) {
        DndClassDto dto = new DndClassDto();
        dto.setId(dndClass.getId());
        dto.setIndexName(dndClass.getIndexName());
        dto.setName(dndClass.getName());
        dto.setHitDie(dndClass.getHitDie());
        dto.setProficiencies(dndClass.getProficiencies());
        dto.setDescription(dndClass.getDescription());
        dto.setSpellcastingAbility(dndClass.getSpellcastingAbility());
        dto.setSkillChoiceCount(dndClass.getNumSkillChoices());
        dto.setAllowedSkillIndices(dndClass.getSkillChoiceOptions());
        return dto;
    }

    private ClassFeatureDto toFeatureDto(ClassFeature feature) {
        ClassFeatureDto dto = new ClassFeatureDto();
        dto.setId(feature.getId());
        dto.setIndexName(feature.getIndexName());
        dto.setName(feature.getName());
        dto.setLevel(feature.getLevel());
        dto.setDescription(feature.getDescription());
        dto.setApiUrl(feature.getApiUrl());
        return dto;
    }

    private SubclassDto toSubclassDto(Subclass subclass) {
        SubclassDto dto = new SubclassDto();
        dto.setId(subclass.getId());
        dto.setIndexName(subclass.getIndexName());
        dto.setName(subclass.getName());
        dto.setClassId(subclass.getDndClass().getId());
        dto.setSubclassFlavor(subclass.getSubclassFlavor());
        dto.setDescription(subclass.getDescription());
        dto.setSpellcastingAbility(subclass.getSpellcastingAbility());
        return dto;
    }
}