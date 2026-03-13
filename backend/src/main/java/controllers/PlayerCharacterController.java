package controllers;

import dto.PlayerCharacterDto;
import entities.User;
import repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import services.PlayerCharacterService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/characters")
@CrossOrigin(origins = "*") // Permitir peticiones desde Flutter
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
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
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
        User user = getAuthenticatedUser();
        PlayerCharacterDto character = playerCharacterService.getById(id);
        
        // Verificar que el personaje pertenece al usuario autenticado
        if (!character.getUserId().equals(user.getId())) {
            throw new RuntimeException("No tienes permiso para acceder a este personaje");
        }
        
        return character;
    }

    @PostMapping
    public PlayerCharacterDto create(@RequestBody PlayerCharacterDto dto){
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
    public void prepareSpell(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {

        verifyCharacterOwnership(characterId);
        playerCharacterService.prepareSpell(characterId, spellId);
    }

    @PostMapping("/{characterId}/spells/{spellId}/cast")
    public void castSpell(
        @PathVariable Long characterId,
        @PathVariable Long spellId) {

        verifyCharacterOwnership(characterId);
        playerCharacterService.castSpell(characterId, spellId);
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

    // ========== MÉTODO AUXILIAR PARA VERIFICAR PERMISOS ==========
    
    private void verifyCharacterOwnership(Long characterId) {
        User user = getAuthenticatedUser();
        PlayerCharacterDto character = playerCharacterService.getById(characterId);
        
        if (!character.getUserId().equals(user.getId())) {
            throw new RuntimeException("No tienes permiso para modificar este personaje");
        }
    }
}