package services;

import dto.ConditionDto;
import entities.Condition;
import org.springframework.stereotype.Service;
import repositories.ConditionRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ConditionService {

    private final ConditionRepository conditionRepository;

    public ConditionService(ConditionRepository conditionRepository) {
        this.conditionRepository = conditionRepository;
    }

    public List<ConditionDto> getAll() {
        return conditionRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ConditionDto getById(Long id) {
        Condition condition = conditionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Condition not found with ID: " + id));
        return toDto(condition);
    }

    public List<ConditionDto> searchByName(String name) {
        return conditionRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public ConditionDto create(ConditionDto dto) {
        Condition condition = new Condition();
        condition.setIndexName(dto.getIndexName());
        condition.setName(dto.getName());
        condition.setDescription(dto.getDescription());

        conditionRepository.save(condition);
        return toDto(condition);
    }

    private ConditionDto toDto(Condition condition) {
        ConditionDto dto = new ConditionDto();
        dto.setId(condition.getId());
        dto.setIndexName(condition.getIndexName());
        dto.setName(condition.getName());
        dto.setDescription(condition.getDescription());
        return dto;
    }
}