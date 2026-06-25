package repositories;

import entities.DndClass;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface DndClassRepository extends JpaRepository<DndClass, Long> {
    Optional<DndClass> findByIndexName(String indexName);
    Optional<DndClass> findByNameIgnoreCase(String name);
    Optional<DndClass> findFirstByNameStartingWithIgnoreCase(String prefix);
    List<DndClass> findBySourceIn(List<String> sources);

    /** Vincula una clase con un hechizo en class_spells. Idempotente (PK compuesta class_id+spell_id). */
    @Modifying
    @Query(value = "INSERT IGNORE INTO class_spells (class_id, spell_id, required_level, dnd_class_id) " +
                    "VALUES (:classId, :spellId, 0, 0)", nativeQuery = true)
    void linkSpell(@Param("classId") Long classId, @Param("spellId") Long spellId);
}
