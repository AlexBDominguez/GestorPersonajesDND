package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import entities.CharacterLanguage;
import entities.Language;
import entities.PlayerCharacter;

public interface CharacterLanguageRepository extends JpaRepository<CharacterLanguage, Long> {

    List<CharacterLanguage> findByCharacter(PlayerCharacter character);

    List<CharacterLanguage> findByCharacterId(Long characterId);

    Optional<CharacterLanguage> findByCharacterAndLanguage(PlayerCharacter character, Language language);

    boolean existsByCharacterAndLanguage(PlayerCharacter character, Language language);

    List<CharacterLanguage> findByCharacterIdAndSource(Long characterId, String source);
    

}
