package dto;

public class LanguageDto {
    private Long id;
    private String indexName;
    private String name;
    private String type;
    private String description;
    private String script;
    private String typicalSpeakers;

    
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
    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String getScript() {
        return script;
    }
    public void setScript(String script) {
        this.script = script;
    }
    public String getTypicalSpeakers() {
        return typicalSpeakers;
    }
    public void setTypicalSpeakers(String typicalSpeakers) {
        this.typicalSpeakers = typicalSpeakers;
    }


    
    
}
