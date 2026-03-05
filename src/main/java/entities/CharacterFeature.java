package entities;

import jakarta.annotation.Generated;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "character_features")
public class CharacterFeature {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "class_feature_id", nullable = false)
    private ClassFeature classFeature;

    private int levelObtained;

    @Column(columnDefinition = "TEXT")
        private String notes;
    

    public CharacterFeature(){}

    public CharacterFeature(PlayerCharacter character, ClassFeature classFeature, int levelObtained){
        this.character = character;
        this.classFeature = classFeature;
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

    public ClassFeature getClassFeature() {
        return classFeature;
    }

    public void setClassFeature(ClassFeature classFeature) {
        this.classFeature = classFeature;
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
