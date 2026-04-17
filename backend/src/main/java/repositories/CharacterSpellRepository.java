package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import entities.CharacterSpell;
import entities.PlayerCharacter;

public interface CharacterSpellRepository extends JpaRepository<CharacterSpell, Long> {

    List<CharacterSpell> findByCharacter(PlayerCharacter character);

    Optional<CharacterSpell> findByCharacterIdAndSpellId(Long characterId, Long spellId);

    @Query("SELECT COUNT(cs) FROM CharacterSpell cs WHERE cs.character.id = :characterId AND cs.prepared = true AND cs.spell.level > 0")
    int countPreparedNonCantripsByCharacterId(@Param("characterId") Long characterId);
}

