package dto;

/**
 * #9: crea un RacialTrait junto con su mecánica (#8.2, generalizado a razas) atado a una Race
 * o una Subrace, en una sola llamada -- mismo patrón que SubclassFeatureAdminRequest.
 */
public class RacialTraitAdminRequest {

    // "RACE" | "SUBRACE"
    private String targetType;
    private Long targetId;

    private String indexName;
    private String name;
    private String description;
    // "COMBAT" | "PASSIVE" | "CHOICE_REQUIRED"
    private String traitType;

    // "NONE" | "RESOURCE_POOL" | "NUMERIC_BONUS" | "GRANT_SPELL" | "GRANT_PROFICIENCY"
    private String mechanicType;

    // RESOURCE_POOL
    private String resourceMaxFormula;
    private String resourceRecoveryType;

    // NUMERIC_BONUS
    private String bonusTargetField;
    private String bonusFormula;
    private String bonusCondition;

    // GRANT_SPELL
    private Long spellId;
    private int spellRequiredLevel = 1;

    // GRANT_PROFICIENCY
    private Long proficiencyId;

    public String getTargetType() { return targetType; }
    public void setTargetType(String targetType) { this.targetType = targetType; }

    public Long getTargetId() { return targetId; }
    public void setTargetId(Long targetId) { this.targetId = targetId; }

    public String getIndexName() { return indexName; }
    public void setIndexName(String indexName) { this.indexName = indexName; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getTraitType() { return traitType; }
    public void setTraitType(String traitType) { this.traitType = traitType; }

    public String getMechanicType() { return mechanicType; }
    public void setMechanicType(String mechanicType) { this.mechanicType = mechanicType; }

    public String getResourceMaxFormula() { return resourceMaxFormula; }
    public void setResourceMaxFormula(String resourceMaxFormula) { this.resourceMaxFormula = resourceMaxFormula; }

    public String getResourceRecoveryType() { return resourceRecoveryType; }
    public void setResourceRecoveryType(String resourceRecoveryType) { this.resourceRecoveryType = resourceRecoveryType; }

    public String getBonusTargetField() { return bonusTargetField; }
    public void setBonusTargetField(String bonusTargetField) { this.bonusTargetField = bonusTargetField; }

    public String getBonusFormula() { return bonusFormula; }
    public void setBonusFormula(String bonusFormula) { this.bonusFormula = bonusFormula; }

    public String getBonusCondition() { return bonusCondition; }
    public void setBonusCondition(String bonusCondition) { this.bonusCondition = bonusCondition; }

    public Long getSpellId() { return spellId; }
    public void setSpellId(Long spellId) { this.spellId = spellId; }

    public int getSpellRequiredLevel() { return spellRequiredLevel; }
    public void setSpellRequiredLevel(int spellRequiredLevel) { this.spellRequiredLevel = spellRequiredLevel; }

    public Long getProficiencyId() { return proficiencyId; }
    public void setProficiencyId(Long proficiencyId) { this.proficiencyId = proficiencyId; }
}
