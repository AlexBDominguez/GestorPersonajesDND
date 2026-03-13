package dto;

import java.time.LocalDateTime;

public class CharacterConditionDto {
    private Long id;
    private Long characterId;
    private String characterName;
    private Long conditionId;
    private String conditionName;
    private Integer durationRounds;
    private Integer remainingRounds;
    private boolean hasSavingThrow;
    private Integer savingThrowDC;
    private String savingThrowAbility;
    private String source;
    private String notes;
    private LocalDateTime appliedAt;
    private boolean active;

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

    public Long getConditionId() {
        return conditionId;
    }

    public void setConditionId(Long conditionId) {
        this.conditionId = conditionId;
    }

    public String getConditionName() {
        return conditionName;
    }

    public void setConditionName(String conditionName) {
        this.conditionName = conditionName;
    }

    public Integer getDurationRounds() {
        return durationRounds;
    }

    public void setDurationRounds(Integer durationRounds) {
        this.durationRounds = durationRounds;
    }

    public Integer getRemainingRounds() {
        return remainingRounds;
    }

    public void setRemainingRounds(Integer remainingRounds) {
        this.remainingRounds = remainingRounds;
    }

    public boolean isHasSavingThrow() {
        return hasSavingThrow;
    }

    public void setHasSavingThrow(boolean hasSavingThrow) {
        this.hasSavingThrow = hasSavingThrow;
    }

    public Integer getSavingThrowDC() {
        return savingThrowDC;
    }

    public void setSavingThrowDC(Integer savingThrowDC) {
        this.savingThrowDC = savingThrowDC;
    }

    public String getSavingThrowAbility() {
        return savingThrowAbility;
    }

    public void setSavingThrowAbility(String savingThrowAbility) {
        this.savingThrowAbility = savingThrowAbility;
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

    public LocalDateTime getAppliedAt() {
        return appliedAt;
    }

    public void setAppliedAt(LocalDateTime appliedAt) {
        this.appliedAt = appliedAt;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}