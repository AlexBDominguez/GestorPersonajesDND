package entities;


import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "classes")
public class DndClass {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String indexName;
    private String name;
    private int hitDie;

    @ElementCollection
    @CollectionTable(name = "class_proficiencies", joinColumns = @JoinColumn(name = "class_id"))
    @Column(name = "proficiency")
    private List<String> proficiencies;

    @Column(columnDefinition = "TEXT")
    private String description;

    public DndClass(){

    }
    public Long getId(){
        return id;
    }
    public void setId(Long id){
        this.id = id;
    }
    public String getIndexName(){
        return indexName;
    }
    public void setIndexName(String indexName){
        this.indexName = indexName;
    }
    public String getName(){
        return name;
    }
    public void setName(String name){
        this.name = name;
    }
    public int getHitDie(){
        return hitDie;
    }
    public void setHitDie(int hitDie){
        this.hitDie = hitDie;
    }
    public List<String> getProficiencies(){
        return proficiencies;
    }
    public void setProficiencies(List<String> proficiencies){
        this.proficiencies = proficiencies;
    }
    public String getDescription(){
        return description;
    }
    public void setDescription(String description){
        this.description = description;
    }

}
