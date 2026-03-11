package services;

import dto.DamageTypeDto;
import entities.DamageType;
import org.springframework.stereotype.Service;
import repositories.DamageTypeRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class DamageTypeService {

    private final DamageTypeRepository damageTypeRepository;

    public DamageTypeService(DamageTypeRepository damageTypeRepository) {
        this.damageTypeRepository = damageTypeRepository;
    }

    public List<DamageTypeDto> getAll() {
        return damageTypeRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public DamageTypeDto getById(Long id) {
        DamageType damageType = damageTypeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("DamageType not found with ID: " + id));
        return toDto(damageType);
    }

    public List<DamageTypeDto> searchByName(String name) {
        return damageTypeRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public DamageTypeDto create(DamageTypeDto dto) {
        DamageType damageType = new DamageType();
        damageType.setIndexName(dto.getIndexName());
        damageType.setName(dto.getName());
        damageType.setDescription(dto.getDescription());

        damageTypeRepository.save(damageType);
        return toDto(damageType);
    }

    private DamageTypeDto toDto(DamageType damageType) {
        DamageTypeDto dto = new DamageTypeDto();
        dto.setId(damageType.getId());
        dto.setIndexName(damageType.getIndexName());
        dto.setName(damageType.getName());
        dto.setDescription(damageType.getDescription());
        return dto;
    }
}