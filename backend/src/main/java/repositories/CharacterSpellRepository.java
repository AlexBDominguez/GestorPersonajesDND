package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import entities.CharacterSpell;
import entities.PlayerCharacter;

public interface CharacterSpellRepository extends JpaRepository<CharacterSpell, Long> {

    List<CharacterSpell> findByCharacter(PlayerCharacter character);

    Optional<CharacterSpell> findByCharacterIdAndSpellId(Long characterId, Long spellId);
}

