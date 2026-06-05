package repositories;

import entities.Race;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RaceRepository extends JpaRepository<Race, Long> {
    Optional<Race> findByIndexName(String indexName);
    List<Race> findByName(String name);
    List<Race> findBySourceIn(List<String> sources);
}
