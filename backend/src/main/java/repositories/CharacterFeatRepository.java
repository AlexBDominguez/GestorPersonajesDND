package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.CharacterFeat;
import entities.Feat;
import entities.PlayerCharacter;

public interface CharacterFeatRepository extends JpaRepository<CharacterFeat, Long> {
    
    List<CharacterFeat> findByCharacter(PlayerCharacter character);

    List<CharacterFeat> findByCharacterId(Long characterId);

    Optional<CharacterFeat> findByCharacterAndFeat(PlayerCharacter character, Feat feat);

    boolean existsByCharacterAndFeat(PlayerCharacter character, Feat feat);

    
}
