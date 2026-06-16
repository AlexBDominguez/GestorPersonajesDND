package repositories;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.Spell;
import entities.Subclass;
import entities.SubclassSpell;

public interface SubclassSpellRepository extends JpaRepository<SubclassSpell, Long> {
    List<SubclassSpell> findBySubclassAndRequiredLevelLessThanEqual(Subclass subclass, int level);
    Optional<SubclassSpell> findBySubclassAndSpell(Subclass subclass, Spell spell);
}
