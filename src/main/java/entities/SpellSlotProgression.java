package entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

public class SpellSlotProgression {
    
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
        private int spellLevel1;
        private int int slots;

        //Getters and Setters
        
        
        

    }

}
