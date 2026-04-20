package entities;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Entity
@Table(name = "race")
public class Race {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String indexName;
    private String name;
    private String size;
    private int speed;

    @ElementCollection
    @CollectionTable(name = "race_ability_bonuses", joinColumns = @JoinColumn(name = "race_id"))
    @MapKeyColumn(name = "ability")
    @Column(name = "bonus")
    private Map<String, Integer> abilityBonuses;

    // Hechizos que otorga la raza automáticamente (ej: High Elf -> Prestidigitation)
    @ManyToMany
    @JoinTable(
            name = "race_spells",
            joinColumns = @JoinColumn(name = "race_id"),
            inverseJoinColumns = @JoinColumn(name = "spell_id")
    )
    private List<Spell> grantedSpells;

    @ManyToMany(cascade = CascadeType.PERSIST)
    @JoinTable(
            name = "race_traits",
            joinColumns = @JoinColumn(name = "race_id"),
            inverseJoinColumns = @JoinColumn(name = "trait_id")
    )
    private List<RacialTrait> traits = new ArrayList<>();

    @Column(columnDefinition = "TEXT")
    private String description;

    public Race() {
    }

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

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public int getSpeed() {
        return speed;
    }

    public void setSpeed(int speed) {
        this.speed = speed;
    }

    public Map<String, Integer> getAbilityBonuses() {
        return abilityBonuses;
    }

    public void setAbilityBonuses(Map<String, Integer> abilityBonuses) {
        this.abilityBonuses = abilityBonuses;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public List<Spell> getGrantedSpells() {
        return grantedSpells;
    }

    public void setGrantedSpells(List<Spell> grantedSpells) {
        this.grantedSpells = grantedSpells;
    }

    public List<RacialTrait> getTraits() {
        return traits;
    }

    public void setTraits(List<RacialTrait> traits) {
        this.traits = traits;
    }
}
