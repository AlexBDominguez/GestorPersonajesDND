package services;


import entities.DndClass;
import entities.Spell;
import entities.Subclass;
import org.springframework.stereotype.Service;
import repositories.DndClassRepository;
import repositories.SpellRepository;
import repositories.SubclassRepository;
import dto.SpellDto;
import config.RequestLocaleContext;
import utils.LocalizedTextResolver;

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

    public List<SpellDto> getAllSpells() {
        return spellRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<SpellDto> getSpellsByLevel(int level) {
        return spellRepository.findByLevel(level).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<SpellDto> searchByName(String name) {
        return spellRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<SpellDto> getSpellsByCastingTime(String castingTime){
        return spellRepository.findByCastingTimeContainingIgnoreCase(castingTime).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<SpellDto> getAvailableSpells(Long classId, Long subclassId, Integer maxLevel){
        // Check if this class has spells linked (full/half-casters do; Fighter/Rogue don't)
        boolean classHasSpells = classId != null &&
                !spellRepository.findByDndClassesId(classId).isEmpty();

        // If the class has no spells but a subclass is provided and that subclass has
        // spellcasting (e.g. Eldritch Knight / Arcane Trickster), use the Wizard spell list
        Long resolvedClassId = classId;
        if (!classHasSpells && subclassId != null) {
            Subclass subclass = subclassRepository.findById(subclassId).orElse(null);
            if (subclass != null && subclass.getSpellcastingAbility() != null
                    && !subclass.getSpellcastingAbility().isEmpty()) {
                // Third-caster: use Wizard list (abjuration + evocation focus, but list is Wizard)
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
            return spellRepository.findByDndClassesIdAndLevelLessThanEqual(resolvedClassId, maxLevel)
                    .stream().map(this::toDto).collect(Collectors.toList());
        }
        if (classHasSpells) {
            return spellRepository.findByDndClassesId(resolvedClassId)
                    .stream().map(this::toDto).collect(Collectors.toList());
        }
        if (maxLevel != null) {
            return spellRepository.findByLevelLessThanEqual(maxLevel)
                    .stream().map(this::toDto).collect(Collectors.toList());
        }
        return spellRepository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    private SpellDto toDto(Spell spell) {
        String locale = RequestLocaleContext.get();
        SpellDto dto = new SpellDto();
        dto.setId(spell.getId());
        dto.setName(LocalizedTextResolver.resolve(locale, spell.getName(), spell.getNameEs(), spell.getNameGl()));
        dto.setLevel(spell.getLevel());
        dto.setSchool(spell.getSchool());
        dto.setCastingTime(spell.getCastingTime());
        dto.setRange(spell.getRange());
        dto.setDuration(spell.getDuration());
        dto.setComponents(spell.getComponents());
        dto.setDescription(LocalizedTextResolver.resolve(locale, spell.getDescription(), spell.getDescriptionEs(), spell.getDescriptionGl()));
        dto.setAttackType(spell.getAttackType());
        dto.setDcType(spell.getDcType());
        dto.setDamageType(spell.getDamageType());
        dto.setDamageBase(spell.getDamageBase());
        return dto;
    }
}