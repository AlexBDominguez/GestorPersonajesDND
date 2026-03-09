package services;

import entities.SubclassFeature;
import entities.Subclass;
import org.springframework.stereotype.Service;
import repositories.SubclassFeatureRepository;
import repositories.SubclassRepository;

import java.util.List;

@Service
public class SubclassFeatureService {

    private final SubclassFeatureRepository subclassFeatureRepository;
    private final SubclassRepository subclassRepository;

    public SubclassFeatureService(SubclassFeatureRepository subclassFeatureRepository,
                                 SubclassRepository subclassRepository) {
        this.subclassFeatureRepository = subclassFeatureRepository;
        this.subclassRepository = subclassRepository;
    }

    public List<SubclassFeature> getFeaturesBySubclass(Long subclassId) {
        Subclass subclass = subclassRepository.findById(subclassId)
                .orElseThrow(() -> new RuntimeException("Subclass not found with ID: " + subclassId));
        return subclassFeatureRepository.findBySubclass(subclass);
    }

    public List<SubclassFeature> getFeaturesBySubclassAndLevel(Long subclassId, int level) {
        Subclass subclass = subclassRepository.findById(subclassId)
                .orElseThrow(() -> new RuntimeException("Subclass not found with ID: " + subclassId));
        return subclassFeatureRepository.findBySubclassAndLevel(subclass, level);
    }

    public List<SubclassFeature> getFeaturesUpToLevel(Long subclassId, int level) {
        Subclass subclass = subclassRepository.findById(subclassId)
                .orElseThrow(() -> new RuntimeException("Subclass not found with ID: " + subclassId));
        return subclassFeatureRepository.findBySubclassAndLevelLessThanEqual(subclass, level);
    }
}