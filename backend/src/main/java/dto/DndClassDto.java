package dto;

import java.util.List;

public class DndClassDto {

    private Long id;
    private String indexName;
    private String name;
    private int hitDie;
    private List<String> proficiencies;
    private String description;
    private String spellcastingAbility;
    private int skillChoiceCount;
    private List<String> allowedSkillIndices;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getIndexName() {
        return indexName;
    }

    public void setIndexName(String indexName) {
        this.indexName = indexName;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getHitDie() {
        return hitDie;
    }

    public void setHitDie(int hitDie) {
        this.hitDie = hitDie;
    }

    public List<String> getProficiencies() {
        return proficiencies;
    }

    public void setProficiencies(List<String> proficiencies) {
        this.proficiencies = proficiencies;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getSpellcastingAbility() {
        return spellcastingAbility;
    }

    public void setSpellcastingAbility(String spellcastingAbility) {
        this.spellcastingAbility = spellcastingAbility;
    }

    public int getSkillChoiceCount() {
        return skillChoiceCount;
    }

    public void setSkillChoiceCount(int skillChoiceCount) {
        this.skillChoiceCount = skillChoiceCount;
    }

    public List<String> getAllowedSkillIndices() {
        return allowedSkillIndices;
    }

    public void setAllowedSkillIndices(List<String> allowedSkillIndices) {
        this.allowedSkillIndices = allowedSkillIndices;
    }
}
