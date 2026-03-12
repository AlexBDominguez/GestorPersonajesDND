package repositories;

import entities.ActiveEffect;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;

public interface ActiveEffectRepository extends JpaRepository<ActiveEffect, Long> {
    
    Optional<ActiveEffect> findByIndexName(String indexName);
    
    List<ActiveEffect> findByNameContainingIgnoreCase(String name);
    
    List<ActiveEffect> findBySource(String source);
}