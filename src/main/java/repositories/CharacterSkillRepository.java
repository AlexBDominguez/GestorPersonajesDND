package repositories;

import entities.CharacterSkill;
import entities.PlayerCharacter;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CharacterSkillRepository extends JpaRepository<CharacterSkill, Long> {
    
    List<CharacterSkill> findByCharacter(PlayerCharacter character);
    
    void deleteByCharacter(PlayerCharacter character);
}