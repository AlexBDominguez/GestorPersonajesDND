package controllers;

import dto.ClassFeatureAdminRequest;
import dto.ClassFeatureDto;
import dto.DndClassDto;
import dto.SubclassDto;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import services.AdminClassFeatureService;
import services.DndClassService;

import java.util.List;



@RestController
@RequestMapping("/api/classes")
public class DndClassController {

    private final DndClassService service;
    private final AdminClassFeatureService adminClassFeatureService;

    public DndClassController(DndClassService service, AdminClassFeatureService adminClassFeatureService){
        this.service = service;
        this.adminClassFeatureService = adminClassFeatureService;
    }

    @GetMapping
    public List<DndClassDto> getAll(
            @RequestParam(required = false) List<String> sources) {
        return service.getAll(sources);
    }

    @GetMapping("/{id}")
    public DndClassDto getById(@PathVariable Long id){
        return service.getById(id);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public DndClassDto create(@RequestBody DndClassDto dto){
        return service.create(dto);
    }

    @GetMapping("/{id}/features")
    public List<ClassFeatureDto> getClassFeatures(@PathVariable Long id){
        return service.getFeaturesByClassId(id);
    }

    @GetMapping("/{id}/subclasses")
    public List<SubclassDto> getSubclassesByClass(
            @PathVariable Long id,
            @RequestParam(required = false) List<String> sources) {
        return service.getSubclassesByClassId(id, sources);
    }

    // #9: crea una ClassFeature (clase base) con su mecánica de #8.2 -- ver AdminClassFeatureService.
    @PostMapping("/{id}/features")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> createFeature(@PathVariable Long id, @RequestBody ClassFeatureAdminRequest req) {
        try {
            return ResponseEntity.ok(adminClassFeatureService.create(id, req));
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("already exists")) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

}
