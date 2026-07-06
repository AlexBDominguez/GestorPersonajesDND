package services;

import dto.ClassFeatureDto;
import entities.SubclassFeature;
import entities.Subclass;
import org.springframework.stereotype.Service;
import repositories.SubclassFeatureRepository;
import repositories.SubclassRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SubclassFeatureService {

    private final SubclassFeatureRepository subclassFeatureRepository;
    private final SubclassRepository subclassRepository;

    public SubclassFeatureService(SubclassFeatureRepository subclassFeatureRepository,
                                 SubclassRepository subclassRepository) {
        this.subclassFeatureRepository = subclassFeatureRepository;
        this.subclassRepository = subclassRepository;
    }

    public List<ClassFeatureDto> getFeaturesBySubclass(Long subclassId) {
        Subclass subclass = subclassRepository.findById(subclassId)
                .orElseThrow(() -> new RuntimeException("Subclass not found with ID: " + subclassId));
        return subclassFeatureRepository.findBySubclass(subclass).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<ClassFeatureDto> getFeaturesBySubclassAndLevel(Long subclassId, int level) {
        Subclass subclass = subclassRepository.findById(subclassId)
                .orElseThrow(() -> new RuntimeException("Subclass not found with ID: " + subclassId));
        return subclassFeatureRepository.findBySubclassAndLevel(subclass, level).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<ClassFeatureDto> getFeaturesUpToLevel(Long subclassId, int level) {
        Subclass subclass = subclassRepository.findById(subclassId)
                .orElseThrow(() -> new RuntimeException("Subclass not found with ID: " + subclassId));
        return subclassFeatureRepository.findBySubclassAndLevelLessThanEqual(subclass, level).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    private ClassFeatureDto toDto(SubclassFeature feature) {
        ClassFeatureDto dto = new ClassFeatureDto();
        dto.setId(feature.getId());
        dto.setIndexName(feature.getIndexName());
        dto.setName(feature.getName());
        dto.setLevel(feature.getLevel());
        dto.setDescription(feature.getDescription());
        dto.setApiUrl(feature.getApiUrl());
        dto.setConsumesResourceIndexName(feature.getConsumesResourceIndexName());
        return dto;
    }
}