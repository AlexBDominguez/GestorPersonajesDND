package repositories;

import entities.CharacterMoney;
import entities.PlayerCharacter;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CharacterMoneyRepository extends JpaRepository<CharacterMoney, Long> {
    
    Optional<CharacterMoney> findByCharacter(PlayerCharacter character);
    
    Optional<CharacterMoney> findByCharacterId(Long characterId);
}