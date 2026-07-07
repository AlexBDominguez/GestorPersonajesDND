package entities;

import jakarta.persistence.*;

/**
 * A proficiency automatically granted by a racial trait (e.g. Dwarven Armor Training →
 * heavy armor, Drow Weapon Training → rapier/shortsword/hand crossbow). Mirrors
 * RacialTraitSpell — see RacialTraitService for how rows are applied to a character.
 * No required-level column: unlike some racial spells (Drow Magic), the racial trait
 * proficiencies seeded so far are all present from character creation.
 */
@Entity
@Table(name = "racial_trait_proficiencies",
        uniqueConstraints = @UniqueConstraint(columnNames = {"racial_trait_id", "proficiency_id"}))
public class RacialTraitProficiency {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "racial_trait_id", nullable = false)
    private RacialTrait racialTrait;

    @ManyToOne
    @JoinColumn(name = "proficiency_id", nullable = false)
    private Proficiency proficiency;

    public RacialTraitProficiency() {}

    public RacialTraitProficiency(RacialTrait racialTrait, Proficiency proficiency) {
        this.racialTrait = racialTrait;
        this.proficiency = proficiency;
    }

    public Long getId() { return id; }

    public RacialTrait getRacialTrait() { return racialTrait; }
    public void setRacialTrait(RacialTrait racialTrait) { this.racialTrait = racialTrait; }

    public Proficiency getProficiency() { return proficiency; }
    public void setProficiency(Proficiency proficiency) { this.proficiency = proficiency; }
}
