package dto;

import enumeration.DamageRelationType;

public class CharacterDamageRelationDto {
    private Long id;
    private Long characterId;
    private String characterName;
    private Long damageTypeId;
    private String damageTypeName;
    private DamageRelationType relationType;
    private String source;
    private boolean temporary;
    private String conditions;
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

    public Long getDamageTypeId() {
        return damageTypeId;
    }

    public void setDamageTypeId(Long damageTypeId) {
        this.damageTypeId = damageTypeId;
    }

    public String getDamageTypeName() {
        return damageTypeName;
    }

    public void setDamageTypeName(String damageTypeName) {
        this.damageTypeName = damageTypeName;
    }

    public DamageRelationType getRelationType() {
        return relationType;
    }

    public void setRelationType(DamageRelationType relationType) {
        this.relationType = relationType;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public boolean isTemporary() {
        return temporary;
    }

    public void setTemporary(boolean temporary) {
        this.temporary = temporary;
    }

    public String getConditions() {
        return conditions;
    }

    public void setConditions(String conditions) {
        this.conditions = conditions;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}