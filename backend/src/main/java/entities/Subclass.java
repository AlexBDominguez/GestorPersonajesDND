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
@Table(name = "subclasses")
public class Subclass {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String indexName;

    private String name;
    private String nameEs;
    private String nameGl;

    @ManyToOne
    @JoinColumn(name = "class_id", nullable = false)
    private DndClass dndClass;

    private String subclassFlavor;
    private String subclassFlavorEs;
    private String subclassFlavorGl;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String descriptionEs;

    @Column(columnDefinition = "TEXT")
    private String descriptionGl;

    // Ability Score para spellcasting (puede ser null si no es caster)
    private String spellcastingAbility;

    public Subclass(){}

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

    public String getNameEs() {
        return nameEs;
    }

    public void setNameEs(String nameEs) {
        this.nameEs = nameEs;
    }

    public String getNameGl() {
        return nameGl;
    }

    public void setNameGl(String nameGl) {
        this.nameGl = nameGl;
    }

    public DndClass getDndClass() {
        return dndClass;
    }

    public void setDndClass(DndClass dndClass) {
        this.dndClass = dndClass;
    }

    public String getSubclassFlavor() {
        return subclassFlavor;
    }

    public void setSubclassFlavor(String subclassFlavor) {
        this.subclassFlavor = subclassFlavor;
    }

    public String getSubclassFlavorEs() {
        return subclassFlavorEs;
    }

    public void setSubclassFlavorEs(String subclassFlavorEs) {
        this.subclassFlavorEs = subclassFlavorEs;
    }

    public String getSubclassFlavorGl() {
        return subclassFlavorGl;
    }

    public void setSubclassFlavorGl(String subclassFlavorGl) {
        this.subclassFlavorGl = subclassFlavorGl;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDescriptionEs() {
        return descriptionEs;
    }

    public void setDescriptionEs(String descriptionEs) {
        this.descriptionEs = descriptionEs;
    }

    public String getDescriptionGl() {
        return descriptionGl;
    }

    public void setDescriptionGl(String descriptionGl) {
        this.descriptionGl = descriptionGl;
    }

    public String getSpellcastingAbility() {
        return spellcastingAbility;
    }

    public void setSpellcastingAbility(String spellcastingAbility) {
        this.spellcastingAbility = spellcastingAbility;
    }

    


}
