package controllers;

import dto.ClassFeatureDto;
import dto.DndClassDto;
import dto.SubclassDto;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import services.DndClassService;

import java.util.List;



@RestController
@RequestMapping("/api/classes")
public class DndClassController {

    private final DndClassService service;

    public DndClassController(DndClassService service){
        this.service = service;
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

}
