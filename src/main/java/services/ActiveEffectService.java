package services;

import dto.ActiveEffectDto;
import entities.ActiveEffect;
import org.springframework.stereotype.Service;
import repositories.ActiveEffectRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ActiveEffectService {

    private final ActiveEffectRepository activeEffectRepository;

    public ActiveEffectService(ActiveEffectRepository activeEffectRepository) {
        this.activeEffectRepository = activeEffectRepository;
    }

    public List<ActiveEffectDto> getAll() {
        return activeEffectRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ActiveEffectDto getById(Long id) {
        ActiveEffect effect = activeEffectRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("ActiveEffect not found with ID: " + id));
        return toDto(effect);
    }

    public List<ActiveEffectDto> searchByName(String name) {
        return activeEffectRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<ActiveEffectDto> getBySource(String source) {
        return activeEffectRepository.findBySource(source).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ActiveEffectDto create(ActiveEffectDto dto) {
        ActiveEffect effect = new ActiveEffect();
        effect.setName(dto.getName());
        effect.setIndexName(dto.getIndexName());
        effect.setDescription(dto.getDescription());
        effect.setModifierTypes(dto.getModifierTypes());
        effect.setModifierValue(dto.getModifierValue());
        effect.setDuration(dto.getDuration());
        effect.setRequiresConcentration(dto.isRequiresConcentration());
        effect.setSource(dto.getSource());
        effect.setConditions(dto.getConditions());

        activeEffectRepository.save(effect);
        return toDto(effect);
    }

    private ActiveEffectDto toDto(ActiveEffect effect) {
        ActiveEffectDto dto = new ActiveEffectDto();
        dto.setId(effect.getId());
        dto.setName(effect.getName());
        dto.setIndexName(effect.getIndexName());
        dto.setDescription(effect.getDescription());
        dto.setModifierTypes(effect.getModifierTypes());
        dto.setModifierValue(effect.getModifierValue());
        dto.setDuration(effect.getDuration());
        dto.setRequiresConcentration(effect.isRequiresConcentration());
        dto.setSource(effect.getSource());
        dto.setConditions(effect.getConditions());
        return dto;
    }
}