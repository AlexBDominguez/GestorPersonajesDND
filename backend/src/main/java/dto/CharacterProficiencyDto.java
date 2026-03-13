package dto;

import enumeration.ProficiencyType;

public class CharacterProficiencyDto {
    private Long id;
    private Long characterId;
    private String characterName;
    private Long proficiencyId;
    private String proficiencyName;
    private ProficiencyType proficiencyType;
    private String category;
    private String source;
    private String notes;


    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public Long getCharacterId() {
        return characterId;
    }
    public void setCharacterId(Long characterId) {
        this.characterId = characterId;
    }
    public String getCharacterName() {
        return characterName;
    }
    public void setCharacterName(String characterName) {
        this.characterName = characterName;
    }
    public Long getProficiencyId() {
        return proficiencyId;
    }
    public void setProficiencyId(Long proficiencyId) {
        this.proficiencyId = proficiencyId;
    }
    public String getProficiencyName() {
        return proficiencyName;
    }
    public void setProficiencyName(String proficiencyName) {
        this.proficiencyName = proficiencyName;
    }
    public ProficiencyType getProficiencyType() {
        return proficiencyType;
    }
    public void setProficiencyType(ProficiencyType proficiencyType) {
        this.proficiencyType = proficiencyType;
    }
    public String getCategory() {
        return category;
    }
    public void setCategory(String category) {
        this.category = category;
    }
    public String getSource() {
        return source;
    }
    public void setSource(String source) {
        this.source = source;
    }
    public String getNotes() {
        return notes;
    }
    public void setNotes(String notes) {
        this.notes = notes;
    }

    
    
}
