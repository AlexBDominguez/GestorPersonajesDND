package repositories;

import entities.CharacterInventory;
import entities.PlayerCharacter;
import entities.Item;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CharacterInventoryRepository extends JpaRepository<CharacterInventory, Long> {
    
    List<CharacterInventory> findByCharacter(PlayerCharacter character);
    
    List<CharacterInventory> findByCharacterId(Long characterId);
    
    Optional<CharacterInventory> findByCharacterAndItem(PlayerCharacter character, Item item);
    
    boolean existsByCharacterAndItem(PlayerCharacter character, Item item);
    
    @Query("SELECT SUM(ci.item.weight * ci.quantity) FROM CharacterInventory ci WHERE ci.character.id = :characterId")
    Double calculateTotalWeight(@Param("characterId") Long characterId);
    
    List<CharacterInventory> findByCharacterIdAndAttuned(Long characterId, boolean attuned);
}