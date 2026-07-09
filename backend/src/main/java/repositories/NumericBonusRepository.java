package repositories;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.NumericBonus;

public interface NumericBonusRepository extends JpaRepository<NumericBonus, Long> {
    Optional<NumericBonus> findByBonusKey(String bonusKey);

    // Para bonos no atados a una fila de ClassFeature/SubclassFeature (elegidos entre varias
    // opciones, p.ej. Fighting Style) -- se escanean todos los de un targetField y se filtra por
    // condición en vez de por activeBonusKeys(). Ver NumericBonusService.fightingStyleBonusFor().
    List<NumericBonus> findByTargetField(String targetField);
}
