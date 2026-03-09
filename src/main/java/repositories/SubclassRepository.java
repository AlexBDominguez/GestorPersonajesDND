package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.DndClass;
import entities.Subclass;

public interface SubclassRepository extends JpaRepository<Subclass, Long> {

    Optional<Subclass> findByIndexName(String indexName);

    List<Subclass> findByDndClass(DndClass dndClass);

} 

