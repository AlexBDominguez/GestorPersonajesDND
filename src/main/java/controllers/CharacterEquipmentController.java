package controllers;

import dto.CharacterEquipmentDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.CharacterEquipmentService;

import java.util.Map;

@RestController
@RequestMapping("/api/characters/{characterId}/equipment")
public class CharacterEquipmentController {

    private final CharacterEquipmentService equipmentService;

    public CharacterEquipmentController(CharacterEquipmentService equipmentService) {
        this.equipmentService = equipmentService;
    }

    @GetMapping
    public ResponseEntity<CharacterEquipmentDto> getEquipment(@PathVariable Long characterId) {
        return ResponseEntity.ok(equipmentService.getCharacterEquipment(characterId));
    }

    @PostMapping("/equip")
    public ResponseEntity<CharacterEquipmentDto> equipItem(
            @PathVariable Long characterId,
            @RequestBody Map<String, Object> body) {
        
        Long itemId = Long.valueOf(body.get("itemId").toString());
        String slot = (String) body.get("slot");
        
        if (slot == null) {
            throw new RuntimeException("slot is required (mainhand, offhand, armor, helmet, etc.)");
        }
        
        return ResponseEntity.ok(equipmentService.equipItem(characterId, itemId, slot));
    }

    @PostMapping("/unequip")
    public ResponseEntity<CharacterEquipmentDto> unequipItem(
            @PathVariable Long characterId,
            @RequestBody Map<String, String> body) {
        
        String slot = body.get("slot");
        
        if (slot == null) {
            throw new RuntimeException("slot is required");
        }
        
        return ResponseEntity.ok(equipmentService.unequipItem(characterId, slot));
    }
}