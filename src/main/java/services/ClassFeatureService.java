package services;

import java.util.List;
import org.springframework.stereotype.Service;
import entities.ClassFeature;
import entities.DndClass;
import repositories.ClassFeatureRepository;
import repositories.DndClassRepository;

@Service
public class ClassFeatureService {

    private final ClassFeatureRepository classFeatureRepository;
    private final DndClassRepository dndClassRepository;

    public ClassFeatureService(ClassFeatureRepository classFeatureRepository,
                               DndClassRepository dndClassRepository) {
        this.classFeatureRepository = classFeatureRepository;
        this.dndClassRepository = dndClassRepository;
    }

    public List<ClassFeature> getFeaturesByClass(Long classId) {
        DndClass dndClass = dndClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));
        return classFeatureRepository.findByDndClass(dndClass);
    }

    public List<ClassFeature> getFeaturesByClassAndLevel(Long classId, int level) {
        DndClass dndClass = dndClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));
        return classFeatureRepository.findByDndClassAndLevel(dndClass, level);
    }

    public List<ClassFeature> getFeaturesUpToLevel(Long classId, int level) {
        DndClass dndClass = dndClassRepository.findById(classId)
                .orElseThrow(() -> new RuntimeException("Class not found"));
        return classFeatureRepository.findByDndClassAndLevelLessThanEqual(dndClass, level);
    }
}
