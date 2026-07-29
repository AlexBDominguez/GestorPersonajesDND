package entities;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(name = "player_character_classes",
       uniqueConstraints = @UniqueConstraint(columnNames = {"character_id", "class_id"}))
public class PlayerCharacterClass {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "class_id", nullable = false)
    private DndClass dndClass;

    @ManyToOne
    @JoinColumn(name = "subclass_id")
    private Subclass subclass;

    // Nivel DENTRO de esta clase (no el nivel total del personaje)
    private int level;

    // Orden de adquisición: 0 = clase original (proficiencies/saves completas)
    private int classOrder;

    public PlayerCharacterClass() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public PlayerCharacter getCharacter() {
        return character;
    }

    public void setCharacter(PlayerCharacter character) {
        this.character = character;
    }

    public DndClass getDndClass() {
        return dndClass;
    }

    public void setDndClass(DndClass dndClass) {
        this.dndClass = dndClass;
    }

    public Subclass getSubclass() {
        return subclass;
    }

    public void setSubclass(Subclass subclass) {
        this.subclass = subclass;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getClassOrder() {
        return classOrder;
    }

    public void setClassOrder(int classOrder) {
        this.classOrder = classOrder;
    }

}
