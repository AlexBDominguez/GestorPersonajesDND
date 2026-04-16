package controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dto.SubraceDto;
import services.SubraceService;

@RestController
@RequestMapping("/api/subraces")
public class SubraceController {
    
    private final SubraceService subraceService;

    public SubraceController(SubraceService subraceService) {
        this.subraceService = subraceService;
    }

    //Get /api/subraces/races/{raceId} -> subrazas de una raza concreta
    @GetMapping("/race/{raceId}")
    public ResponseEntity<List<SubraceDto>> getByRace(@PathVariable Long raceId) {
        return ResponseEntity.ok(subraceService.getByRaceId(raceId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<SubraceDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(subraceService.getById(id));
    }

    @PostMapping
    public ResponseEntity<SubraceDto> create(@RequestBody SubraceDto dto) {
        return ResponseEntity.ok(subraceService.create(dto));
    }


}
