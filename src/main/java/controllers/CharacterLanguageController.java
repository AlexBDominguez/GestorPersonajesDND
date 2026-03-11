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

import dto.CharacterLanguageDto;
import services.CharacterLanguageService;

@RestController
@RequestMapping("/api/characters/{characterId}/languages")
public class CharacterLanguageController {

    private final CharacterLanguageService characterLanguageService;

    public CharacterLanguageController(CharacterLanguageService characterLanguageService) {
        this.characterLanguageService = characterLanguageService;
    }

    @GetMapping
    public ResponseEntity<List<CharacterLanguageDto>> getCharacterLAnguages(@PathVariable Long characterId) {
        return ResponseEntity.ok(characterLanguageService.getCharacterLanguages(characterId));
    }

    @PostMapping("/{languageId}")
    public ResponseEntity<CharacterLanguageDto> assignLanguage(
            @PathVariable Long characterId,
            @PathVariable Long languageId,
            @RequestBody(required = false) Map<String, String> body){

        String source = body != null ? body.get("source") : "Manual";
        String notes = body != null ? body.get("notes") : null;

        return ResponseEntity.ok(characterLanguageService.assignLanguageToCharacter(characterId, languageId, source, notes));
    }

    @DeleteMapping("/{languageId}")
    public ResponseEntity<String> removeLanguage(
            @PathVariable Long characterId,
            @PathVariable Long languageId) {
        characterLanguageService.removeLanguageFromCharacter(characterId, languageId);
        return ResponseEntity.ok("Language removed from character");
    }
   
}
