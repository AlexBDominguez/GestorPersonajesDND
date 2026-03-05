package repositories;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.CharacterSavingThrow;
import entities.PlayerCharacter;

public interface CharacterSavingThrowRepository extends JpaRepository<CharacterSavingThrow, Long>{
    
    List<CharacterSavingThrow> findByCharacter(PlayerCharacter character);

    void deleteByCharacter(PlayerCharacter character);

}
