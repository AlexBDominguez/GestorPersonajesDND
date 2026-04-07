package repositories;

import entities.Spell;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;

public interface SpellRepository extends JpaRepository<Spell, Long> {

    Optional<Spell> findByIndexApi(String indexApi);

    List<Spell> findByLevel(int level);

    List<Spell> findByNameContainingIgnoreCase(String name);

    List<Spell> findByLevelLessThanEqual(int maxLevel);

    List<Spell> findByCastingTimeContainingIgnoreCase(String castingTime);
}
