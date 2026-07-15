package entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "class_resources")
public class ClassResource {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "class_id", nullable = false)
    private DndClass dndClass;

    private String name; // e.g., "Ki Points", "Rage", "Channel Divinity"

    private String indexName;

    @Column(columnDefinition = "TEXT")
    private String description;


    //Como se calcula el máximo (ej: level, level + modifier, proficiency bonus, etc)
    private String maxFormula;

    // Cuando se recupera: Short Rest, Long Rest, etc
    private String recoveryType;

    //Nivel de clase al que se desbloquea
    private int levelUnlocked;

    // Si no es null, el recurso solo se concede a personajes con esta subclase
    private String subclassRestriction;

    // Si no es null, el recurso solo se concede si el personaje tiene este valor entre sus
    // elecciones resueltas de una tarea multi-selección (p.ej. Rune Knight: solo se inicializa
    // "Cloud Rune" si el jugador la eligió entre sus runas conocidas). Formato
    // "HAS_MULTI_CHOICE:<taskType>:<valor>" -- mismo formato que NumericBonus.condition, resuelto
    // por el mismo PendingChoiceService. A diferencia de subclassRestriction (fijo por subclase),
    // esto depende de una elección del jugador dentro de esa subclase. Ver #8.2 RESOURCE_POOL.
    @Column(name = "requires_multi_choice")
    private String requiresMultiChoice;

    public ClassResource() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public DndClass getDndClass() {
        return dndClass;
    }

    public void setDndClass(DndClass dndClass) {
        this.dndClass = dndClass;
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

    public String getMaxFormula() {
        return maxFormula;
    }

    public void setMaxFormula(String maxFormula) {
        this.maxFormula = maxFormula;
    }

    public String getRecoveryType() {
        return recoveryType;
    }

    public void setRecoveryType(String recoveryType) {
        this.recoveryType = recoveryType;
    }

    public int getLevelUnlocked() {
        return levelUnlocked;
    }

    public void setLevelUnlocked(int levelUnlocked) {
        this.levelUnlocked = levelUnlocked;
    }

    public String getSubclassRestriction() {
        return subclassRestriction;
    }

    public void setSubclassRestriction(String subclassRestriction) {
        this.subclassRestriction = subclassRestriction;
    }

    public String getRequiresMultiChoice() {
        return requiresMultiChoice;
    }

    public void setRequiresMultiChoice(String requiresMultiChoice) {
        this.requiresMultiChoice = requiresMultiChoice;
    }
}
