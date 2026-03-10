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
@Table(name = "character_feats")
public class CharacterFeat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "feat_id", nullable = false)
    private Feat feat;


    //Nivel al que se obtuvo el feat
    private int levelObtained;

    //Notas adicionales (por si el feat tiene opciones)
    @Column(columnDefinition = "TEXT")
    private String notes;


    public CharacterFeat() {}

    public CharacterFeat(PlayerCharacter character,
                            Feat feat,
                            int levelObtained){
        this.character = character;
        this.feat = feat;
        this.levelObtained = levelObtained;            
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

    public Feat getFeat() {
        return feat;
    }

    public void setFeat(Feat feat) {
        this.feat = feat;
    }

    public int getLevelObtained() {
        return levelObtained;
    }

    public void setLevelObtained(int levelObtained) {
        this.levelObtained = levelObtained;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    
    

}
