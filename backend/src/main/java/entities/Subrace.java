package entities;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import jakarta.persistence.CascadeType;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapKeyColumn;
import jakarta.persistence.Table;

@Entity
@Table(name = "subraces")
public class Subrace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique=true)
    private String indexName;

    private String name;

    @ManyToOne
    @JoinColumn(name = "race_id", nullable = false)
    private Race race;

    @Column(columnDefinition = "TEXT")
    private String description;


    //Bonos de ability adicionales que se suman a los de la raza base
    @ElementCollection
    @CollectionTable(name = "subrace_ability_bonuses",
                        joinColumns = @JoinColumn(name = "subrace_id"))
    @MapKeyColumn(name = "ability")
    @Column(name = "bonus")
    private Map<String, Integer> abilityBonuses;
    

    //Traits de texto (ej: Darkvision 60ft, "Advantages on saves vs poison", etc)
    @ManyToMany(cascade = CascadeType.PERSIST)
    @JoinTable(
        name = "subrace_traits",
        joinColumns = @JoinColumn(name = "subrace_id"),
        inverseJoinColumns = @JoinColumn(name = "trait_id")
    )
    private List<RacialTrait> traits = new ArrayList<>();

    public Subrace() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getIndexName() {
        return indexName;
    }

    public void setIndexName(String indexName) {
        this.indexName = indexName;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Race getRace() {
        return race;
    }

    public void setRace(Race race) {
        this.race = race;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Map<String, Integer> getAbilityBonuses() {
        return abilityBonuses;
    }

    public void setAbilityBonuses(Map<String, Integer> abilityBonuses) {
        this.abilityBonuses = abilityBonuses;
    }

    public List<String> getTraits() {
        return traits;
    }

    public void setTraits(List<String> traits) {
        this.traits = traits;
    }

    
}
