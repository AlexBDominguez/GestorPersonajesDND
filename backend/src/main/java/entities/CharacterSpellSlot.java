package entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "character_spell_slots")
public class CharacterSpellSlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id")
    private PlayerCharacter character;
    
    private int spellLevel;
    private int maxSlots;
    private int usedSlots;


    // Getters and Setters
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
    public int getSpellLevel() {
        return spellLevel;
    }
    public void setSpellLevel(int spellLevel) {
        this.spellLevel = spellLevel;
    }
    public int getMaxSlots() {
        return maxSlots;
    }
    public void setMaxSlots(int maxSlots) {
        this.maxSlots = maxSlots;
    }
    public int getUsedSlots() {
        return usedSlots;
    }
    public void setUsedSlots(int usedSlots) {
        this.usedSlots = usedSlots;
    }

    
    
    
    
}
