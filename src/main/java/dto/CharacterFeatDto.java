package dto;

public class CharacterFeatDto {
    private Long id;
    private Long characterId;
    private String characterName;
    private Long featId;
    private String featName;
    private String featDescription;
    private int levelObtained;
    private String notes;

    // Getters y Setters
    
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

    public Long getFeatId() {
        return featId;
    }

    public void setFeatId(Long featId) {
        this.featId = featId;
    }

    public String getFeatName() {
        return featName;
    }

    public void setFeatName(String featName) {
        this.featName = featName;
    }

    public String getFeatDescription() {
        return featDescription;
    }

    public void setFeatDescription(String featDescription) {
        this.featDescription = featDescription;
    }

    public int getLevelObtained() {
        return levelObtained;
    }

    public void setLevelObtained(int levelObtained) {
        this.levelObtained = levelObtained;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}