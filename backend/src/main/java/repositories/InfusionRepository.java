package repositories;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import entities.Infusion;

public interface InfusionRepository extends JpaRepository<Infusion, Long> {
    Optional<Infusion> findByIndexName(String indexName);
}
