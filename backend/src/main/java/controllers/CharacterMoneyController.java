package controllers;

import dto.CharacterMoneyDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import services.CharacterMoneyService;

import java.util.Map;

@RestController
@RequestMapping("/api/characters/{characterId}/money")
public class CharacterMoneyController {

    private final CharacterMoneyService moneyService;

    public CharacterMoneyController(CharacterMoneyService moneyService) {
        this.moneyService = moneyService;
    }

    @GetMapping
    public ResponseEntity<CharacterMoneyDto> getMoney(@PathVariable Long characterId) {
        return ResponseEntity.ok(moneyService.getCharacterMoney(characterId));
    }

    @PostMapping("/add")
    public ResponseEntity<CharacterMoneyDto> addMoney(
            @PathVariable Long characterId,
            @RequestBody Map<String, Integer> body) {
        
        int platinum = body.getOrDefault("platinum", 0);
        int gold = body.getOrDefault("gold", 0);
        int electrum = body.getOrDefault("electrum", 0);
        int silver = body.getOrDefault("silver", 0);
        int copper = body.getOrDefault("copper", 0);
        
        return ResponseEntity.ok(moneyService.addMoney(characterId, platinum, gold, electrum, silver, copper));
    }

    @PostMapping("/subtract")
    public ResponseEntity<CharacterMoneyDto> subtractMoney(
            @PathVariable Long characterId,
            @RequestBody Map<String, Integer> body) {
        
        int platinum = body.getOrDefault("platinum", 0);
        int gold = body.getOrDefault("gold", 0);
        int electrum = body.getOrDefault("electrum", 0);
        int silver = body.getOrDefault("silver", 0);
        int copper = body.getOrDefault("copper", 0);
        
        return ResponseEntity.ok(moneyService.subtractMoney(characterId, platinum, gold, electrum, silver, copper));
    }

    @PostMapping("/set")
    public ResponseEntity<CharacterMoneyDto> setMoney(
            @PathVariable Long characterId,
            @RequestBody Map<String, Integer> body) {
        
        int platinum = body.getOrDefault("platinum", 0);
        int gold = body.getOrDefault("gold", 0);
        int electrum = body.getOrDefault("electrum", 0);
        int silver = body.getOrDefault("silver", 0);
        int copper = body.getOrDefault("copper", 0);
        
        return ResponseEntity.ok(moneyService.setMoney(characterId, platinum, gold, electrum, silver, copper));
    }
}