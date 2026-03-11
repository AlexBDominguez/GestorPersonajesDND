package entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "languages")
public class Language {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String indexName;

    private String name;

    //Tipo de idioma(Standard, Exotic, etc)
    private String type;

    @Column(columnDefinition = "TEXT")
    private String description;

    //Script que usa (Common, Elvish, etc)
    private String script;

    //Razas típicas que hablan este idioma
    @Column(columnDefinition = "TEXT")
    private String typicalSpeakers;

    public Language() {
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
