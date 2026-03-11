package repositories;

import entities.CharacterDamageRelation;
import entities.PlayerCharacter;
import entities.DamageType;
import enumeration.DamageRelationType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CharacterDamageRelationRepository extends JpaRepository<CharacterDamageRelation, Long> {
    
    List<CharacterDamageRelation> findByCharacter(PlayerCharacter character);
    
    List<CharacterDamageRelation> findByCharacterId(Long characterId);
    
    @Query("SELECT cdr FROM CharacterDamageRelation cdr WHERE cdr.character.id = :characterId AND cdr.relationType = :relationType")
    List<CharacterDamageRelation> findByCharacterIdAndRelationType(
            @Param("characterId") Long characterId, 
            @Param("relationType") DamageRelationType relationType);
    
    Optional<CharacterDamageRelation> findByCharacterAndDamageTypeAndRelationType(
            PlayerCharacter character, DamageType damageType, DamageRelationType relationType);
    
    boolean existsByCharacterAndDamageTypeAndRelationType(
            PlayerCharacter character, DamageType damageType, DamageRelationType relationType);
    
    List<CharacterDamageRelation> findByCharacterIdAndTemporary(Long characterId, boolean temporary);
}