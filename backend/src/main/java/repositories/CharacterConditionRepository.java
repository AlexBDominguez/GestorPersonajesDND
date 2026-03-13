package repositories;

import entities.CharacterCondition;
import entities.PlayerCharacter;
import entities.Condition;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CharacterConditionRepository extends JpaRepository<CharacterCondition, Long> {
    
    List<CharacterCondition> findByCharacter(PlayerCharacter character);
    
    List<CharacterCondition> findByCharacterId(Long characterId);
    
    List<CharacterCondition> findByCharacterIdAndActive(Long characterId, boolean active);
    
    Optional<CharacterCondition> findByCharacterAndConditionAndActive(PlayerCharacter character, Condition condition, boolean active);
    
    boolean existsByCharacterAndConditionAndActive(PlayerCharacter character, Condition condition, boolean active);
}