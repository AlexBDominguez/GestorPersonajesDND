package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import entities.ClassFeature;
import entities.DndClass;

public interface ClassFeatureRepository extends JpaRepository<ClassFeature, Long> {
    
    //Buscar features de una clase específica
    List<ClassFeature> findByDndClass(DndClass dndClass);

    //Buscar features de una clase en un nivel específico
    List<ClassFeature> findByDndClassAndLevel(DndClass dndClass, int level);

    //Buscar por indexName (para evitar duplicados al sincronizar)
    Optional<ClassFeature> findByIndexName(String indexName);

    //Buscar todas las features hasta un nivel determinado
    List<ClassFeature> findByDndClassAndLevelLessThanEqual(DndClass dndClass, int level);

}
