package entities;

import jakarta.persistence.*;

@Entity
@Table(name = "racial_traits")
public class RacialTrait {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String indexName;

    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    // COMBAT si da un bono de ataque, acción activable, etc.
    // PASSIVE para el resto (visión oscura, resistencias, etc.)
    private String traitType; // "COMBAT" | "PASSIVE" | "CHOICE_REQUIRED"

    public RacialTrait() {}

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