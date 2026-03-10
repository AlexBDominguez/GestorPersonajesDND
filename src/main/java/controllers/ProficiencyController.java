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

import dto.ProficiencyDto;
import enumeration.ProficiencyType;
import services.ProficiencyService;

@RestController
@RequestMapping("/api/proficiencies")
public class ProficiencyController {

    private final ProficiencyService proficiencyService;

    public ProficiencyController(ProficiencyService proficiencyService) {
        this.proficiencyService = proficiencyService;
    }

    @GetMapping
    public ResponseEntity<List<ProficiencyDto>> getAll() {
        return ResponseEntity.ok(proficiencyService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProficiencyDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(proficiencyService.getById(id));
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<List<ProficiencyDto>> getByType(@PathVariable ProficiencyType type) {
        return ResponseEntity.ok(proficiencyService.getByType(type));
    }

    @GetMapping("/search")
    public ResponseEntity<List<ProficiencyDto>> searchByName(@RequestParam String name) {
        return ResponseEntity.ok(proficiencyService.searchByName(name));
    }

    @PostMapping
    public ResponseEntity<ProficiencyDto> create(@RequestBody ProficiencyDto dto) {
        return ResponseEntity.ok(proficiencyService.create(dto));
    }

}
