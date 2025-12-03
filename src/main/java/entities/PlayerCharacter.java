package entities;

import jakarta.persistence.*;

import java.util.Map;

@Entity
@Table(name = "characters")
public class PlayerCharacter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private int level;

    @ManyToOne
    @JoinColumn(name = "race_id")
    private Race race;

    @ManyToOne
    @JoinColumn(name = "class_id")
    private DndClass dndClass;

    @ElementCollection
    @CollectionTable(name = "character_abilities", joinColumns = @JoinColumn(name = "character_id"))
    @MapKeyColumn(name = "ability")
    @Column(name = "score")
    private Map<String, Integer> abilityScores;

    private int maxHP;
    private int currentHP;

    private int proficiencyBonus;

    @Column(columnDefinition = "TEXT")
    private String backstory;

    public PlayerCharacter(){}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public Race getRace() {
        return race;
    }

    public void setRace(Race race) {
        this.race = race;
    }

    public DndClass getDndClass() {
        return dndClass;
    }

    public void setDndClass(DndClass dndClass) {
        this.dndClass = dndClass;
    }

    public Map<String, Integer> getAbilityScores() {
        return abilityScores;
    }

    public void setAbilityScores(Map<String, Integer> abilityScores) {
        this.abilityScores = abilityScores;
    }

    public int getMaxHP() {
        return maxHP;
    }

    public void setMaxHP(int maxHP) {
        this.maxHP = maxHP;
    }

    public int getCurrentHP() {
        return currentHP;
    }

    public void setCurrentHP(int currentHP) {
        this.currentHP = currentHP;
    }

    public int getProficiencyBonus() {
        return proficiencyBonus;
    }

    public void setProficiencyBonus(int proficiencyBonus) {
        this.proficiencyBonus = proficiencyBonus;
    }

    public String getBackstory() {
        return backstory;
    }

    public void setBackstory(String backstory) {
        this.backstory = backstory;
    }
}
