package controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import dto.LanguageDto;
import services.LanguageService;

@RestController
@RequestMapping("/api/languages")
public class LanguageController {
    
    private final LanguageService languageService;

    public LanguageController(LanguageService languageService) {
        this.languageService = languageService;
    }

    @GetMapping
    public ResponseEntity<List<LanguageDto>> getAll() {
        return ResponseEntity.ok(languageService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<LanguageDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(languageService.getById(id));
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<List<LanguageDto>> getByType(@PathVariable String type) {
        return ResponseEntity.ok(languageService.getByType(type));
    }

    @GetMapping("/search")
    public ResponseEntity<List<LanguageDto>> searchByName(@RequestParam String name) {
        return ResponseEntity.ok(languageService.searchByName(name));
    }

    @PostMapping
    public ResponseEntity<LanguageDto> create(@RequestBody LanguageDto dto) {
        return ResponseEntity.ok(languageService.create(dto));
    }

}
