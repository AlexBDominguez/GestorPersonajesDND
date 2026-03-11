
package repositories;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

import entities.Condition;


public interface ConditionRepository extends JpaRepository<Condition, Long> {
    
    Optional<Condition> findByIndexName(String indexName);

    List<Condition> findByNameContainingIgnoreCase(String name);

    
    
}