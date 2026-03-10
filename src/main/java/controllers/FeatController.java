package controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import dto.FeatDto;
import services.FeatService;

@RestController
@RequestMapping("/api/feats")
public class FeatController {

    private final FeatService featService;

    public FeatController(FeatService featService) {
        this.featService = featService;
    }

    @GetMapping
    public ResponseEntity<List<FeatDto>> getAll(){
        return ResponseEntity.ok(featService.getAll());    
    }

    @GetMapping("/{id}")
    public ResponseEntity<FeatDto> getById(@PathVariable Long id){
        return ResponseEntity.ok(featService.getById(id));
    }

    @GetMapping("/search")
        public ResponseEntity<List<FeatDto>> searchByName(@RequestParam String name){
            return ResponseEntity.ok(featService.searchByName(name));
        }
    
    @PostMapping
    public ResponseEntity<FeatDto> create(@RequestBody FeatDto dto){
        return ResponseEntity.ok(featService.create(dto));
    }
    

    

}
