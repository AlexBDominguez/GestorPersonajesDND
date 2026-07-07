package repositories;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.NumericBonus;

public interface NumericBonusRepository extends JpaRepository<NumericBonus, Long> {
    Optional<NumericBonus> findByBonusKey(String bonusKey);
}
