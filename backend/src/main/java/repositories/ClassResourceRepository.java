package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.ClassResource;
import entities.DndClass;

public interface ClassResourceRepository  extends JpaRepository<ClassResource, Long> {

    Optional<ClassResource> findByIndexName(String indexName);

    List<ClassResource> findByDndClass(DndClass dndClass);

    List<ClassResource> findByDndClassAndLevelUnlockedLessThanEqual(DndClass dndClass, int level);
    
    
}
