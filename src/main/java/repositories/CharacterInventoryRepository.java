package repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import entities.CharacterInventory;
import entities.PlayerCharacter;

public interface CharacterInventoryRepository extends JpaRepository<entities.CharacterInventory, Long> {

    List<CharacterInventory> findByCharacter(PlayerCharacter character);
    
    List<CharacterInventory> findByCharacterAndEquipped(PlayerCharacter character, boolean equipped);

    List<CharacterInventory> findByCharacterAndAttuned(PlayerCharacter character, boolean attuned);

    @Query("SELECT SUM(ci.item.weight * ci.quantity) FROM CharacterInventory ci WHERE ci.character = :character")
    Double getTotalWeight(PlayerCharacter character);

}
