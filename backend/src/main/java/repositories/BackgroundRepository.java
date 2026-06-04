package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Background;

public interface BackgroundRepository extends JpaRepository<Background, Long> {
    Optional<Background> findByIndexName(String indexName);
    List<Background> findBySourceIn(List<String> sources);
}
