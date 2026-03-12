package dto;

import enumeration.EffectModifierType;
import java.util.List;

public class ActiveEffectDto {
    private Long id;
    private String name;
    private String indexName;
    private String description;
    private List<EffectModifierType> modifierTypes;
    private String modifierValue;
    private String duration;
    private boolean requiresConcentration;
    private String source;
    private String conditions;

    // Getters y Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIndexName() {
        return indexName;
    }

    public void setIndexName(String indexName) {
        this.indexName = indexName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<EffectModifierType> getModifierTypes() {
        return modifierTypes;
    }

    public void setModifierTypes(List<EffectModifierType> modifierTypes) {
        this.modifierTypes = modifierTypes;
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

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getConditions() {
        return conditions;
    }

    public void setConditions(String conditions) {
        this.conditions = conditions;
    }
}