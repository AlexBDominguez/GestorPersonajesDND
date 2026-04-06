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

            CharacterSavingThrow savingThrow = new CharacterSavingThrow(character, ability);
            savingThrow.setProficient(proficient);
            characterSavingThrowRepository.save(savingThrow);
        }

        System.out.println("Initialized saving throws for character: " + character.getName());
    }

    public List<CharacterSkill> getCharacterSkills(PlayerCharacter character){
        return characterSkillRepository.findByCharacter(character);
    }

    @Transactional
    public List<CharacterSavingThrow> getCharacterSavingThrows(PlayerCharacter character){
        List<CharacterSavingThrow> existing = characterSavingThrowRepository.findByCharacter(character);
        if (existing.isEmpty()) {
            // Personaje creado antes de que se implementaran las saving throws: inicializar ahora
            initializeSavingThrows(character);
            return characterSavingThrowRepository.findByCharacter(character);
        }
        return existing;
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


    @Transactional
public void applySkillProficiencyByIndex(PlayerCharacter character, String skillIndex) {
    // Background skill proficiencies arrive as e.g. "skill-insight" from the API,
    // but the skills table stores index_name without the "skill-" prefix.
    String normalizedIndex = skillIndex.startsWith("skill-") ? skillIndex.substring(6) : skillIndex;
    Skill skill = skillRepository.findByIndexName(normalizedIndex)
            .orElseThrow(() -> new RuntimeException("Skill not found: " + normalizedIndex));

    List<CharacterSkill> characterSkills = characterSkillRepository.findByCharacter(character);

    for (CharacterSkill cs : characterSkills) {
        if (cs.getSkill().getId().equals(skill.getId())) {
            cs.setProficient(true);
            characterSkillRepository.save(cs);
            System.out.println("Applied skill proficiency: " + skill.getName() + " (from background)");
            break;
        }
    }
}

}
