package controllers;

import dto.PlayerCharacterDto;
import entities.User;
import repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import services.PlayerCharacterService;
import java.security.Principal;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/characters")
public class PlayerCharacterController {

    private final PlayerCharacterService playerCharacterService;

    @Autowired
    private UserRepository userRepository;

    public PlayerCharacterController(PlayerCharacterService playerCharacterService) {
        this.playerCharacterService = playerCharacterService;
    }

    // ========== MÉTODO AUXILIAR PARA OBTENER EL USUARIO AUTENTICADO ==========
    
    private User getAuthenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found: " + username));
    }

    // ========== MÉTODO AUXILIAR PARA VERIFICAR PERMISOS ==========
    private void verifyCharacterOwnership(Long characterId){
        User user = getAuthenticatedUser();
        PlayerCharacterDto character = playerCharacterService.getById(characterId);
        //Objects.equals() es null-safe.
        //Me daba problemas de caché de Long
        if(!Objects.equals(character.getUserId(), user.getId())){
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You don't have permission to access this character");
        }
    }

    // ========== ENDPOINTS DE GESTIÓN DE PERSONAJES ==========

    @GetMapping
    public List<PlayerCharacterDto> getAll(){
        User user = getAuthenticatedUser();
        // Filtrar personajes del usuario autenticado
        return playerCharacterService.getCharactersByUserId(user.getId());
    }

    @GetMapping("/{id}")
    public PlayerCharacterDto getById(@PathVariable Long id){
        verifyCharacterOwnership(id);
        return playerCharacterService.getById(id);
    }

    @PostMapping
    public PlayerCharacterDto create(@RequestBody PlayerCharacterDto dto, Principal principal){
        User user = getAuthenticatedUser();
        // Asignar automáticamente el personaje al usuario autenticado
        dto.setUserId(user.getId());
        return playerCharacterService.create(dto);
    }

    // ========== ENDPOINTS DE GESTIÓN DE HECHIZOS ==========

    @PostMapping("/{characterId}/spells/{spellId}")
    public void addSpellToCharacter(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {
            
        verifyCharacterOwnership(characterId);
        playerCharacterService.addSpellToCharacter(characterId, spellId);
    }
        
    @PostMapping("/{characterId}/learn-spell/{spellId}")
    public void learnSpell(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {

        verifyCharacterOwnership(characterId);
        playerCharacterService.learnSpell(characterId, spellId);
    }

    @PostMapping("/{characterId}/spells/{spellId}/prepare")
    public ResponseEntity<Void> togglePrepareSpell(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {

            verifyCharacterOwnership(characterId);
            playerCharacterService.togglePrepareSpell(characterId, spellId);
            return ResponseEntity.noContent().build();
        }

    @DeleteMapping("/{characterId}/spells/{spellId}")
    public ResponseEntity<Void> removeSpellFromCharacter(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {
            verifyCharacterOwnership(characterId);
            playerCharacterService.removeSpellFromCharacter(characterId, spellId);
            return ResponseEntity.noContent().build();
        }    
    

    @PostMapping("/{characterId}/spells/{spellId}/cast")
    public void castSpell(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {

        verifyCharacterOwnership(characterId);
        playerCharacterService.castSpell(characterId, spellId);
    }

    @PostMapping("/{characterId}/spell-slots/{level}/use")
    public ResponseEntity<Void> useSpellSlot(
        @PathVariable Long characterId,
        @PathVariable int level) {
            verifyCharacterOwnership(characterId);
            playerCharacterService.useSpellSlot(characterId, level);
            return ResponseEntity.noContent().build();
        }            

    @PostMapping("/{characterId}/spell-slots/{level}/restore")
    public ResponseEntity<Void> restoreSpellSlot(
        @PathVariable Long characterId,
        @PathVariable int level) {
            verifyCharacterOwnership(characterId);
            playerCharacterService.restoreSpellSlot(characterId, level);
            return ResponseEntity.noContent().build();
        }

    @PostMapping("/{id}/level-up")
    public ResponseEntity<String> levelUp(@PathVariable Long id){
        verifyCharacterOwnership(id);
        playerCharacterService.levelUp(id);
        return ResponseEntity.ok("Character leveled up!");
    } 

    // ========== ENDPOINTS PARA GESTIÓN DE COMBATE Y ESTADO ==========

    @PostMapping("/{id}/damage")
    public ResponseEntity<PlayerCharacterDto> takeDamage(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        verifyCharacterOwnership(id);
        
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
        
        verifyCharacterOwnership(id);
        
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
        
        verifyCharacterOwnership(id);
        
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
        
        verifyCharacterOwnership(id);
        
        Boolean success = body.get("success");
        if (success == null) {
            throw new RuntimeException("Success status is required");
        }
        
        return ResponseEntity.ok(playerCharacterService.recordDeathSave(id, success));
    }

    @PostMapping("/{id}/reset-death-saves")
    public ResponseEntity<PlayerCharacterDto> resetDeathSaves(@PathVariable Long id) {
        verifyCharacterOwnership(id);
        return ResponseEntity.ok(playerCharacterService.resetDeathSaves(id));
    }

    // Combined HP update: damage + heal + temporaryHp in one call
    @PatchMapping("/{id}/hp")
    public ResponseEntity<PlayerCharacterDto> updateHp(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {

        verifyCharacterOwnership(id);

        int damage  = body.getOrDefault("damage",      0);
        int heal    = body.getOrDefault("heal",        0);
        int tempHp  = body.getOrDefault("temporaryHp", 0);

        PlayerCharacterDto result = null;
        if (damage > 0) result = playerCharacterService.takeDamage(id, damage);
        if (heal   > 0) result = playerCharacterService.heal(id, heal);
        if (tempHp > 0) result = playerCharacterService.setTemporaryHP(id, tempHp);
        if (result == null) result = playerCharacterService.getById(id);

        return ResponseEntity.ok(result);
    }

    @PostMapping("/{id}/toggle-inspiration")
    public ResponseEntity<PlayerCharacterDto> toggleInspiration(@PathVariable Long id) {
        verifyCharacterOwnership(id);
        return ResponseEntity.ok(playerCharacterService.toggleInspiration(id));
    }

    @PostMapping("/{id}/add-experience")
    public ResponseEntity<PlayerCharacterDto> addExperience(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        verifyCharacterOwnership(id);
        
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
        
        verifyCharacterOwnership(id);
        
        Integer numberOfDice = body.get("numberOfDice");
        if (numberOfDice == null || numberOfDice < 1) {
            throw new RuntimeException("Valid number of dice is required");
        }
        
        return ResponseEntity.ok(playerCharacterService.spendHitDice(id, numberOfDice));
    }

    @PostMapping("/{id}/long-rest")
    public ResponseEntity<PlayerCharacterDto> longRest(@PathVariable Long id) {
        verifyCharacterOwnership(id);
        return ResponseEntity.ok(playerCharacterService.longRest(id));
    }

    @PostMapping("/{id}/short-rest")
    public ResponseEntity<PlayerCharacterDto> shortRest(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body) {
        
        verifyCharacterOwnership(id);
        
        Integer hitDiceToSpend = body.getOrDefault("hitDiceToSpend", 0);
        Integer hitDiceRoll = body.getOrDefault("hitDiceRoll", 0);
        
        if (hitDiceToSpend < 0 || hitDiceRoll < 0) {
            throw new RuntimeException("Hit dice and roll values must be non-negative");
        }
        
        return ResponseEntity.ok(playerCharacterService.shortRest(id, hitDiceToSpend, hitDiceRoll));
    }   
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id){
        verifyCharacterOwnership(id);
        playerCharacterService.delete(id);
        return ResponseEntity.noContent().build();
    }
}