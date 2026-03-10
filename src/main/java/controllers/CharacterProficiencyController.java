package controllers;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dto.CharacterProficiencyDto;
import enumeration.ProficiencyType;
import services.CharacterProficiencyService;

@RestController
@RequestMapping("/api/characters/{characterId}/proficiencies")
public class CharacterProficiencyController {

    private final CharacterProficiencyService characterProficiencyService;

    public CharacterProficiencyController(CharacterProficiencyService characterProficiencyService) {
        this.characterProficiencyService = characterProficiencyService;
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<List<CharacterProficiencyDto>> getCharacterProficienciesByType(
            @PathVariable Long characterId,
            @PathVariable ProficiencyType type) {
        return ResponseEntity.ok(characterProficiencyService.getCharacterProficienciesByType(characterId, type));
    }

    @PostMapping("/{proficiencyId}")
    public ResponseEntity<CharacterProficiencyDto> assignProficiency(
            @PathVariable Long characterId,
            @PathVariable Long proficiencyId,
            @RequestBody(required = false) Map<String, String> body) {
        
        String source = (body != null) ? body.get("source") : "Manual";
        String notes = (body != null) ? body.get("notes") : null;
        
        return ResponseEntity.ok(characterProficiencyService.assignProficiencyToCharacter(
                characterId, proficiencyId, source, notes));
    }

    @DeleteMapping("/{proficiencyId}")
    public ResponseEntity<String> removeProficiency(
            @PathVariable Long characterId,
            @PathVariable Long proficiencyId) {

        characterProficiencyService.removeProficiencyFromCharacter(characterId, proficiencyId);
        return ResponseEntity.ok("Proficiency removed successfully");
    }
}