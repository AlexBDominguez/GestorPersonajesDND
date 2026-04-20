package repositories;

import entities.RacialTrait;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface RacialTraitRepository extends JpaRepository<RacialTrait, Long> {
    Optional<RacialTrait> findByIndexName(String indexName);
}