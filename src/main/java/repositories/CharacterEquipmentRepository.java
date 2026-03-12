package repositories;

import entities.CharacterEquipment;
import entities.PlayerCharacter;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CharacterEquipmentRepository extends JpaRepository<CharacterEquipment, Long> {
    
    Optional<CharacterEquipment> findByCharacter(PlayerCharacter character);
    
    Optional<CharacterEquipment> findByCharacterId(Long characterId);
}