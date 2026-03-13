package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import entities.CharacterProficiency;
import entities.PlayerCharacter;
import entities.Proficiency;
import enumeration.ProficiencyType;

public interface CharacterProficiencyRepository extends JpaRepository<CharacterProficiency, Long> {
    
    List<CharacterProficiency> findByCharacter(PlayerCharacter character);

    List<CharacterProficiency> findByCharacterId(Long characterId);

    Optional<CharacterProficiency> findByCharacterAndProficiency(PlayerCharacter character, Proficiency proficiency);

    boolean existsByCharacterAndProficiency(PlayerCharacter character, Proficiency proficiency);

    @Query("SELECT cp FROM CharacterProficiency cp WHERE cp.character.id = :characterId AND cp.proficiency.type = :type")
    List<CharacterProficiency> findByCharacterIdAndType(@Param("characterId") Long characterId, @Param("type") ProficiencyType type);
    
    List<CharacterProficiency> findByCharacterIdAndSource(Long characterId, String source);
}
