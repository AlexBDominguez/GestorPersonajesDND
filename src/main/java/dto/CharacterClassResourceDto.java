package dto;

public class CharacterClassResourceDto {

    private Long id;
    private Long characterId;
    private String characterName;
    private Long classResourceId;
    private String resourceName;
    private String resourceIndexName;
    private int maxAmount;
    private int currentAmount;
    private String recoveryType;


    
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
    public Long getClassResourceId() {
        return classResourceId;
    }
    public void setClassResourceId(Long classResourceId) {
        this.classResourceId = classResourceId;
    }
    public String getResourceName() {
        return resourceName;
    }
    public void setResourceName(String resourceName) {
        this.resourceName = resourceName;
    }
    public String getResourceIndexName() {
        return resourceIndexName;
    }
    public void setResourceIndexName(String resourceIndexName) {
        this.resourceIndexName = resourceIndexName;
    }
    public int getMaxAmount() {
        return maxAmount;
    }
    public void setMaxAmount(int maxAmount) {
        this.maxAmount = maxAmount;
    }
    public int getCurrentAmount() {
        return currentAmount;
    }
    public void setCurrentAmount(int currentAmount) {
        this.currentAmount = currentAmount;
    }
    public String getRecoveryType() {
        return recoveryType;
    }
    public void setRecoveryType(String recoveryType) {
        this.recoveryType = recoveryType;
    }

    //Getters and Setters

    
    
}
