package repositories;

import entities.DndClass;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DndClassRepository extends JpaRepository<DndClass, Long> {
    Optional<DndClass> findByIndexName(String indexName);
    List<DndClass> findBySourceIn(List<String> sources);
}
