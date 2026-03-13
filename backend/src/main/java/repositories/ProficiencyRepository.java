package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Proficiency;
import enumeration.ProficiencyType;

public interface ProficiencyRepository extends JpaRepository<Proficiency, Long>{

    Optional<Proficiency> findByIndexName(String indexName);

    List<Proficiency> findByType(ProficiencyType type);

    List<Proficiency> findByNameContainingIgnoreCase(String name);

    List<Proficiency> findByCategory(String category);
    
}
