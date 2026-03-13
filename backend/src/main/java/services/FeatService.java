package services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import dto.FeatDto;
import entities.Feat;
import repositories.FeatRepository;

@Service
public class FeatService {

    private final FeatRepository featRepository;

    public FeatService(FeatRepository featRepository) {
        this.featRepository = featRepository;
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
        return dto;
    }

    
    
}
