package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Language;

public interface LanguageRepository extends JpaRepository<Language, Long> {

    Optional<Language> findByIndexName(String indexName);

    List<Language> findByType(String type);

    List<Language> findByNameContainingIgnoreCase(String name);
        
}
