package controllers;

import entities.Spell;
import org.springframework.web.bind.annotation.*;
import services.SpellService;

import java.util.List;

@RestController
@RequestMapping("/api/spells")
public class SpellController {

    private final SpellService spellService;

    public SpellController(SpellService spellService) {
        this.spellService = spellService;
    }

    @GetMapping
    public List<Spell> getAllSpells() {
        return spellService.getAllSpells();
    }

    @GetMapping("/level/{level}")
    public List<Spell> getByLevel(@PathVariable int level) {
        return spellService.getSpellsByLevel(level);
    }

    @GetMapping("/search")
    public List<Spell> searchByName(@RequestParam String name) {
        return spellService.searchByName(name);
    }

    @GetMapping("/casting-time/{castingTime}")
    public List<Spell> getByCastingTime(@PathVariable String castingTime) {
        return spellService.getSpellsByCastingTime(castingTime);
    }

    //Endpoint para obtener hechizos por clase y nivel
    //Usar en wizard para mostrar qué hechizos puede aprender el personaje
    @GetMapping("/available")
    public List<Spell> getAvailableSpells(
        @RequestParam(required = false) Long classId,
        @RequestParam(required = false) Long subclassId,
        @RequestParam(required = false) Integer maxLevel){
        return spellService.getAvailableSpells(classId, subclassId, maxLevel);
        }
    
}
