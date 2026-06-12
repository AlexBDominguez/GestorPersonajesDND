package entities;

import jakarta.persistence.*;

@Entity
@Table(name = "subclass_spells",
        uniqueConstraints = @UniqueConstraint(columnNames = {"subclass_id", "spell_id"}))
public class SubclassSpell {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "subclass_id", nullable = false)
    private Subclass subclass;

    @ManyToOne
    @JoinColumn(name = "spell_id", nullable = false)
    private Spell spell;

    @Column(name = "required_level", nullable = false)
    private int requiredLevel;

    public SubclassSpell() {}

    public SubclassSpell(Subclass subclass, Spell spell, int requiredLevel) {
        this.subclass = subclass;
        this.spell = spell;
        this.requiredLevel = requiredLevel;
    }

    public Long getId() { return id; }

    public Subclass getSubclass() { return subclass; }
    public void setSubclass(Subclass subclass) { this.subclass = subclass; }

    public Spell getSpell() { return spell; }
    public void setSpell(Spell spell) { this.spell = spell; }

    public int getRequiredLevel() { return requiredLevel; }
    public void setRequiredLevel(int requiredLevel) { this.requiredLevel = requiredLevel; }
}
