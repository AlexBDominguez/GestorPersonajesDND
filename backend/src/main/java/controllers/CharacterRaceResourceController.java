package controllers;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dto.CharacterRaceResourceDto;
import services.CharacterRaceResourceService;

/** Mirrors CharacterClassResourceController, for RaceResource instead of ClassResource. See #9. */
@RestController
@RequestMapping("/api/characters/{characterId}/race-resources")
public class CharacterRaceResourceController {

    private final CharacterRaceResourceService characterRaceResourceService;

    public CharacterRaceResourceController(CharacterRaceResourceService characterRaceResourceService) {
        this.characterRaceResourceService = characterRaceResourceService;
    }

    @GetMapping
    public ResponseEntity<List<CharacterRaceResourceDto>> getCharacterResources(@PathVariable Long characterId) {
        return ResponseEntity.ok(characterRaceResourceService.getCharacterResourcesDto(characterId));
    }

    @PostMapping("/initialize")
    public ResponseEntity<String> initializeResources(@PathVariable Long characterId) {
        characterRaceResourceService.initializeRaceResourcesForCharacter(characterId);
        return ResponseEntity.ok("Race resources initialized for character");
    }

    @PostMapping("/spend")
    public ResponseEntity<CharacterRaceResourceDto> spendResource(
            @PathVariable Long characterId,
            @RequestBody Map<String, Object> body) {
        String resourceIndexName = (String) body.get("resourceIndexName");
        Integer amount = (Integer) body.get("amount");
        if (resourceIndexName == null || amount == null) {
            throw new RuntimeException("resourceIndexName and amount are required");
        }
        return ResponseEntity.ok(characterRaceResourceService.spendResourceDto(characterId, resourceIndexName, amount));
    }

    @PostMapping("/recover")
    public ResponseEntity<CharacterRaceResourceDto> recoverResource(
            @PathVariable Long characterId,
            @RequestBody Map<String, Object> body) {
        String resourceIndexName = (String) body.get("resourceIndexName");
        Integer amount = (Integer) body.get("amount");
        if (resourceIndexName == null || amount == null) {
            throw new RuntimeException("resourceIndexName and amount are required");
        }
        return ResponseEntity.ok(characterRaceResourceService.recoverResourceDto(characterId, resourceIndexName, amount));
    }

    @PostMapping("/update-maximums")
    public ResponseEntity<String> updateResourceMaximums(@PathVariable Long characterId) {
        characterRaceResourceService.updateResourceMaximums(characterId);
        return ResponseEntity.ok("Resource maximums updated");
    }
}
