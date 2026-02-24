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

    @PostMapping("/{characterId}/spells/{spellId}")
    public void addSpellToCharacter(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {
            
        playerCharacterService.addSpellToCharacter(characterId, spellId);
        }
        
    @PostMapping("/{characterId}/learn-spell/{spellId}")
    public void learnSpell(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {

            playerCharacterService.learnSpell(characterId, spellId);
        }

    @PostMapping("/{characterId}/spells{spellId}/prepare")
    public void prepareSpell(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {

        playerCharacterService.prepareSpell(characterId, spellId);
        }

    @PostMapping("/{characterId}/spells{spellId}/cast")
    public void castSpell(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {

        playerCharacterService.castSpell(characterId, spellId);
        }
}
