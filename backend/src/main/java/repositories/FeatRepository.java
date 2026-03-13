package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Feat;

public interface FeatRepository extends JpaRepository<Feat, Long> {

    Optional<Feat> findByIndexName(String indexName);

    List<Feat> findByNameContainingIgnoreCase(String name);
    
}
