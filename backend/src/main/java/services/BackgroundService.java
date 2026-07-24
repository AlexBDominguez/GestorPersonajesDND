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

    public List<BackgroundDto> getAll(List<String> sources) {
        List<Background> backgrounds = (sources == null || sources.isEmpty())
                ? backgroundRepository.findAll()
                : backgroundRepository.findBySourceIn(sources);
        return backgrounds.stream().map(this::toDto).collect(Collectors.toList());
    }

    public BackgroundDto getById(Long id) {
        Background background = backgroundRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Background not found"));

        return toDto(background);
    }

    // #9: creación manual de backgrounds homebrew desde el panel de admin.
    public BackgroundDto create(BackgroundDto dto) {
        Background background = new Background();
        background.setIndexName(dto.getIndexName());
        background.setName(dto.getName());
        background.setSkillProficiencies(dto.getSkillProficiencies());
        background.setToolProficiencies(dto.getToolProficiencies());
        background.setLanguages(dto.getLanguages());
        background.setLanguageOptions(dto.getLanguageOptions());
        background.setFeature(dto.getFeature());
        background.setFeatureDescription(dto.getFeatureDescription());
        background.setDescription(dto.getDescription());
        background.setPersonalityTraits(dto.getPersonalityTraits());
        background.setIdeals(dto.getIdeals());
        background.setBonds(dto.getBonds());
        background.setFlaws(dto.getFlaws());
        return toDto(backgroundRepository.save(background));
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
