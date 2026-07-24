package controllers;


import dto.RaceDto;
import dto.RacialTraitAdminRequest;
import dto.RacialTraitDto;
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
import services.AdminRacialTraitService;
import services.RaceService;

import java.util.List;

@RestController
@RequestMapping("/api/races")
public class RaceController {

    private final RaceService raceService;
    private final AdminRacialTraitService adminRacialTraitService;

    public RaceController(RaceService raceService, AdminRacialTraitService adminRacialTraitService){
        this.raceService = raceService;
        this.adminRacialTraitService = adminRacialTraitService;
    }

    @GetMapping
    public List<RaceDto> getAllRaces(
            @RequestParam(required = false) List<String> sources) {
        return raceService.getAllRaces(sources);
    }

    @GetMapping("/{id}")
    public RaceDto getRaceById(@PathVariable Long id){
        return raceService.getRace(id);
    }

    @GetMapping("/{id}/traits")
    public List<RacialTraitDto> getRaceTraits(@PathVariable Long id){
        return raceService.getTraits(id);
    }

    @GetMapping("/subraces/{subraceId}/traits")
    public List<RacialTraitDto> getSubraceTraits(@PathVariable Long subraceId){
        return raceService.getSubraceTraits(subraceId);
    }

    // #9: creación manual de razas homebrew desde el panel de admin.
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> create(@RequestBody RaceDto dto) {
        try {
            return ResponseEntity.ok(raceService.create(dto));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // #9: crea un RacialTrait con su mecánica (#8.2 generalizado a razas), atado a una Race
    // o Subrace según req.targetType/targetId -- ver AdminRacialTraitService.
    @PostMapping("/traits")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createTrait(@RequestBody RacialTraitAdminRequest req) {
        try {
            return ResponseEntity.ok(adminRacialTraitService.create(req));
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("already exists")) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}
