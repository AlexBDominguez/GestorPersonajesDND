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
@Table(name = "character_spells")
public class CharacterSpell {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "spell_id", nullable = false)
    private Spell spell;

    private boolean prepared;
    private boolean learned;
    private int timesCast;

    //Origen del hechizo: "CLASS", "SUBCLASS", "RACE", "FEAT"
    @Column(name = "spell_source", length = 20)
    private String spellSource;

    public CharacterSpell() {}

    public CharacterSpell(PlayerCharacter character, Spell spell){
        this.character = character;
        this.spell = spell;
        this.learned = true;
        this.prepared = true;
        this.timesCast = 0;
        this.spellSource = "CLASS"; //Por defecto para compatibilidad con código existente
    }

    //Constructor con fuente explicita
    public CharacterSpell(PlayerCharacter character, Spell spell, String spellSource){
        this.character = character;
        this.spell = spell;
        this.learned = true;
        this.prepared = true;
        this.timesCast = 0;
        this.spellSource = spellSource;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public PlayerCharacter getCharacter() {
        return character;
    }

    public void setCharacter(PlayerCharacter character) {
        this.character = character;
    }

    public Spell getSpell() {
        return spell;
    }

    public void setSpell(Spell spell) {
        this.spell = spell;
    }

    public boolean isPrepared() {
        return prepared;
    }

    public void setPrepared(boolean prepared) {
        this.prepared = prepared;
    }

    public boolean isLearned() {
        return learned;
    }

    public void setLearned(boolean learned) {
        this.learned = learned;
    }

    public int getTimesCast() {
        return timesCast;
    }

    public void setTimesCast(int timesCast) {
        this.timesCast = timesCast;
    }

    public String getSpellSource() {
        return spellSource;
    }

    public void setSpellSource(String spellSource) {
        this.spellSource = spellSource;
    }

    
    
}
