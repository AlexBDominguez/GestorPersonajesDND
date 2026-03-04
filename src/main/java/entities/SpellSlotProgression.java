package entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "spell_slot_progression")
public class SpellSlotProgression {
    

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "class_id")
    private DndClass dndClass;

    private int characterLevel;
    private int spellLevel;
    private int slots;


    //Getters and Setters

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
    public int getCharacterLevel() {
        return characterLevel;
    }
    public void setCharacterLevel(int characterLevel) {
        this.characterLevel = characterLevel;
    }
    public int getSpellLevel() {
        return spellLevel;
    }
    public void setSpellLevel(int spellLevel) {
        this.spellLevel = spellLevel;
    }
    public int getSlots() {
        return slots;
    }
    public void setSlots(int slots) {
        this.slots = slots;
    }

    
        
        
        

    

}
