package controllers;

import dto.DamageTypeDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.DamageTypeService;

import java.util.List;

@RestController
@RequestMapping("/api/damage-types")
public class DamageTypeController {

    private final DamageTypeService damageTypeService;

    public DamageTypeController(DamageTypeService damageTypeService) {
        this.damageTypeService = damageTypeService;
    }

    @GetMapping
    public ResponseEntity<List<DamageTypeDto>> getAll() {
        return ResponseEntity.ok(damageTypeService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<DamageTypeDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(damageTypeService.getById(id));
    }

    @GetMapping("/search")
    public ResponseEntity<List<DamageTypeDto>> searchByName(@RequestParam String name) {
        return ResponseEntity.ok(damageTypeService.searchByName(name));
    }

    @PostMapping
    public ResponseEntity<DamageTypeDto> create(@RequestBody DamageTypeDto dto) {
        return ResponseEntity.ok(damageTypeService.create(dto));
    }
}