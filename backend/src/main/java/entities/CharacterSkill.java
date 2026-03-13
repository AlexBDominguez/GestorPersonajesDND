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
@Table(name = "character_skills")
public class CharacterSkill {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "skill_id", nullable = false)
    private Skill skill;

    private boolean proficient;

    private boolean expertise; //Para Rogues/Bards, la doble proficiency

    public CharacterSkill(){}

    public CharacterSkill(PlayerCharacter character, Skill skill){
        this.character = character;
        this.skill = skill;
        this.proficient = false;
        this.expertise = false;
    }

    //Método para calcular el bonus total
    @Transient
    public int getBonus(){
        if(character == null || skill == null) return 0;

        int abilityMod = character.calculateAbilityModifier(skill.getAbilityScore());
        int profBonus = 0;

        if(proficient) {
            profBonus = character.getProficiencyBonus();            
        }

        if(expertise) {
            profBonus += character.getProficiencyBonus(); // Doble proficiency
        }

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

    public Skill getSkill() {
        return skill;
    }

    public void setSkill(Skill skill) {
        this.skill = skill;
    }

    public boolean isProficient() {
        return proficient;
    }

    public void setProficient(boolean proficient) {
        this.proficient = proficient;
    }

    public boolean isExpertise() {
        return expertise;
    }

    public void setExpertise(boolean expertise) {
        this.expertise = expertise;
    }

    




}
