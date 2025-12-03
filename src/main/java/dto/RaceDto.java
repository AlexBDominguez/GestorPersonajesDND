package dto;

import java.util.Map;

public class RaceDto {
    private Long id;
    private String indexName;
    private String name;
    private String size;
    private int speed;
    private Map<String, Integer> abilityBonuses;
    private String description;

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
