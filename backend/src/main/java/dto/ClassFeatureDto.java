package dto;

public class ClassFeatureDto {
    
    private Long id;
    private String indexName;
    private String name;
    private int level;
    private String description;
    private String apiUrl;
    private String consumesResourceIndexName;
    private String grantsBonusKey;

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
    public int getLevel() {
        return level;
    }
    public void setLevel(int level) {
        this.level = level;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String getApiUrl() {
        return apiUrl;
    }
    public void setApiUrl(String apiUrl) {
        this.apiUrl = apiUrl;
    }
    public String getConsumesResourceIndexName() {
        return consumesResourceIndexName;
    }
    public void setConsumesResourceIndexName(String consumesResourceIndexName) {
        this.consumesResourceIndexName = consumesResourceIndexName;
    }
    public String getGrantsBonusKey() {
        return grantsBonusKey;
    }
    public void setGrantsBonusKey(String grantsBonusKey) {
        this.grantsBonusKey = grantsBonusKey;
    }

}
