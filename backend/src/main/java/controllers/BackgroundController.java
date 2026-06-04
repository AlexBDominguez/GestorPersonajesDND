package controllers;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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
    
}
