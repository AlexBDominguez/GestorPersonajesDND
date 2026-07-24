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
import org.springframework.web.bind.annotation.RestController;

import dto.ClassFeatureDto;
import dto.SubclassDto;
import dto.SubclassFeatureAdminRequest;
import services.AdminSubclassFeatureService;
import services.SubclassFeatureService;
import services.SubclassService;

@RestController
@RequestMapping("/api/subclasses")
public class SubclassController {

    private final SubclassService subclassService;
    private final SubclassFeatureService subclassFeatureService;
    private final AdminSubclassFeatureService adminSubclassFeatureService;

    public SubclassController(SubclassService subclassService,
                              SubclassFeatureService subclassFeatureService,
                              AdminSubclassFeatureService adminSubclassFeatureService) {
        this.subclassService = subclassService;
        this.subclassFeatureService = subclassFeatureService;
        this.adminSubclassFeatureService = adminSubclassFeatureService;
    }


    @GetMapping
    public ResponseEntity<List<SubclassDto>> getAll() {
        return ResponseEntity.ok(subclassService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<SubclassDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(subclassService.getById(id));

    }

    @GetMapping("/class/{classId}")
    public ResponseEntity<List<SubclassDto>> getByClassId(@PathVariable Long classId) {
        return ResponseEntity.ok(subclassService.getByClassId(classId));
    }

    @GetMapping("/{id}/features")
    public ResponseEntity<List<ClassFeatureDto>> getFeatures(@PathVariable Long id) {
        return ResponseEntity.ok(subclassFeatureService.getFeaturesBySubclass(id));
    }

    @GetMapping("/{id}/features/level/{level}")
    public ResponseEntity<List<ClassFeatureDto>> getFeaturesUpToLevel(
            @PathVariable Long id,
            @PathVariable int level) {
        return ResponseEntity.ok(subclassFeatureService.getFeaturesUpToLevel(id, level));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SubclassDto> create(@RequestBody SubclassDto dto) {
        return ResponseEntity.ok(subclassService.create(dto));
    }

    // #9: crea una SubclassFeature junto con su mecánica (#8.2) en una sola llamada -- ver
    // AdminSubclassFeatureService para qué campos de SubclassFeatureAdminRequest se usan según
    // el mechanicType elegido.
    @PostMapping("/{id}/features")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createFeature(@PathVariable Long id,
                                            @RequestBody SubclassFeatureAdminRequest req) {
        try {
            return ResponseEntity.ok(adminSubclassFeatureService.create(id, req));
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("already exists")) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

}
