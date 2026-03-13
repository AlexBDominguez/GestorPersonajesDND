package entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "subclass_features")
public class SubclassFeature {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "subclass_id", nullable = false)
    private Subclass subclass;

    private String indexName;
    private String name;

    //Nivel al que se obtiene esta característica
    private int level;

    @Column(columnDefinition = "TEXT")
    private String description;

    //URL de la API para detalles adicionales
    private String apiUrl;


    public SubclassFeature(){}


    public Long getId() {
        return id;
    }


    public void setId(Long id) {
        this.id = id;
    }


    public Subclass getSubclass() {
        return subclass;
    }


    public void setSubclass(Subclass subclass) {
        this.subclass = subclass;
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


    
    




}
