package services;


import entities.Spell;
import org.springframework.stereotype.Service;
import repositories.SpellRepository;

import java.util.List;

@Service
public class SpellService {

    private final SpellRepository spellRepository;

    public SpellService(SpellRepository spellRepository) {
        this.spellRepository = spellRepository;
    }

    public List<Spell> getAllSpells() {
        return spellRepository.findAll();
    }

    public List<Spell> getSpellsByLevel(int level) {
        return spellRepository.findByLevel(level);
    }

    public List<Spell> searchByName(String name) {
        return spellRepository.findByNameContainingIgnoreCase(name);
    }

    public List<Spell> getSpellsByCastingTime(String castingTime){
        return
            spellRepository.findByCastingTimeContainingIgnoreCase(castingTime);
    }

    public List<Spell> getAvailableSpells(Long classId, Long subclassId, Integer maxLevel){
        if(maxLevel != null){
            return spellRepository.findByLevelLessThanEqual(maxLevel);
        }
        return spellRepository.findAll();
    }
}