package dto;

import java.util.List;
import java.util.Map;

public class SubraceDto {
    private Long id;
    private String indexName;
    private String name;
    private Long raceId;
    private String raceName;
    private String description;
    private Map<String, Integer> abilityBonuses;
    private List<String> traits;

    
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
    public Long getRaceId() {
        return raceId;
    }
    public void setRaceId(Long raceId) {
        this.raceId = raceId;
    }
    public String getRaceName() {
        return raceName;
    }
    public void setRaceName(String raceName) {
        this.raceName = raceName;
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
