package entities;

import jakarta.persistence.*;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "classes")
public class DndClass {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String indexName;
    
    private String name;
    private int hitDie;

    @ElementCollection
    @CollectionTable(name = "class_proficiencies", joinColumns = @JoinColumn(name = "class_id"))
    @Column(name = "proficiency")
    private List<String> proficiencies;

    // Skill choices at character creation
    @ElementCollection
    @CollectionTable(name = "class_skill_choices", joinColumns = @JoinColumn(name = "class_id"))
    @Column(name = "skill_index")
    private List<String> skillChoiceOptions;

    @Column(name = "num_skill_choices")
    private int numSkillChoices;

    //Saving Throws
    @ElementCollection
    @CollectionTable(name = "class_saving_throws", joinColumns = @JoinColumn(name = "class_id"))
    @Column(name = "saving_throw")
    private List<String> savingThrows;

    //SpellCasting
    private String spellcastingAbility;

    //Nivel al que se elige subclase
    private Integer subclassLevel;


    @Column(columnDefinition = "TEXT")
    private String description;

    @ManyToMany
    @JoinTable(
        name = "class_spells",
        joinColumns = @JoinColumn(name = "class_id"),
        inverseJoinColumns = @JoinColumn(name = "spell_id")
    )
    private Set<Spell> spells = new HashSet<>();

    public DndClass(){

    }
    public Long getId(){
        return id;
    }
    public void setId(Long id){
        this.id = id;
    }
    public String getIndexName(){
        return indexName;
    }
    public void setIndexName(String indexName){
        this.indexName = indexName;
    }
    public String getName(){
        return name;
    }
    public void setName(String name){
        this.name = name;
    }
    public int getHitDie(){
        return hitDie;
    }
    public void setHitDie(int hitDie){
        this.hitDie = hitDie;
    }
    public List<String> getProficiencies(){
        return proficiencies;
    }
    public void setProficiencies(List<String> proficiencies){
        this.proficiencies = proficiencies;
    }
    public String getDescription(){
        return description;
    }
    public void setDescription(String description){
        this.description = description;
    }
    public String getSpellcastingAbility() {
        return spellcastingAbility;
    }
    public void setSpellcastingAbility(String spellcastingAbility) {
        this.spellcastingAbility = spellcastingAbility;
    }
    public Integer getSubclassLevel() {
        return subclassLevel;
    }
    public void setSubclassLevel(Integer subclassLevel) {
        this.subclassLevel = subclassLevel;
    }

    public List<String> getSavingThrows() {
        return savingThrows;
    }

    public void setSavingThrows(List<String> savingThrows) {
        this.savingThrows = savingThrows;
    }

    public Set<Spell> getSpells() {
        return spells;
    }

    public void setSpells(Set<Spell> spells) {
        this.spells = spells;
    }

    public List<String> getSkillChoiceOptions() {
        return skillChoiceOptions;
    }

    public void setSkillChoiceOptions(List<String> skillChoiceOptions) {
        this.skillChoiceOptions = skillChoiceOptions;
    }

    public int getNumSkillChoices() {
        return numSkillChoices;
    }

    public void setNumSkillChoices(int numSkillChoices) {
        this.numSkillChoices = numSkillChoices;
    }
    
}
