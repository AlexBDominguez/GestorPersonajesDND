package dto;

/**
 * #9: crea una ClassFeature (clase base, no subclase) junto con su mecánica (#8.2) en una sola
 * llamada. Mirrors SubclassFeatureAdminRequest.
 *
 * A diferencia de las features de subclase, GRANT_PROFICIENCY no está soportado aquí: no existe
 * ninguna tabla de "otorgamiento de competencia por feature de clase base" en el esquema (las
 * competencias de clase son la lista estática DndClass.proficiencies, no un grant por feature) --
 * ver AdminClassFeatureService.
 */
public class ClassFeatureAdminRequest {

    private String indexName;
    private String name;
    private int level;
    private String description;

    // "NONE" | "RESOURCE_POOL" | "NUMERIC_BONUS" | "GRANT_SPELL"
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
}
