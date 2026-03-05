package services;

import java.util.List;

import org.springframework.stereotype.Service;
import repositories.*;
import entities.CharacterSavingThrow;
import entities.CharacterSkill;
import entities.DndClass;
import entities.PlayerCharacter;
import entities.Skill;
import jakarta.transaction.Transactional;

@Service
public class CharacterSkillService {
    
    private final CharacterSkillRepository characterSkillRepository;
    private final CharacterSavingThrowRepository characterSavingThrowRepository;
    private final SkillRepository skillRepository;

    public CharacterSkillService(CharacterSkillRepository characterSkillRepository, CharacterSavingThrowRepository characterSavingThrowRepository, SkillRepository skillRepository) {
        this.characterSkillRepository = characterSkillRepository;
        this.characterSavingThrowRepository = characterSavingThrowRepository;
        this.skillRepository = skillRepository;
    }

    @Transactional
    public void initializeCharacterSkills(PlayerCharacter character){
        //Obtener todas las skills del catálogo
        List<Skill> allSkills = skillRepository.findAll();

        for(Skill skill: allSkills){
            CharacterSkill characterSkill = new CharacterSkill(character, skill);
            //Por defecto, el personaje no es competente ni tiene expertise en ninguna habilidad
            characterSkill.setProficient(false);
            characterSkill.setExpertise(false);

            characterSkillRepository.save(characterSkill);
        }

        System.out.println("Initialized " + allSkills.size() + " skills for character: " + character.getName());
    }

    @Transactional
    public void initializeSavingThrows(PlayerCharacter character){
        DndClass dndClass = character.getDndClass();

        String[] allAbilities = {"str", "dex", "con", "int", "wis", "cha"};

        for (String ability : allAbilities) {
            boolean proficient = dndClass.getSavingThrows() != null &&
                    dndClass.getSavingThrows().contains(ability);

            CharacterSavingThrow savingThrow = new CharacterSavingThrow(character, ability, proficient);
            savingThrowRepository.save(savingThrow);
        }

        System.out.println("Initialized saving throws for character: " + character.getName());
    }

    public List<CharacterSkill> getCharacterSkills(PlayerCharacter character){
        return characterSkillRepository.findByCharacter(character);
    }

    public List<CharacterSavingThrow> getCharacterSavingThrows(PlayerCharacter character){
        return characterSavingThrowRepository.findByCharacter(character);
    }

    @Transactional
    public void setSkillProficiency(Long characterId, Long skillId, boolean proficient) {
        CharacterSkill characterSkill = characterSkillRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character skill not found"));

        characterSkill.setProficient(proficient);
        characterSkillRepository.save(characterSkill);
    }

    @Transactional
    public void setSkillExpertise(Long characterId, Long skillId, boolean expertise) {
        CharacterSkill characterSkill = characterSkillRepository.findById(characterId)
                .orElseThrow(() -> new RuntimeException("Character skill not found"));

        characterSkill.setExpertise(expertise);
        characterSkillRepository.save(characterSkill);
    }

}
