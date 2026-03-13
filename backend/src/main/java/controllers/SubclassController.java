package controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dto.SubclassDto;
import entities.SubclassFeature;
import services.SubclassFeatureService;
import services.SubclassService;

@RestController
@RequestMapping("/api/subclasses")
public class SubclassController {

    private final SubclassService subclassService;
    private final SubclassFeatureService subclassFeatureService;

    public SubclassController(SubclassService subclassService,
                              SubclassFeatureService subclassFeatureService) {
        this.subclassService = subclassService;
        this.subclassFeatureService = subclassFeatureService;
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
    public ResponseEntity<List<SubclassFeature>> getFeatures(@PathVariable Long id) {
        return ResponseEntity.ok(subclassFeatureService.getFeaturesBySubclass(id));
    }

    @GetMapping("/{id}/features/level/{level}")
    public ResponseEntity<List<SubclassFeature>> getFeaturesUpToLevel(
            @PathVariable Long id,
            @PathVariable int level) {
        return ResponseEntity.ok(subclassFeatureService.getFeaturesUpToLevel(id, level));
    }

    @PostMapping
    public ResponseEntity<SubclassDto> create(@RequestBody SubclassDto dto) {
        return ResponseEntity.ok(subclassService.create(dto));
    }

}
