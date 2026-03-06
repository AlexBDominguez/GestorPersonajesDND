package services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dto.BackgroundDto;
import entities.Background;
import repositories.BackgroundRepository;

@Service
public class BackgroundService {

    private final BackgroundRepository backgroundRepository;
    
    public BackgroundService(BackgroundRepository backgroundRepository) {
        this.backgroundRepository = backgroundRepository;
    }

    public List<BackgroundDto> getAll() {
        return backgroundRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public BackgroundDto getById(Long id) {
        Background background = backgroundRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Background not found"));

        return toDto(background);
    }

    private BackgroundDto toDto(Background background) {
        BackgroundDto dto = new BackgroundDto();
        dto.setId(background.getId());
        dto.setIndexName(background.getIndexName());
        dto.setName(background.getName());
        dto.setSkillProficiencies(background.getSkillProficiencies());
        dto.setToolProficiencies(background.getToolProficiencies());
        dto.setLanguages(background.getLanguages());
        dto.setLanguageOptions(background.getLanguageOptions());
        dto.setFeature(background.getFeature());
        dto.setFeatureDescription(background.getFeatureDescription());
        dto.setDescription(background.getDescription());
        dto.setPersonalityTraits(background.getPersonalityTraits());
        dto.setIdeals(background.getIdeals());
        dto.setBonds(background.getBonds());
        dto.setFlaws(background.getFlaws());
        return dto;
    }


}
