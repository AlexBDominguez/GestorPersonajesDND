package controllers;

import dto.DndClassDto;
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
    public List<DndClassDto> getAll(){
        return service.getAll();
    }

    @GetMapping("/{id}")
    public DndClassDto getById(@PathVariable Long id){
        return service.getById(id);
    }

    @PostMapping
    public DndClassDto create(@RequestBody DndClassDto dto){
        return service.create(dto);
    }

}
