package repositories;


import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import entities.CharacterClassResource;
import entities.ClassResource;
import entities.PlayerCharacter;

public interface CharacterClassResourceRepository extends JpaRepository<CharacterClassResource, Long> {

    List<CharacterClassResource> findByCharacter(PlayerCharacter character);

    List<CharacterClassResource> findByCharacterId(Long characterId);

    Optional<CharacterClassResource> findByCharacterAndClassResource(PlayerCharacter character, ClassResource classResource);

    // Los recursos con recoveryType = SHORT_OR_LONG_REST se recuperan tanto en descanso corto
    // como largo, así que siempre coinciden además de la coincidencia exacta pedida.
    @Query("SELECT ccr FROM CharacterClassResource ccr " +
           "WHERE ccr.character.id = :characterId " +
           "AND (ccr.classResource.recoveryType = :recoveryType " +
           "     OR ccr.classResource.recoveryType = 'SHORT_OR_LONG_REST')")
    List<CharacterClassResource> findByCharacterIdAndRecoveryType(
            @Param("characterId") Long characterId,
            @Param("recoveryType") String recoveryType);
    

    
}
