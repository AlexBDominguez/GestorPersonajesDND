package repositories;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.RacialTrait;
import entities.RacialTraitSpell;
import entities.Spell;

public interface RacialTraitSpellRepository extends JpaRepository<RacialTraitSpell, Long> {
    List<RacialTraitSpell> findByRacialTraitInAndRequiredLevelLessThanEqual(List<RacialTrait> racialTraits, int level);
    boolean existsByRacialTraitAndSpell(RacialTrait racialTrait, Spell spell);
}
