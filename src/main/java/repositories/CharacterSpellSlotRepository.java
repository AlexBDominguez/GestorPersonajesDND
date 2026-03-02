package repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import entities.CharacterSpellSlot;

public interface CharacterSpellSlotRepository extends JpaRepository<CharacterSpellSlot, Long> {
    
    List<CharacterSpellSlot> findByCharacterId(Long characterId);

    CharacterSpellSlot findByCharacterIdAndSpellLevel(Long characterId, int spellLevel);

}