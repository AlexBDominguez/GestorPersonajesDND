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

import dto.CharacterClassResourceDto;
import services.CharacterClassResourceService;

@RestController
@RequestMapping("/api/characters/{characterId}/resources")
public class CharacterClassResourceController {
    
    private final CharacterClassResourceService characterClassResourceService;

    public CharacterClassResourceController(CharacterClassResourceService characterClassResourceService) {
        this.characterClassResourceService = characterClassResourceService;
    }
    
    @GetMapping
    public ResponseEntity<List<CharacterClassResourceDto>> getCharacterResources(@PathVariable Long characterId) {
        return ResponseEntity.ok(characterClassResourceService.getCharacterResourcesDto(characterId));
    }

    @PostMapping("/initialize")
    public ResponseEntity<String> initializeResources(@PathVariable Long characterId) {
        characterClassResourceService.initializeClassResourcesForCharacter(characterId);
        return ResponseEntity.ok("Class resources initialized for character");
    }

    @PostMapping("/spend")
    public ResponseEntity<CharacterClassResourceDto> spendResource(
            @PathVariable Long characterId,
            @RequestBody Map<String, Object> body) {
        
        String resourceIndexName = (String) body.get("resourceIndexName");
        Integer amount = (Integer) body.get("amount");
        
        if (resourceIndexName == null || amount == null) {
            throw new RuntimeException("resourceIndexName and amount are required");
        }
        
        return ResponseEntity.ok(characterClassResourceService.spendResourceDto(
                characterId, resourceIndexName, amount));
    }

    @PostMapping("/recover")
    public ResponseEntity<CharacterClassResourceDto> recoverResource(
            @PathVariable Long characterId,
            @RequestBody Map<String, Object> body) {

        String resourceIndexName = (String) body.get("resourceIndexName");
        Integer amount = (Integer) body.get("amount");

        if(resourceIndexName == null || amount == null) {
            throw new RuntimeException("resourceIndexName and amount are required");
        }

        return ResponseEntity.ok(characterClassResourceService.recoverResourceDto(
                characterId, resourceIndexName, amount));
    }

    @PostMapping("/update-maximums")
    public ResponseEntity<String> updateResourceMaximums(@PathVariable Long characterId) {
        characterClassResourceService.updateResourceMaximums(characterId);
        return ResponseEntity.ok("Resource maximums updated");
    }
}
