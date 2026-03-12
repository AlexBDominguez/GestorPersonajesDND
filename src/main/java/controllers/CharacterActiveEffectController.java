package controllers;

import dto.CharacterActiveEffectDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.CharacterActiveEffectService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/characters/{characterId}/effects")
public class CharacterActiveEffectController {

    private final CharacterActiveEffectService characterActiveEffectService;

    public CharacterActiveEffectController(CharacterActiveEffectService characterActiveEffectService) {
        this.characterActiveEffectService = characterActiveEffectService;
    }

    @GetMapping
    public ResponseEntity<List<CharacterActiveEffectDto>> getCharacterEffects(
            @PathVariable Long characterId,
            @RequestParam(required = false) Boolean activeOnly) {
        return ResponseEntity.ok(characterActiveEffectService.getCharacterEffects(characterId, activeOnly));
    }

    @PostMapping("/{effectId}")
    public ResponseEntity<CharacterActiveEffectDto> applyEffect(
            @PathVariable Long characterId,
            @PathVariable Long effectId,
            @RequestBody(required = false) Map<String, Object> body) {
        
        Integer remainingRounds = (body != null && body.containsKey("remainingRounds")) 
                ? (Integer) body.get("remainingRounds") : null;
        
        Integer casterLevel = (body != null && body.containsKey("casterLevel")) 
                ? (Integer) body.get("casterLevel") : null;
        
        String notes = (body != null && body.containsKey("notes")) 
                ? (String) body.get("notes") : null;
        
        return ResponseEntity.ok(characterActiveEffectService.applyEffect(
                characterId, effectId, remainingRounds, casterLevel, notes));
    }

    @PostMapping("/{effectInstanceId}/toggle")
    public ResponseEntity<CharacterActiveEffectDto> toggleEffect(
            @PathVariable Long characterId,
            @PathVariable Long effectInstanceId) {
        
        return ResponseEntity.ok(characterActiveEffectService.toggleEffect(effectInstanceId));
    }

    @PatchMapping("/{effectInstanceId}/rounds")
    public ResponseEntity<CharacterActiveEffectDto> updateRemainingRounds(
            @PathVariable Long characterId,
            @PathVariable Long effectInstanceId,
            @RequestBody Map<String, Integer> body) {
        
        Integer remainingRounds = body.get("remainingRounds");
        if (remainingRounds == null) {
            throw new RuntimeException("remainingRounds is required");
        }
        
        return ResponseEntity.ok(characterActiveEffectService.updateRemainingRounds(
                effectInstanceId, remainingRounds));
    }

    @PostMapping("/decrement-all")
    public ResponseEntity<String> decrementAllEffectRounds(@PathVariable Long characterId) {
        characterActiveEffectService.decrementAllEffectRounds(characterId);
        return ResponseEntity.ok("All effect rounds decremented successfully");
    }

    @DeleteMapping("/{effectId}")
    public ResponseEntity<String> removeEffect(
            @PathVariable Long characterId,
            @PathVariable Long effectId) {
        
        characterActiveEffectService.removeEffect(characterId, effectId);
        return ResponseEntity.ok("Effect removed successfully");
    }

    @DeleteMapping("/remove-all")
    public ResponseEntity<String> removeAllEffects(@PathVariable Long characterId) {
        characterActiveEffectService.removeAllEffects(characterId);
        return ResponseEntity.ok("All effects removed successfully");
    }
}