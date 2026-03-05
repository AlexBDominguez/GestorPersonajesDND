package repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.ClassLevelFeature;
import entities.ClassLevelProgression;

public interface ClassLevelFeatureRepository extends JpaRepository<ClassLevelFeature, Long> {

    List<ClassLevelFeature> findByProgression(ClassLevelProgression progression);

    void deleteByProgression(ClassLevelProgression progression);
    
}
