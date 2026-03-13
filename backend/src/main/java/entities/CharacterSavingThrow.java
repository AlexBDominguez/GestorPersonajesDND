package entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

@Entity
@Table(name = "character_saving_throws")
public class CharacterSavingThrow {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    private String abilityScore;

    private boolean proficient;

    public CharacterSavingThrow() {}

    public CharacterSavingThrow(PlayerCharacter character, String abilityScore){
        this.character = character;
        this.abilityScore = abilityScore;
        this.proficient = false;
    }

    //Método para calcular el bonus total
    @Transient
    public int getBonus(){
        if(character == null || abilityScore == null) return 0;

        int abilityMod = character.calculateAbilityModifier(abilityScore);
        int profBonus = proficient ? character.getProficiencyBonus() : 0;

        return abilityMod + profBonus;
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

    public String getAbilityScore() {
        return abilityScore;
    }

    public void setAbilityScore(String abilityScore) {
        this.abilityScore = abilityScore;
    }

    public boolean isProficient() {
        return proficient;
    }

    public void setProficient(boolean proficient) {
        this.proficient = proficient;
    }

    
    
}