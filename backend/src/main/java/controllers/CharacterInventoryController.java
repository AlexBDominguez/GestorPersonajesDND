package controllers;

import dto.CharacterInventoryDto;
import entities.PlayerCharacter;
import entities.User;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import repositories.PlayerCharacterRepository;
import repositories.UserRepository;
import services.CharacterInventoryService;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/characters/{characterId}/inventory")
public class CharacterInventoryController {

    private final CharacterInventoryService inventoryService;
    private final PlayerCharacterRepository characterRepository;
    private final UserRepository userRepository;

    public CharacterInventoryController(CharacterInventoryService inventoryService,
                                        PlayerCharacterRepository characterRepository,
                                        UserRepository userRepository) {
        this.inventoryService = inventoryService;
        this.characterRepository = characterRepository;
        this.userRepository = userRepository;
    }

    /** Verifies the authenticated user owns the given character. */
    private void verifyOwnership(Long characterId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userRepository.findByUsername(auth.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Character not found"));
        if (!Objects.equals(character.getUser().getId(), user.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }
    }

    @GetMapping
    public ResponseEntity<List<CharacterInventoryDto>> getInventory(@PathVariable Long characterId) {
        verifyOwnership(characterId);
        return ResponseEntity.ok(inventoryService.getCharacterInventory(characterId));
    }

    @GetMapping("/weight")
    public ResponseEntity<Map<String, Double>> getTotalWeight(@PathVariable Long characterId) {
        verifyOwnership(characterId);
        Double weight = inventoryService.getTotalWeight(characterId);
        return ResponseEntity.ok(Map.of("totalWeight", weight));
    }

    @PostMapping("/add")
    public ResponseEntity<CharacterInventoryDto> addItem(
            @PathVariable Long characterId,
            @RequestBody Map<String, Object> body) {
        verifyOwnership(characterId);
        Long itemId = Long.valueOf(body.get("itemId").toString());
        Integer quantity = body.containsKey("quantity") ? (Integer) body.get("quantity") : 1;
        
        return ResponseEntity.ok(inventoryService.addItemToInventory(characterId, itemId, quantity));
    }

    @PatchMapping("/{inventoryId}/quantity")
    public ResponseEntity<CharacterInventoryDto> updateQuantity(
            @PathVariable Long characterId,
            @PathVariable Long inventoryId,
            @RequestBody Map<String, Integer> body) {
        verifyOwnership(characterId);
        Integer newQuantity = body.get("quantity");
        if (newQuantity == null) {
            throw new RuntimeException("quantity is required");
        }
        
        return ResponseEntity.ok(inventoryService.updateQuantity(inventoryId, newQuantity));
    }

    @DeleteMapping("/item/{itemId}")
    public ResponseEntity<String> removeItem(
            @PathVariable Long characterId,
            @PathVariable Long itemId) {
        verifyOwnership(characterId);
        inventoryService.removeItemFromInventory(characterId, itemId);
        return ResponseEntity.ok("Item removed from inventory");
    }

    @PostMapping("/{inventoryId}/toggle-attuned")
    public ResponseEntity<CharacterInventoryDto> toggleAttuned(
            @PathVariable Long characterId,
            @PathVariable Long inventoryId) {
        verifyOwnership(characterId);
        return ResponseEntity.ok(inventoryService.toggleAttuned(inventoryId));
    }

    @PostMapping("/{inventoryId}/toggle-equipped")
    public ResponseEntity<CharacterInventoryDto> toggleEquipped(
            @PathVariable Long characterId,
            @PathVariable Long inventoryId) {
        verifyOwnership(characterId);
        return ResponseEntity.ok(inventoryService.toggleEquipped(inventoryId));
    }
}