package entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;

@Entity
public class LevelUpTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private PlayerCharacter character;

    private int targetLevel;

    private String type;
    //HP_CHOICE
    //SPELL_SELECTION
    //SUBCLASS_CHOICE
    //ASI_CHOICE O)R FEAT_CHOICE

    private boolean completed;

    @Column(columnDefinition = "TEXT")
    private String metadata; // JSON con detalles específicos de la tarea (e.g., opciones de hechizos, ASI, etc.)
    
}
