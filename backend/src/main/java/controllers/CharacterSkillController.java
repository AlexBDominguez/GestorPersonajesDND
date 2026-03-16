package controllers;

import dto.CharacterSkillDto;
import dto.CharacterSavingThrowDto;
import entities.CharacterSavingThrow;
import entities.CharacterSkill;
import entities.PlayerCharacter;
import org.springframework.web.bind.annotation.*;
import repositories.PlayerCharacterRepository;
import services.CharacterSkillService;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/characters/{characterId}")
public class CharacterSkillController {

    private final CharacterSkillService characterSkillService;
    private final PlayerCharacterRepository characterRepository;

    public CharacterSkillController(CharacterSkillService characterSkillService,
                                   PlayerCharacterRepository characterRepository) {
        this.characterSkillService = characterSkillService;
        this.characterRepository = characterRepository;
    }

    @GetMapping("/skills")
    public List<CharacterSkillDto> getSkills(@PathVariable Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        List<CharacterSkill> skills = characterSkillService.getCharacterSkills(character);

        return skills.stream().map(skill -> {
            CharacterSkillDto dto = new CharacterSkillDto();
            dto.setId(skill.getId());
            dto.setSkillName(skill.getSkill().getName());
            dto.setAbilityScore(skill.getSkill().getAbilityScore());
            dto.setProficient(skill.isProficient());
            dto.setExpertise(skill.isExpertise());
            dto.setBonus(skill.getBonus());
            return dto;
        }).collect(Collectors.toList());
    }

    @GetMapping("/saving-throws")
    public List<CharacterSavingThrowDto> getSavingThrows(@PathVariable Long characterId) {
        PlayerCharacter character = characterRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character not found"));

        List<CharacterSavingThrow> savingThrows = characterSkillService.getCharacterSavingThrows(character);

        return savingThrows.stream().map(st -> {
            CharacterSavingThrowDto dto = new CharacterSavingThrowDto();
            dto.setId(st.getId());
            dto.setAbilityScore(st.getAbilityScore());
            dto.setProficient(st.isProficient());
            dto.setBonus(st.getBonus());
            return dto;
        }).collect(Collectors.toList());
    }

    @PutMapping("/skills/{skillId}/proficiency")
    public void setSkillProficiency(@PathVariable Long characterId,
                                   @PathVariable Long skillId,
                                   @RequestParam boolean proficient) {
        characterSkillService.setSkillProficiency(skillId, skillId, proficient);
    }

    @PutMapping("/skills/{skillId}/expertise")
    public void setSkillExpertise(@PathVariable Long characterId,
                                  @PathVariable Long skillId,
                                  @RequestParam boolean expertise) {
        characterSkillService.setSkillExpertise(skillId, skillId, expertise);
    }
}