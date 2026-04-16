package repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.Subrace;

public interface SubraceRepository extends JpaRepository<Subrace, Long> {
    List<Subrace> findByRaceId(Long raceId);

}
