package entities;

import java.util.List;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "feats")
public class Feat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String indexName;
    
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;


    //Prerequisitos como texto (ej: Strength 13 or higher)
    @ElementCollection
    @CollectionTable(name = "feat_prerequisites", joinColumns = @JoinColumn(name = "feat_id"))  
    @Column(name = "prerequisite", columnDefinition = "TEXT")
    private List<String> prerequisites;

    //Hechizos que otorga el feat automáticamente (ej: Magic Initiate)
    //Nota: algunos feats permiten elegir - eso se gestiona en el wizard
    @ManyToMany
    @JoinTable(
        name = "feat_spells",
        joinColumns = @JoinColumn(name = "feat_id"),
        inverseJoinColumns = @JoinColumn(name = "spell_id")
    )
    private List<Spell> grantedSpells;


    public Feat() {}


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


    public String getDescription() {
        return description;
    }


    public void setDescription(String description) {
        this.description = description;
    }


    public List<String> getPrerequisites() {
        return prerequisites;
    }


    public void setPrerequisites(List<String> prerequisites) {
        this.prerequisites = prerequisites;
    }

    public List<Spell> getGrantedSpells() {
        return grantedSpells;
    }

    public void setGrantedSpells(List<Spell> grantedSpells) {
        this.grantedSpells = grantedSpells;
    }

}
