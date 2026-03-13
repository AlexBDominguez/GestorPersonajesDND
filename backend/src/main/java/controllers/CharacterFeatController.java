package controllers;

import dto.CharacterFeatDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.CharacterFeatService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/characters/{characterId}/feats")
public class CharacterFeatController {

    private final CharacterFeatService characterFeatService;

    public CharacterFeatController(CharacterFeatService characterFeatService) {
        this.characterFeatService = characterFeatService;
    }

    @GetMapping
    public ResponseEntity<List<CharacterFeatDto>> getCharacterFeats(@PathVariable Long characterId) {
        return ResponseEntity.ok(characterFeatService.getCharacterFeats(characterId));
    }

    @PostMapping("/{featId}")
    public ResponseEntity<CharacterFeatDto> assignFeat(
            @PathVariable Long characterId,
            @PathVariable Long featId,
            @RequestBody(required = false) Map<String, String> body) {
        
        String notes = (body != null) ? body.get("notes") : null;
        return ResponseEntity.ok(characterFeatService.assignFeatToCharacter(characterId, featId, notes));
    }

    @DeleteMapping("/{featId}")
    public ResponseEntity<String> removeFeat(
            @PathVariable Long characterId,
            @PathVariable Long featId) {
        
        characterFeatService.removeFeatFromCharacter(characterId, featId);
        return ResponseEntity.ok("Feat removed successfully");
    }
}