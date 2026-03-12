package entities;

import enumeration.EffectModifierType;
import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "active_effects")
public class ActiveEffect {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name; // "Bless", "Rage", "Mage Armor", etc.
    
    @Column(unique = true)
    private String indexName;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    // Tipo(s) de modificador que aplica este efecto
    @ElementCollection(targetClass = EffectModifierType.class)
    @CollectionTable(name = "effect_modifiers", joinColumns = @JoinColumn(name = "effect_id"))
    @Column(name = "modifier_type")
    @Enumerated(EnumType.STRING)
    private List<EffectModifierType> modifierTypes;
    
    // Valor del modificador (puede ser "+2", "+1d4", "advantage", etc.)
    private String modifierValue;
    
    // Duración del efecto
    private String duration; // "1 minute", "8 hours", "Until long rest", "Concentration"
    
    // Si requiere concentración
    private boolean requiresConcentration;
    
    // Fuente del efecto (spell, class feature, item, etc.)
    private String source;
    
    // Condiciones específicas (ej: "only melee attacks", "only Strength checks")
    @Column(columnDefinition = "TEXT")
    private String conditions;

    public ActiveEffect() {}

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