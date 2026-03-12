package controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import dto.ClassResourceDto;
import services.ClassResourceService;

@RestController
@RequestMapping("/api/class-resources")
public class ClassResourceController {

    private final ClassResourceService classResourceService;

    public ClassResourceController(ClassResourceService classResourceService) {
        this.classResourceService = classResourceService;
    }

    @GetMapping
    public ResponseEntity<List<ClassResourceDto>> getAll() {
        return ResponseEntity.ok(classResourceService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ClassResourceDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(classResourceService.getById(id));
    }

    @GetMapping("/class/{classId}")
    public ResponseEntity<List<ClassResourceDto>> getByClassId(@PathVariable Long classId) {
        return ResponseEntity.ok(classResourceService.getByClassId(classId));
    }

    @PostMapping
    public ResponseEntity<ClassResourceDto> create(@RequestBody ClassResourceDto dto) {
        return ResponseEntity.ok(classResourceService.create(dto));
    }
    
}
