package entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

/**
 * #9/#8.2 RESOURCE_POOL for racial traits -- mirrors ClassResource, but tied to a Race
 * instead of a DndClass. Added because no race trait had ever needed a limited-use resource
 * before (unlike class features, which almost always do) -- a homebrew race with something
 * like a breath weapon or a limited-use innate spell-like ability needs the same "usesLeft /
 * maxUses, recovers on X rest" shape a class resource has, and there was previously nowhere
 * to put that data. See RacialTrait.consumesResourceIndexName and Aurora_Fixes.md #9.
 */
@Entity
@Table(name = "race_resources")
public class RaceResource {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "race_id", nullable = false)
    private Race race;

    private String name;

    @Column(unique = true)
    private String indexName;

    @Column(columnDefinition = "TEXT")
    private String description;

    // Misma DSL que ClassResource.maxFormula, evaluada por CharacterFormulaService.
    private String maxFormula;

    private String recoveryType;

    // Si no es null, el recurso solo se concede a personajes con esta subraza -- mismo
    // propósito que ClassResource.subclassRestriction, pero para subrazas.
    private String subraceRestriction;

    public RaceResource() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Race getRace() { return race; }
    public void setRace(Race race) { this.race = race; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getIndexName() { return indexName; }
    public void setIndexName(String indexName) { this.indexName = indexName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getMaxFormula() { return maxFormula; }
    public void setMaxFormula(String maxFormula) { this.maxFormula = maxFormula; }

    public String getRecoveryType() { return recoveryType; }
    public void setRecoveryType(String recoveryType) { this.recoveryType = recoveryType; }

    public String getSubraceRestriction() { return subraceRestriction; }
    public void setSubraceRestriction(String subraceRestriction) { this.subraceRestriction = subraceRestriction; }
}
