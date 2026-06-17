package entities;

import jakarta.persistence.*;

/**
 * A spell automatically granted by a base class feature (not a subclass).
 * Mirrors SubclassSpell — see AuroraClassFeatureMapper for how rows are populated
 * from Aurora's nested &lt;grant type="Spell"&gt; rules, and ClassSpellService for
 * how they're applied to a character.
 */
@Entity
@Table(name = "class_granted_spells",
        uniqueConstraints = @UniqueConstraint(columnNames = {"dnd_class_id", "spell_id"}))
public class ClassSpell {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "dnd_class_id", nullable = false)
    private DndClass dndClass;

    @ManyToOne
    @JoinColumn(name = "spell_id", nullable = false)
    private Spell spell;

    @Column(name = "required_level", nullable = false)
    private int requiredLevel;

    public ClassSpell() {}

    public ClassSpell(DndClass dndClass, Spell spell, int requiredLevel) {
        this.dndClass = dndClass;
        this.spell = spell;
        this.requiredLevel = requiredLevel;
    }

    public Long getId() { return id; }

    public DndClass getDndClass() { return dndClass; }
    public void setDndClass(DndClass dndClass) { this.dndClass = dndClass; }

    public Spell getSpell() { return spell; }
    public void setSpell(Spell spell) { this.spell = spell; }

    public int getRequiredLevel() { return requiredLevel; }
    public void setRequiredLevel(int requiredLevel) { this.requiredLevel = requiredLevel; }
}
