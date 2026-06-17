package repositories;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.ClassSpell;
import entities.DndClass;
import entities.Spell;

public interface ClassSpellRepository extends JpaRepository<ClassSpell, Long> {
    List<ClassSpell> findByDndClassAndRequiredLevelLessThanEqual(DndClass dndClass, int level);
    Optional<ClassSpell> findByDndClassAndSpell(DndClass dndClass, Spell spell);
}
