package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Race;
import entities.RaceResource;

public interface RaceResourceRepository extends JpaRepository<RaceResource, Long> {

    Optional<RaceResource> findByIndexName(String indexName);

    List<RaceResource> findByRace(Race race);
}
