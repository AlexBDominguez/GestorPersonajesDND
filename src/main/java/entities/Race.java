package entities;

import jakarta.persistence.*;

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
}
