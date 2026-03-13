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

import dto.ConditionDto;
import services.ConditionService;

@RestController
@RequestMapping("/api/conditions")
public class ConditionController {

    private final ConditionService conditionService;

    public ConditionController(ConditionService conditionService) {
        this.conditionService = conditionService;
    }

    @GetMapping
    public ResponseEntity<List<ConditionDto>> getAll() {
        return ResponseEntity.ok(conditionService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ConditionDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(conditionService.getById(id));
    }

    @GetMapping("/search")
    public ResponseEntity<List<ConditionDto>> searchByName(@RequestParam String name) {
        return ResponseEntity.ok(conditionService.searchByName(name));
    }

    @PostMapping
    public ResponseEntity<ConditionDto> create(@RequestBody ConditionDto dto) {
        return ResponseEntity.ok(conditionService.create(dto));
    }

    
    
}
