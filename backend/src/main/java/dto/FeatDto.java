package dto;

import java.util.List;

import enumeration.EffectModifierType;

public class FeatDto {
    private Long id;
    private String indexName;
    private String name;
    private String description;
    private List<String> prerequisites;

    // Bono numérico genérico de fallback (ver Feat.java) -- ausentes de este DTO hasta ahora
    // pese a que Feat ya los soporta. Necesarios para que un feat creado a mano en el panel de
    // admin (#9) pueda tener efecto real, no solo texto descriptivo.
    private EffectModifierType effectModifierType;
    private String effectModifierValue;
    private Integer choiceProficiencyCount;
    private List<Long> grantedSpellIds;


    
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
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public List<String> getPrerequisites() {
        return prerequisites;
    }
    public void setPrerequisites(List<String> prerequisites) {
        this.prerequisites = prerequisites;
    }

    public EffectModifierType getEffectModifierType() { return effectModifierType; }
    public void setEffectModifierType(EffectModifierType effectModifierType) { this.effectModifierType = effectModifierType; }

    public String getEffectModifierValue() { return effectModifierValue; }
    public void setEffectModifierValue(String effectModifierValue) { this.effectModifierValue = effectModifierValue; }

    public Integer getChoiceProficiencyCount() { return choiceProficiencyCount; }
    public void setChoiceProficiencyCount(Integer choiceProficiencyCount) { this.choiceProficiencyCount = choiceProficiencyCount; }

    public List<Long> getGrantedSpellIds() { return grantedSpellIds; }
    public void setGrantedSpellIds(List<Long> grantedSpellIds) { this.grantedSpellIds = grantedSpellIds; }
}
