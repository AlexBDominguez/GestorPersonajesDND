package dto;

/**
 * Petición del panel de admin (#9) para crear una SubclassFeature junto con su mecánica
 * (#8.2: RESOURCE_POOL / NUMERIC_BONUS / GRANT_SPELL / GRANT_PROFICIENCY), en una sola llamada.
 * Solo los campos relevantes al mechanicType elegido se usan; el resto se ignora.
 */
public class SubclassFeatureAdminRequest {

    private String indexName;
    private String name;
    private int level;
    private String description;

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

    // GRANT_PROFICIENCY
    private Long proficiencyId;

    public String getIndexName() { return indexName; }
    public void setIndexName(String indexName) { this.indexName = indexName; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getLevel() { return level; }
    public void setLevel(int level) { this.level = level; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

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

    public Long getProficiencyId() { return proficiencyId; }
    public void setProficiencyId(Long proficiencyId) { this.proficiencyId = proficiencyId; }
}
