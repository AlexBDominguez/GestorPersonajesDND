package repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.ClassLevelProgression;
import entities.DndClass;

public interface ClassLevelProgressionRepository extends JpaRepository<ClassLevelProgression, Long> {
    
    Optional<ClassLevelProgression> findByDndClassAndLevel(DndClass dndClass, int level);
    
}
