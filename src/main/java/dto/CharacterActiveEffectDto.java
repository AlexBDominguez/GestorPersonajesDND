package dto;

import java.time.LocalDateTime;

public class CharacterActiveEffectDto {
    private Long id;
    private Long characterId;
    private String characterName;
    private Long effectId;
    private String effectName;
    private String effectDescription;
    private String modifierValue;
    private String duration;
    private boolean requiresConcentration;
    private boolean active;
    private LocalDateTime appliedAt;
    private Integer remainingRounds;
    private Integer casterLevel;
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

    public Long getEffectId() {
        return effectId;
    }

    public void setEffectId(Long effectId) {
        this.effectId = effectId;
    }

    public String getEffectName() {
        return effectName;
    }

    public void setEffectName(String effectName) {
        this.effectName = effectName;
    }

    public String getEffectDescription() {
        return effectDescription;
    }

    public void setEffectDescription(String effectDescription) {
        this.effectDescription = effectDescription;
    }

    public String getModifierValue() {
        return modifierValue;
    }

    public void setModifierValue(String modifierValue) {
        this.modifierValue = modifierValue;
    }

    public String getDuration() {
        return duration;
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }

    public boolean isRequiresConcentration() {
        return requiresConcentration;
    }

    public void setRequiresConcentration(boolean requiresConcentration) {
        this.requiresConcentration = requiresConcentration;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public LocalDateTime getAppliedAt() {
        return appliedAt;
    }

    public void setAppliedAt(LocalDateTime appliedAt) {
        this.appliedAt = appliedAt;
    }

    public Integer getRemainingRounds() {
        return remainingRounds;
    }

    public void setRemainingRounds(Integer remainingRounds) {
        this.remainingRounds = remainingRounds;
    }

    public Integer getCasterLevel() {
        return casterLevel;
    }

    public void setCasterLevel(Integer casterLevel) {
        this.casterLevel = casterLevel;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}