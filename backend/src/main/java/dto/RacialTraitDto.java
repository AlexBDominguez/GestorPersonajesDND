package dto;

public class RacialTraitDto {
    private Long id;
    private String indexName;
    private String name;
    private String description;
    private String traitType;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getIndexName() { return indexName; }
    public void setIndexName(String indexName) { this.indexName = indexName; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getTraitType() { return traitType; }
    public void setTraitType(String traitType) { this.traitType = traitType; }
}