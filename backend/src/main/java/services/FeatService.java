package services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dto.FeatDto;
import entities.Feat;
import entities.Spell;
import repositories.FeatRepository;
import repositories.SpellRepository;

@Service
public class FeatService {

    private final FeatRepository featRepository;
    private final SpellRepository spellRepository;

    public FeatService(FeatRepository featRepository, SpellRepository spellRepository) {
        this.featRepository = featRepository;
        this.spellRepository = spellRepository;
    }

    public List<FeatDto> getAll() {
        return featRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public FeatDto getById(Long id) {
        Feat feat = featRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Feat not found with id: " + id));
        return toDto(feat);
    }

    public List<FeatDto> searchByName(String name) {
        return featRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public FeatDto create(FeatDto dto){
        Feat feat = new Feat();
        feat.setIndexName(dto.getIndexName());
        feat.setName(dto.getName());
        feat.setDescription(dto.getDescription());
        feat.setPrerequisites(dto.getPrerequisites());
        feat.setEffectModifierType(dto.getEffectModifierType());
        feat.setEffectModifierValue(dto.getEffectModifierValue());
        feat.setChoiceProficiencyCount(dto.getChoiceProficiencyCount());
        if (dto.getGrantedSpellIds() != null && !dto.getGrantedSpellIds().isEmpty()) {
            List<Spell> spells = dto.getGrantedSpellIds().stream()
                    .map(id -> spellRepository.findById(id)
                            .orElseThrow(() -> new RuntimeException("Spell not found: " + id)))
                    .collect(Collectors.toList());
            feat.setGrantedSpells(spells);
        }

        featRepository.save(feat);
        return toDto(feat);
    }

    private FeatDto toDto(Feat feat) {
        FeatDto dto = new FeatDto();
        dto.setId(feat.getId());
        dto.setIndexName(feat.getIndexName());
        dto.setName(feat.getName());
        dto.setDescription(feat.getDescription());
        dto.setPrerequisites(feat.getPrerequisites());
        dto.setEffectModifierType(feat.getEffectModifierType());
        dto.setEffectModifierValue(feat.getEffectModifierValue());
        dto.setChoiceProficiencyCount(feat.getChoiceProficiencyCount());
        if (feat.getGrantedSpells() != null) {
            dto.setGrantedSpellIds(feat.getGrantedSpells().stream()
                    .map(Spell::getId)
                    .collect(Collectors.toList()));
        }
        return dto;
    }

    
    
}
