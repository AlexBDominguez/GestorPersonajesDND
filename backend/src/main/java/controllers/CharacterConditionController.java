package controllers;

import dto.CharacterConditionDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.CharacterConditionService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/characters/{characterId}/conditions")
public class CharacterConditionController {

    private final CharacterConditionService characterConditionService;

    public CharacterConditionController(CharacterConditionService characterConditionService) {
        this.characterConditionService = characterConditionService;
    }

    @GetMapping
    public ResponseEntity<List<CharacterConditionDto>> getCharacterConditions(
            @PathVariable Long characterId,
            @RequestParam(required = false) Boolean activeOnly) {
        return ResponseEntity.ok(characterConditionService.getCharacterConditions(characterId, activeOnly));
    }

    @PostMapping("/{conditionId}")
    public ResponseEntity<CharacterConditionDto> applyCondition(
            @PathVariable Long characterId,
            @PathVariable Long conditionId,
            @RequestBody(required = false) Map<String, Object> body) {
        
        String source = (body != null && body.containsKey("source")) 
                ? (String) body.get("source") : "Manual";
        
        Integer durationRounds = (body != null && body.containsKey("durationRounds")) 
                ? (Integer) body.get("durationRounds") : null;
        
        boolean hasSavingThrow = (body != null && body.containsKey("hasSavingThrow")) 
                ? (Boolean) body.get("hasSavingThrow") : false;
        
        Integer savingThrowDC = (body != null && body.containsKey("savingThrowDC")) 
                ? (Integer) body.get("savingThrowDC") : null;
        
        String savingThrowAbility = (body != null && body.containsKey("savingThrowAbility")) 
                ? (String) body.get("savingThrowAbility") : null;
        
        String notes = (body != null && body.containsKey("notes")) 
                ? (String) body.get("notes") : null;
        
        return ResponseEntity.ok(characterConditionService.applyConditionToCharacter(
                characterId, conditionId, source, durationRounds, 
                hasSavingThrow, savingThrowDC, savingThrowAbility, notes));
    }

    @PatchMapping("/{conditionInstanceId}/rounds")
    public ResponseEntity<CharacterConditionDto> updateRemainingRounds(
            @PathVariable Long characterId,
            @PathVariable Long conditionInstanceId,
            @RequestBody Map<String, Integer> body) {
        
        Integer remainingRounds = body.get("remainingRounds");
        if (remainingRounds == null) {
            throw new RuntimeException("remainingRounds is required");
        }
        
        return ResponseEntity.ok(characterConditionService.updateRemainingRounds(
                conditionInstanceId, remainingRounds));
    }

    @PostMapping("/decrement-all")
    public ResponseEntity<String> decrementAllConditionRounds(@PathVariable Long characterId) {
        characterConditionService.decrementAllConditionRounds(characterId);
        return ResponseEntity.ok("All condition rounds decremented successfully");
    }

    @DeleteMapping("/{conditionId}")
    public ResponseEntity<String> removeCondition(
            @PathVariable Long characterId,
            @PathVariable Long conditionId) {
        
        characterConditionService.removeConditionFromCharacter(characterId, conditionId);
        return ResponseEntity.ok("Condition removed successfully");
    }
}