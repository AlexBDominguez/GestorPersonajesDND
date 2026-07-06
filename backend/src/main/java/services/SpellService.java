package services;


import dto.SpellDto;
import entities.DndClass;
import entities.Spell;
import entities.Subclass;
import org.springframework.stereotype.Service;
import repositories.DndClassRepository;
import repositories.SpellRepository;
import repositories.SubclassRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SpellService {

    private final SpellRepository spellRepository;
    private final SubclassRepository subclassRepository;
    private final DndClassRepository dndClassRepository;

    public SpellService(SpellRepository spellRepository,
                        SubclassRepository subclassRepository,
                        DndClassRepository dndClassRepository) {
        this.spellRepository = spellRepository;
        this.subclassRepository = subclassRepository;
        this.dndClassRepository = dndClassRepository;
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

    public List<SpellDto> getAvailableSpells(Long classId, Long subclassId, Integer maxLevel, List<String> sources) {
        return getAvailableSpellEntities(classId, subclassId, maxLevel, sources).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    private List<Spell> getAvailableSpellEntities(Long classId, Long subclassId, Integer maxLevel, List<String> sources) {
        boolean hasSourceFilter = sources != null && !sources.isEmpty();

        // Comprobar si esta clase tiene spells vinculados (los lanzadores full/half los tienen; Fighter/Rogue no)
        boolean classHasSpells = classId != null &&
                spellRepository.existsByDndClassesId(classId);

        // Si la clase no tiene spells pero se ha indicado una subclase que sí tiene
        // lanzamiento de spells (p.ej. Eldritch Knight / Arcane Trickster), usar la lista del Wizard
        Long resolvedClassId = classId;
        if (!classHasSpells && subclassId != null) {
            Subclass subclass = subclassRepository.findById(subclassId).orElse(null);
            if (subclass != null && subclass.getSpellcastingAbility() != null
                    && !subclass.getSpellcastingAbility().isEmpty()) {
                DndClass wizard = dndClassRepository.findAll().stream()
                        .filter(c -> "Wizard".equalsIgnoreCase(c.getName()))
                        .findFirst().orElse(null);
                if (wizard != null) {
                    resolvedClassId = wizard.getId();
                    classHasSpells = true;
                }
            }
        }

        if (classHasSpells && maxLevel != null) {
            return hasSourceFilter
                    ? spellRepository.findByDndClassesIdAndLevelLessThanEqualAndSourceIn(resolvedClassId, maxLevel, sources)
                    : spellRepository.findByDndClassesIdAndLevelLessThanEqual(resolvedClassId, maxLevel);
        }
        if (classHasSpells) {
            return hasSourceFilter
                    ? spellRepository.findByDndClassesIdAndSourceIn(resolvedClassId, sources)
                    : spellRepository.findByDndClassesId(resolvedClassId);
        }
        if (maxLevel != null) {
            return spellRepository.findByLevelLessThanEqual(maxLevel);
        }
        return hasSourceFilter ? spellRepository.findBySourceIn(sources) : spellRepository.findAll();
    }

    private SpellDto toDto(Spell spell) {
        SpellDto dto = new SpellDto();
        dto.setId(spell.getId());
        dto.setName(spell.getName());
        dto.setLevel(spell.getLevel());
        dto.setSchool(spell.getSchool());
        dto.setCastingTime(spell.getCastingTime());
        dto.setRange(spell.getRange());
        dto.setDuration(spell.getDuration());
        dto.setComponents(spell.getComponents());
        dto.setDescription(spell.getDescription());
        return dto;
    }
}