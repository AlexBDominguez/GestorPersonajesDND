package controllers;

import dto.PlayerCharacterDto;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.PlayerCharacterService;

import java.util.List;
import java.util.Map;

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

    @PostMapping("/{id}/level-up")
    public ResponseEntity<String> levelUp(@PathVariable Long id){
            playerCharacterService.levelUp(id);
            return ResponseEntity.ok("Character leveled up!");
        } 

    // ========== ENDPOINTS PARA GESTIÓN DE COMBATE Y ESTADO ==========

    @PostMapping("/{id}/damage")
    public ResponseEntity<PlayerCharacterDto> takeDamage(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        Integer damage = body.get("damage");
        if (damage == null || damage < 0) {
            throw new RuntimeException("Valid damage amount is required");
        }
        
        return ResponseEntity.ok(playerCharacterService.takeDamage(id, damage));
    }

    @PostMapping("/{id}/heal")
    public ResponseEntity<PlayerCharacterDto> heal(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        Integer healing = body.get("healing");
        if (healing == null || healing < 0) {
            throw new RuntimeException("Valid healing amount is required");
        }
        
        return ResponseEntity.ok(playerCharacterService.heal(id, healing));
    }

    @PostMapping("/{id}/temporary-hp")
    public ResponseEntity<PlayerCharacterDto> setTemporaryHP(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        Integer tempHP = body.get("temporaryHP");
        if (tempHP == null || tempHP < 0) {
            throw new RuntimeException("Valid temporary HP amount is required");
        }
        
        return ResponseEntity.ok(playerCharacterService.setTemporaryHP(id, tempHP));
    }

    @PostMapping("/{id}/death-save")
    public ResponseEntity<PlayerCharacterDto> recordDeathSave(
            @PathVariable Long id,
            @RequestBody Map<String, Boolean> body) {
        
        Boolean success = body.get("success");
        if (success == null) {
            throw new RuntimeException("Success status is required");
        }
        
        return ResponseEntity.ok(playerCharacterService.recordDeathSave(id, success));
    }

    @PostMapping("/{id}/reset-death-saves")
    public ResponseEntity<PlayerCharacterDto> resetDeathSaves(@PathVariable Long id) {
        return ResponseEntity.ok(playerCharacterService.resetDeathSaves(id));
    }

    @PostMapping("/{id}/toggle-inspiration")
    public ResponseEntity<PlayerCharacterDto> toggleInspiration(@PathVariable Long id) {
        return ResponseEntity.ok(playerCharacterService.toggleInspiration(id));
    }

    @PostMapping("/{id}/add-experience")
    public ResponseEntity<PlayerCharacterDto> addExperience(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        Integer xp = body.get("experience");
        if (xp == null) {
            throw new RuntimeException("Experience amount is required");
        }
        
        return ResponseEntity.ok(playerCharacterService.addExperience(id, xp));
    }

    @PostMapping("/{id}/spend-hit-dice")
    public ResponseEntity<PlayerCharacterDto> spendHitDice(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        Integer numberOfDice = body.get("numberOfDice");
        if (numberOfDice == null || numberOfDice < 1) {
            throw new RuntimeException("Valid number of dice is required");
        }
        
        return ResponseEntity.ok(playerCharacterService.spendHitDice(id, numberOfDice));
    }

    @PostMapping("/{id}/long-rest")
    public ResponseEntity<PlayerCharacterDto> longRest(@PathVariable Long id) {
        return ResponseEntity.ok(playerCharacterService.longRest(id));
    }

    @PostMapping("/{id}/short-rest")
    public ResponseEntity<PlayerCharacterDto> shortRest(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        Integer hitDiceToSpend = body.getOrDefault("hitDiceToSpend", 0);
        Integer hitDiceRoll = body.getOrDefault("hitDiceRoll", 0);
        
        if (hitDiceToSpend < 0 || hitDiceRoll < 0) {
            throw new RuntimeException("Hit dice and roll values must be non-negative");
        }
        
        return ResponseEntity.ok(playerCharacterService.shortRest(id, hitDiceToSpend, hitDiceRoll));
    }       
    
}
