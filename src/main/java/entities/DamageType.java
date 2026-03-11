package entities;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "damage_types")
public class DamageType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String indexName;
    
    private String name;
    
    @ElementCollection
    @CollectionTable(name = "damage_type_descriptions", joinColumns = @JoinColumn(name = "damage_type_id"))
    @Column(name = "description", columnDefinition = "TEXT")
    private List<String> description;

    public DamageType() {}

    // Getters y Setters
    
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

    public List<String> getDescription() {
        return description;
    }

    public void setDescription(List<String> description) {
        this.description = description;
    }
}