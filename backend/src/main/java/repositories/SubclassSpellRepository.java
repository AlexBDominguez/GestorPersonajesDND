package repositories;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.Subclass;
import entities.SubclassSpell;

public interface SubclassSpellRepository extends JpaRepository<SubclassSpell, Long> {
    List<SubclassSpell> findBySubclassAndRequiredLevelLessThanEqual(Subclass subclass, int level);
}
