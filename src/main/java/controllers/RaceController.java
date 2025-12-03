package controllers;


import dto.RaceDto;
import entities.Race;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import services.RaceService;

import java.util.List;

@RestController
@RequestMapping("/api/races")
public class RaceController {

    private final RaceService raceService;

    public RaceController(RaceService raceService){
        this.raceService = raceService;
    }

    @GetMapping
    public List<RaceDto> getAllRaces(){
        return raceService.getAllRaces();
    }

    @GetMapping("/{id}")
    public RaceDto getRaceById(Long id){
        return raceService.getRace(id);
    }
}
