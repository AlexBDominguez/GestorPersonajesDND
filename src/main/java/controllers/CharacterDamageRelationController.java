package controllers;

import dto.CharacterDamageRelationDto;
import enumeration.DamageRelationType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.CharacterDamageRelationService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/characters/{characterId}/damage-relations")
public class CharacterDamageRelationController {

    private final CharacterDamageRelationService characterDamageRelationService;

    public CharacterDamageRelationController(CharacterDamageRelationService characterDamageRelationService) {
        this.characterDamageRelationService = characterDamageRelationService;
    }

    @GetMapping
    public ResponseEntity<List<CharacterDamageRelationDto>> getCharacterDamageRelations(
            @PathVariable Long characterId) {
        return ResponseEntity.ok(characterDamageRelationService.getCharacterDamageRelations(characterId));
    }

    @GetMapping("/type/{relationType}")
    public ResponseEntity<List<CharacterDamageRelationDto>> getCharacterDamageRelationsByType(
            @PathVariable Long characterId,
            @PathVariable DamageRelationType relationType) {
        return ResponseEntity.ok(characterDamageRelationService.getCharacterDamageRelationsByType(
                characterId, relationType));
    }

    @PostMapping("/{damageTypeId}")
    public ResponseEntity<CharacterDamageRelationDto> addDamageRelation(
            @PathVariable Long characterId,
            @PathVariable Long damageTypeId,
            @RequestBody Map<String, Object> body) {
        
        String relationTypeStr = (String) body.get("relationType");
        if (relationTypeStr == null) {
            throw new RuntimeException("relationType is required (RESISTANCE, IMMUNITY, or VULNERABILITY)");
        }
        
        DamageRelationType relationType = DamageRelationType.valueOf(relationTypeStr.toUpperCase());
        
        String source = (String) body.getOrDefault("source", "Manual");
        boolean temporary = (boolean) body.getOrDefault("temporary", false);
        String conditions = (String) body.get("conditions");
        String notes = (String) body.get("notes");
        
        return ResponseEntity.ok(characterDamageRelationService.addDamageRelationToCharacter(
                characterId, damageTypeId, relationType, source, temporary, conditions, notes));
    }

    @DeleteMapping("/{damageTypeId}/{relationType}")
    public ResponseEntity<String> removeDamageRelation(
            @PathVariable Long characterId,
            @PathVariable Long damageTypeId,
            @PathVariable DamageRelationType relationType) {
        
        characterDamageRelationService.removeDamageRelationFromCharacter(
                characterId, damageTypeId, relationType);
        return ResponseEntity.ok("Damage relation removed successfully");
    }

    @DeleteMapping("/temporary")
    public ResponseEntity<String> removeAllTemporaryRelations(@PathVariable Long characterId) {
        characterDamageRelationService.removeAllTemporaryRelations(characterId);
        return ResponseEntity.ok("All temporary damage relations removed successfully");
    }
}