package entities;

import jakarta.persistence.*;

/**
 * A spell automatically granted by a racial trait (e.g. Drow Magic's Dancing Lights
 * at level 1, Faerie Fire at 3, Darkness at 5). Mirrors ClassSpell/SubclassSpell —
 * see AuroraRaceMapper for how rows are populated and RacialTraitService for how
 * they're applied to a character.
 */
@Entity
@Table(name = "racial_trait_spells",
        uniqueConstraints = @UniqueConstraint(columnNames = {"racial_trait_id", "spell_id"}))
public class RacialTraitSpell {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "racial_trait_id", nullable = false)
    private RacialTrait racialTrait;

    @ManyToOne
    @JoinColumn(name = "spell_id", nullable = false)
    private Spell spell;

    @Column(name = "required_level", nullable = false)
    private int requiredLevel;

    public RacialTraitSpell() {}

    public RacialTraitSpell(RacialTrait racialTrait, Spell spell, int requiredLevel) {
        this.racialTrait = racialTrait;
        this.spell = spell;
        this.requiredLevel = requiredLevel;
    }

    public Long getId() { return id; }

    public RacialTrait getRacialTrait() { return racialTrait; }
    public void setRacialTrait(RacialTrait racialTrait) { this.racialTrait = racialTrait; }

    public Spell getSpell() { return spell; }
    public void setSpell(Spell spell) { this.spell = spell; }

    public int getRequiredLevel() { return requiredLevel; }
    public void setRequiredLevel(int requiredLevel) { this.requiredLevel = requiredLevel; }
}
