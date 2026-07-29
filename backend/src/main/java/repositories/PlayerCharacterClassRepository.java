package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.DndClass;
import entities.PlayerCharacter;
import entities.PlayerCharacterClass;

public interface PlayerCharacterClassRepository extends JpaRepository<PlayerCharacterClass, Long> {

    List<PlayerCharacterClass> findByCharacterOrderByClassOrderAsc(PlayerCharacter character);

    Optional<PlayerCharacterClass> findByCharacterAndDndClass(PlayerCharacter character, DndClass dndClass);

    long countByCharacter(PlayerCharacter character);

}
