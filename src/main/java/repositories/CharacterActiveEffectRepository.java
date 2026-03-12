package repositories;

import entities.CharacterActiveEffect;
import entities.PlayerCharacter;
import entities.ActiveEffect;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface CharacterActiveEffectRepository extends JpaRepository<CharacterActiveEffect, Long> {
    
    List<CharacterActiveEffect> findByCharacter(PlayerCharacter character);
    
    List<CharacterActiveEffect> findByCharacterId(Long characterId);
    
    List<CharacterActiveEffect> findByCharacterIdAndActive(Long characterId, boolean active);
    
    Optional<CharacterActiveEffect> findByCharacterAndEffectAndActive(
            PlayerCharacter character, ActiveEffect effect, boolean active);
    
    // Encontrar todos los efectos que requieren concentración activos
    List<CharacterActiveEffect> findByCharacterIdAndActiveAndEffect_RequiresConcentration(
            Long characterId, boolean active, boolean requiresConcentration);
}