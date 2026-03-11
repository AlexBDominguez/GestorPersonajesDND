package services;

import dto.LanguageDto;
import entities.Language;
import org.springframework.stereotype.Service;
import repositories.LanguageRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class LanguageService {

    private final LanguageRepository languageRepository;

    public LanguageService(LanguageRepository languageRepository) {
        this.languageRepository = languageRepository;
    }

    public List<LanguageDto> getAll() {
        return languageRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public LanguageDto getById(Long id) {
        Language language = languageRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Language not found with ID: " + id));
        return toDto(language);
    }

    public List<LanguageDto> getByType(String type) {
        return languageRepository.findByType(type).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public List<LanguageDto> searchByName(String name) {
        return languageRepository.findByNameContainingIgnoreCase(name).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    public LanguageDto create(LanguageDto dto) {
        Language language = new Language();
        language.setIndexName(dto.getIndexName());
        language.setName(dto.getName());
        language.setType(dto.getType());
        language.setDescription(dto.getDescription());
        language.setScript(dto.getScript());
        language.setTypicalSpeakers(dto.getTypicalSpeakers());

        languageRepository.save(language);
        return toDto(language);
    }

    private LanguageDto toDto(Language language) {
        LanguageDto dto = new LanguageDto();
        dto.setId(language.getId());
        dto.setIndexName(language.getIndexName());
        dto.setName(language.getName());
        dto.setType(language.getType());
        dto.setDescription(language.getDescription());
        dto.setScript(language.getScript());
        dto.setTypicalSpeakers(language.getTypicalSpeakers());
        return dto;
    }
}