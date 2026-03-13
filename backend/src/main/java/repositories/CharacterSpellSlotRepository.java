package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import entities.CharacterSpellSlot;
import entities.PlayerCharacter;

public interface CharacterSpellSlotRepository extends JpaRepository<CharacterSpellSlot, Long> {
    
    List<CharacterSpellSlot> findByCharacter(PlayerCharacter character);

    List<CharacterSpellSlot> findByCharacterId(Long characterId);

    Optional<CharacterSpellSlot> findByCharacterAndSpellLevel(PlayerCharacter character, int spellLevel);

    @Query("SELECT c FROM CharacterSpellSlot c WHERE c.character.id = :characterId AND c.spellLevel = :spellLevel")
    Optional<CharacterSpellSlot> findByCharacterIdAndSpellLevel(@Param("characterId") Long characterId, @Param("spellLevel") int spellLevel);
}
