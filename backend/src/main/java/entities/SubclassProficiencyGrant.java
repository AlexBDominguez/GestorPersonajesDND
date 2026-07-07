package entities;

import jakarta.persistence.*;

/**
 * A proficiency automatically granted by choosing a subclass (e.g. Oath of Vengeance →
 * heavy armor + martial weapons, Armorer → heavy armor). Mirrors RacialTraitProficiency —
 * see SubclassProficiencyService.applySubclassProficiencies() for how rows are applied.
 * Deliberately does not cover proficiency CHOICES (e.g. College of Lore's 3 extra skills,
 * Battle Master's tool/language pick) — those stay as PendingTask, a different mechanic
 * (a choice, not an automatic grant).
 */
@Entity
@Table(name = "subclass_proficiency_grants",
        uniqueConstraints = @UniqueConstraint(columnNames = {"subclass_id", "proficiency_id"}))
public class SubclassProficiencyGrant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "subclass_id", nullable = false)
    private Subclass subclass;

    @ManyToOne
    @JoinColumn(name = "proficiency_id", nullable = false)
    private Proficiency proficiency;

    public SubclassProficiencyGrant() {}

    public SubclassProficiencyGrant(Subclass subclass, Proficiency proficiency) {
        this.subclass = subclass;
        this.proficiency = proficiency;
    }

    public Long getId() { return id; }

    public Subclass getSubclass() { return subclass; }
    public void setSubclass(Subclass subclass) { this.subclass = subclass; }

    public Proficiency getProficiency() { return proficiency; }
    public void setProficiency(Proficiency proficiency) { this.proficiency = proficiency; }
}
