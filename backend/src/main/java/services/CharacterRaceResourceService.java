package services;

import dto.CharacterRaceResourceDto;
import entities.CharacterRaceResource;
import entities.PlayerCharacter;
import entities.RaceResource;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import repositories.CharacterRaceResourceRepository;
import repositories.PlayerCharacterRepository;
import repositories.RaceResourceRepository;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Mirrors CharacterClassResourceService, for RaceResource instead of ClassResource. See #9.
 * No per-level gating (racial traits, unlike class features, don't have a level field in this
 * app's schema -- confirmed while designing this: race_traits/subrace_traits are flat
 * many-to-many joins, no level column -- matching how almost every real 5e racial trait is
 * granted at character level 1 anyway) and no multi-choice gating (no race trait needs it yet,
 * unlike Rune Knight for RESOURCE_POOL class resources).
 */
@Service
public class CharacterRaceResourceService {

    private final CharacterRaceResourceRepository characterRaceResourceRepository;
    private final PlayerCharacterRepository characterRepository;
    private final RaceResourceRepository raceResourceRepository;
    private final CharacterFormulaService formulaService;

    public CharacterRaceResourceService(CharacterRaceResourceRepository characterRaceResourceRepository,
                                        PlayerCharacterRepository characterRepository,
                                        RaceResourceRepository raceResourceRepository,
                                        CharacterFormulaService formulaService) {
        this.characterRaceResourceRepository = characterRaceResourceRepository;
        this.characterRepository = characterRepository;
        this.raceResourceRepository = raceResourceRepository;
        this.formulaService = formulaService;
    }

    public List<CharacterRaceResourceDto> getCharacterResourcesDto(Long characterId) {
        return characterRaceResourceRepository.findByCharacterId(characterId).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public CharacterRaceResourceDto spendResourceDto(Long characterId, String resourceIndexName, int amount) {
        spendResource(characterId, resourceIndexName, amount);

        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        RaceResource raceResource = raceResourceRepository.findByIndexName(resourceIndexName)
                .orElseThrow(() -> new RuntimeException("Race resource not found: " + resourceIndexName));
        CharacterRaceResource crr = characterRaceResourceRepository
                .findByCharacterAndRaceResource(character, raceResource)
                .orElseThrow(() -> new RuntimeException("Character does not have this resource"));
        return toDto(crr);
    }

    @Transactional
    public CharacterRaceResourceDto recoverResourceDto(Long characterId, String resourceIndexName, int amount) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        RaceResource raceResource = raceResourceRepository.findByIndexName(resourceIndexName)
                .orElseThrow(() -> new RuntimeException("Race resource not found: " + resourceIndexName));
        CharacterRaceResource crr = characterRaceResourceRepository
                .findByCharacterAndRaceResource(character, raceResource)
                .orElseThrow(() -> new RuntimeException("Character does not have this resource"));

        int newAmount = Math.min(crr.getMaxAmount(), crr.getCurrentAmount() + amount);
        crr.setCurrentAmount(newAmount);
        characterRaceResourceRepository.save(crr);
        return toDto(crr);
    }

    @Transactional
    public void spendResource(Long characterId, String resourceIndexName, int amount) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        RaceResource raceResource = raceResourceRepository.findByIndexName(resourceIndexName)
                .orElseThrow(() -> new RuntimeException("Race resource not found: " + resourceIndexName));
        CharacterRaceResource crr = characterRaceResourceRepository
                .findByCharacterAndRaceResource(character, raceResource)
                .orElseThrow(() -> new RuntimeException("Character does not have this resource"));

        if (crr.getCurrentAmount() < amount) {
            throw new RuntimeException("Not enough " + raceResource.getName()
                    + ". Available: " + crr.getCurrentAmount() + ", needed: " + amount);
        }
        crr.setCurrentAmount(crr.getCurrentAmount() - amount);
        characterRaceResourceRepository.save(crr);
    }

    @Transactional
    public void initializeRaceResourcesForCharacter(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        if (character.getRace() == null) return;

        String subraceIndex = character.getSubrace() != null ? character.getSubrace().getIndexName() : null;

        List<RaceResource> resources = raceResourceRepository.findByRace(character.getRace()).stream()
                .filter(r -> r.getSubraceRestriction() == null || r.getSubraceRestriction().equals(subraceIndex))
                .collect(Collectors.toList());

        for (RaceResource resource : resources) {
            if (characterRaceResourceRepository.findByCharacterAndRaceResource(character, resource).isEmpty()) {
                int maxAmount = formulaService.evaluate(character, resource.getMaxFormula());
                characterRaceResourceRepository.save(new CharacterRaceResource(character, resource, maxAmount));
            }
        }
    }

    @Transactional
    public void recoverResources(Long characterId, String recoveryType) {
        List<CharacterRaceResource> resources = characterRaceResourceRepository
                .findByCharacterIdAndRecoveryType(characterId, recoveryType);
        for (CharacterRaceResource resource : resources) {
            resource.setCurrentAmount(resource.getMaxAmount());
            characterRaceResourceRepository.save(resource);
        }
    }

    @Transactional
    public void updateResourceMaximums(Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));
        List<CharacterRaceResource> resources = characterRaceResourceRepository.findByCharacter(character);
        for (CharacterRaceResource crr : resources) {
            int newMax = formulaService.evaluate(character, crr.getRaceResource().getMaxFormula());
            if (newMax > crr.getMaxAmount()) {
                int difference = newMax - crr.getMaxAmount();
                crr.setCurrentAmount(Math.min(newMax, crr.getCurrentAmount() + difference));
            }
            crr.setMaxAmount(newMax);
            characterRaceResourceRepository.save(crr);
        }
    }

    private CharacterRaceResourceDto toDto(CharacterRaceResource crr) {
        CharacterRaceResourceDto dto = new CharacterRaceResourceDto();
        dto.setId(crr.getId());
        dto.setCharacterId(crr.getCharacter().getId());
        dto.setCharacterName(crr.getCharacter().getName());
        dto.setClassResourceId(crr.getRaceResource().getId());
        dto.setResourceName(crr.getRaceResource().getName());
        dto.setResourceIndexName(crr.getRaceResource().getIndexName());
        dto.setMaxAmount(crr.getMaxAmount());
        dto.setCurrentAmount(crr.getCurrentAmount());
        dto.setRecoveryType(crr.getRaceResource().getRecoveryType());
        return dto;
    }
}
