public package repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import entities.CharacterSpell;

interface CharacterSpellRepository extends JpaRepository<CharacterSpell, Long> {

    List<CharacterSpell> findByCharacter(Long CharacterId);

    Optional<CharacterSpell> findByCharacterIdAndSpellId(Long characterId, Long spellId);
}

