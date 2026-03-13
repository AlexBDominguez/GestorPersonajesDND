package repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.CharacterFeature;
import entities.PlayerCharacter;

public interface CharacterFeatureRepository extends JpaRepository<CharacterFeature, Long> {
    
    List<CharacterFeature> findByCharacter(PlayerCharacter character);
    
    List<CharacterFeature> findByCharacterAndLevelObtained(PlayerCharacter character, int levelObtained);
}
