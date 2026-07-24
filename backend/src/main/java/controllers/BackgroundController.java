package controllers;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import dto.BackgroundDto;

import services.BackgroundService;

@RestController
@RequestMapping("/api/backgrounds")
public class BackgroundController {

    private final BackgroundService backgroundService;

    public BackgroundController(BackgroundService backgroundService) {
        this.backgroundService = backgroundService;
    }

    @GetMapping
    public List<BackgroundDto> getAll(
            @RequestParam(required = false) List<String> sources) {
        return backgroundService.getAll(sources);
    }

    @GetMapping("/{id}")
    public BackgroundDto getById(@PathVariable Long id) {
        return backgroundService.getById(id);
    }

    // #9: creación manual de backgrounds homebrew desde el panel de admin.
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> create(@RequestBody BackgroundDto dto) {
        try {
            return ResponseEntity.ok(backgroundService.create(dto));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

}
