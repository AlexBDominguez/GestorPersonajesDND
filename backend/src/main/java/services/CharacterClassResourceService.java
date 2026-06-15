package services;

import entities.CharacterClassResource;
import entities.PlayerCharacter;
import entities.ClassResource;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterClassResourceRepository;
import repositories.PlayerCharacterRepository;
import repositories.ClassResourceRepository;
import dto.CharacterClassResourceDto;
import java.util.stream.Collectors;

import java.util.List;

@Service
public class CharacterClassResourceService {

    private final CharacterClassResourceRepository characterClassResourceRepository;
    private final PlayerCharacterRepository characterRepository;
    private final ClassResourceRepository classResourceRepository;

    public CharacterClassResourceService(
            CharacterClassResourceRepository characterClassResourceRepository,
            PlayerCharacterRepository characterRepository,
            ClassResourceRepository classResourceRepository) {
        this.characterClassResourceRepository = characterClassResourceRepository;
        this.characterRepository = characterRepository;
        this.classResourceRepository = classResourceRepository;
    }

    public List<CharacterClassResource> getCharacterResources(Long characterId) {
        return characterClassResourceRepository.findByCharacterId(characterId);
    }

    public List<CharacterClassResourceDto> getCharacterResourcesDto(Long characterId) {
    return characterClassResourceRepository.findByCharacterId(characterId).stream()
            .map(this::toDto)
            .collect(Collectors.toList());
    }

    @Transactional
    public CharacterClassResourceDto spendResourceDto(Long characterId, String resourceIndexName, int amount) {
        spendResource(characterId, resourceIndexName, amount);

        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        ClassResource classResource = classResourceRepository.findByIndexName(resourceIndexName)
                .orElseThrow(() -> new RuntimeException("Class resource not found: " + resourceIndexName));

        CharacterClassResource ccr = characterClassResourceRepository
                .findByCharacterAndClassResource(character, classResource)
                .orElseThrow(() -> new RuntimeException("Character does not have this resource"));

        return toDto(ccr);
    }

    @Transactional
    public CharacterClassResourceDto recoverResourceDto(Long characterId, String resourceIndexName, int amount) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        ClassResource classResource = classResourceRepository.findByIndexName(resourceIndexName)
                .orElseThrow(() -> new RuntimeException("Class resource not found: " + resourceIndexName));

        CharacterClassResource ccr = characterClassResourceRepository
                .findByCharacterAndClassResource(character, classResource)
                .orElseThrow(() -> new RuntimeException("Character does not have this resource"));

        int newAmount = Math.min(ccr.getMaxAmount(), ccr.getCurrentAmount() + amount);
        ccr.setCurrentAmount(newAmount);
        characterClassResourceRepository.save(ccr);
        
        return toDto(ccr);
    }

    private CharacterClassResourceDto toDto(CharacterClassResource ccr) {
        CharacterClassResourceDto dto = new CharacterClassResourceDto();
        dto.setId(ccr.getId());
        dto.setCharacterId(ccr.getCharacter().getId());
        dto.setCharacterName(ccr.getCharacter().getName());
        dto.setClassResourceId(ccr.getClassResource().getId());
        dto.setResourceName(ccr.getClassResource().getName());
        dto.setResourceIndexName(ccr.getClassResource().getIndexName());
        dto.setMaxAmount(ccr.getMaxAmount());
        dto.setCurrentAmount(ccr.getCurrentAmount());
        dto.setRecoveryType(ccr.getClassResource().getRecoveryType());
        return dto;
    }


    @Transactional
    public void initializeClassResourcesForCharacter(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        // Obtener recursos de la clase del personaje según su nivel, filtrando por subclase si aplica
        String subclassIndex = character.getSubclass() != null
                ? character.getSubclass().getIndexName() : null;

        List<ClassResource> classResources = classResourceRepository
                .findByDndClassAndLevelUnlockedLessThanEqual(
                        character.getDndClass(), character.getLevel())
                .stream()
                .filter(r -> r.getSubclassRestriction() == null
                        || r.getSubclassRestriction().equals(subclassIndex))
                .collect(java.util.stream.Collectors.toList());

        for (ClassResource resource : classResources) {
            // Verificar si ya existe
            if (characterClassResourceRepository
                    .findByCharacterAndClassResource(character, resource).isEmpty()) {
                
                int maxAmount = calculateMaxAmount(character, resource);
                CharacterClassResource ccr = new CharacterClassResource(character, resource, maxAmount);
                characterClassResourceRepository.save(ccr);
            }
        }
    }

    @Transactional
    public void recoverResources(Long characterId, String recoveryType) {
        List<CharacterClassResource> resources = characterClassResourceRepository
                .findByCharacterIdAndRecoveryType(characterId, recoveryType);

        for (CharacterClassResource resource : resources) {
            resource.setCurrentAmount(resource.getMaxAmount());
            characterClassResourceRepository.save(resource);
        }

        System.out.println("Recovered " + resources.size() + " resources for recovery type: " + recoveryType);
    }

    @Transactional
    public void spendResource(Long characterId, String resourceIndexName, int amount) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        ClassResource classResource = classResourceRepository.findByIndexName(resourceIndexName)
                .orElseThrow(() -> new RuntimeException("Class resource not found: " + resourceIndexName));

        CharacterClassResource ccr = characterClassResourceRepository
                .findByCharacterAndClassResource(character, classResource)
                .orElseThrow(() -> new RuntimeException("Character does not have this resource"));

        if (ccr.getCurrentAmount() < amount) {
            throw new RuntimeException("Not enough " + classResource.getName() + 
                                     ". Available: " + ccr.getCurrentAmount() + ", needed: " + amount);
        }

        ccr.setCurrentAmount(ccr.getCurrentAmount() - amount);
        characterClassResourceRepository.save(ccr);
    }

    private int calculateMaxAmount(PlayerCharacter character, ClassResource resource) {
        String formula = resource.getMaxFormula();
        
        if (formula == null) {
            return 0;
        }

        switch (formula.toLowerCase()) {
            case "level":
                return character.getLevel();

            case "level_monk":
                return character.getLevel();

            case "level_sorcerer":
                return character.getLevel();

            case "proficiency_bonus":
                return character.getProficiencyBonus();

            case "charisma_modifier":
                return Math.max(1, character.calculateAbilityModifier("cha"));

            case "level_half":
                return Math.max(1, character.getLevel() / 2);

            case "level_divided_3":
                return Math.max(1, character.getLevel() / 3);

            case "wisdom_modifier_min1":
                return Math.max(1, character.calculateAbilityModifier("wis"));

            // Tabla de usos de Furia del Bárbaro (no sigue proficiency bonus)
            case "barbarian_rage_table":
                return barbarianRageUses(character.getLevel());

            default:
                try {
                    return Integer.parseInt(formula);
                } catch (NumberFormatException e) {
                    System.err.println("Unknown formula: " + formula);
                    return 0;
                }
        }
    }

    private int barbarianRageUses(int level) {
        if (level >= 20) return 999;
        if (level >= 17) return 6;
        if (level >= 12) return 5;
        if (level >= 6)  return 4;
        if (level >= 3)  return 3;
        return 2;
    }

    @Transactional
    public void updateResourceMaximums(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        List<CharacterClassResource> resources = characterClassResourceRepository
                .findByCharacter(character);

        for (CharacterClassResource ccr : resources) {
            int newMax = calculateMaxAmount(character, ccr.getClassResource());
            
            // Si el máximo aumentó, aumentar también el actual proporcionalmente
            if (newMax > ccr.getMaxAmount()) {
                int difference = newMax - ccr.getMaxAmount();
                ccr.setCurrentAmount(Math.min(newMax, ccr.getCurrentAmount() + difference));
            }
            
            ccr.setMaxAmount(newMax);
            characterClassResourceRepository.save(ccr);
        }
    }
}