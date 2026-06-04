package repositories;

import entities.ContentSource;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ContentSourceRepository extends JpaRepository<ContentSource, Long> {
    Optional<ContentSource> findByShortName(String shortName);
    List<ContentSource> findAllByOrderByIsBaseDescShortNameAsc();
    boolean existsByShortName(String shortName);
}
