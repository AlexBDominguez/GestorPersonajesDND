package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import entities.CharacterRaceResource;
import entities.PlayerCharacter;
import entities.RaceResource;

public interface CharacterRaceResourceRepository extends JpaRepository<CharacterRaceResource, Long> {

    List<CharacterRaceResource> findByCharacter(PlayerCharacter character);

    List<CharacterRaceResource> findByCharacterId(Long characterId);

    Optional<CharacterRaceResource> findByCharacterAndRaceResource(PlayerCharacter character, RaceResource raceResource);

    @Query("SELECT crr FROM CharacterRaceResource crr " +
           "WHERE crr.character.id = :characterId " +
           "AND (crr.raceResource.recoveryType = :recoveryType " +
           "     OR crr.raceResource.recoveryType = 'SHORT_OR_LONG_REST')")
    List<CharacterRaceResource> findByCharacterIdAndRecoveryType(
            @Param("characterId") Long characterId,
            @Param("recoveryType") String recoveryType);
}
