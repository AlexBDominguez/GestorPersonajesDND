package entities;

import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Background {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String indexName;
    private String name;

    @ElementCollection
    private List<String> skillProficiencies;

    @ElementCollection
    private List<String> toolProficiencies;

    @ElementCollection
    private List<String> languages;

    @Column(columnDefinition = "TEXT")
    private String feature;
    
    @Column(columnDefinition = "TEXT")
    private String description;

}
