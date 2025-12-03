package controllers;

import dto.PlayerCharacterDto;
import org.springframework.web.bind.annotation.*;
import services.PlayerCharacterService;

import java.util.List;

@RestController
@RequestMapping("/api/characters")
public class PlayerCharacterController {

    private final PlayerCharacterService playerCharacterService;

    public PlayerCharacterController(PlayerCharacterService playerCharacterService) {
        this.playerCharacterService = playerCharacterService;
    }

    @GetMapping
    public List<PlayerCharacterDto> getAll(){
        return playerCharacterService.getAll();
    }

    @GetMapping("/{id}")
    public PlayerCharacterDto getById(@PathVariable Long id){
        return playerCharacterService.getById(id);
    }

    @PostMapping
    public PlayerCharacterDto create(@RequestBody PlayerCharacterDto dto){
        return playerCharacterService.create(dto);
    }

}
