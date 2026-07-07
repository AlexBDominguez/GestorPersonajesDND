package repositories;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.RacialTrait;
import entities.RacialTraitProficiency;

public interface RacialTraitProficiencyRepository extends JpaRepository<RacialTraitProficiency, Long> {
    List<RacialTraitProficiency> findByRacialTraitIn(List<RacialTrait> racialTraits);
}
