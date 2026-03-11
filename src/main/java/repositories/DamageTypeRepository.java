package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.DamageType;

public interface DamageTypeRepository extends JpaRepository<DamageType, Long> {
   
    Optional<DamageType> findByIndexName(String indexName);

    List<DamageType> findByNameContainingIgnoreCase(String name);
    
}
