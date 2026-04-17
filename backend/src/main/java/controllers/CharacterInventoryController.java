package controllers;

import dto.CharacterInventoryDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.CharacterInventoryService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/characters/{characterId}/inventory")
public class CharacterInventoryController {

    private final CharacterInventoryService inventoryService;

    public CharacterInventoryController(CharacterInventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    @GetMapping
    public ResponseEntity<List<CharacterInventoryDto>> getInventory(@PathVariable Long characterId) {
        return ResponseEntity.ok(inventoryService.getCharacterInventory(characterId));
    }

    @GetMapping("/weight")
    public ResponseEntity<Map<String, Double>> getTotalWeight(@PathVariable Long characterId) {
        Double weight = inventoryService.getTotalWeight(characterId);
        return ResponseEntity.ok(Map.of("totalWeight", weight));
    }

    @PostMapping("/add")
    public ResponseEntity<CharacterInventoryDto> addItem(
            @PathVariable Long characterId,
            @RequestBody Map<String, Object> body) {
        
        Long itemId = Long.valueOf(body.get("itemId").toString());
        Integer quantity = body.containsKey("quantity") ? (Integer) body.get("quantity") : 1;
        
        return ResponseEntity.ok(inventoryService.addItemToInventory(characterId, itemId, quantity));
    }

    @PatchMapping("/{inventoryId}/quantity")
    public ResponseEntity<CharacterInventoryDto> updateQuantity(
            @PathVariable Long characterId,
            @PathVariable Long inventoryId,
            @RequestBody Map<String, Integer> body) {
        
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
        
        inventoryService.removeItemFromInventory(characterId, itemId);
        return ResponseEntity.ok("Item removed from inventory");
    }

    @PostMapping("/{inventoryId}/toggle-attuned")
    public ResponseEntity<CharacterInventoryDto> toggleAttuned(
            @PathVariable Long characterId,
            @PathVariable Long inventoryId) {
        
        return ResponseEntity.ok(inventoryService.toggleAttuned(inventoryId));
    }

    @PostMapping("/{inventoryId}/toggle-equipped")
    public ResponseEntity<CharacterInventoryDto> toggleEquipped(
            @PathVariable Long characterId,
            @PathVariable Long inventoryId) {
        return ResponseEntity.ok(inventoryService.toggleEquipped(inventoryId));
    }
}