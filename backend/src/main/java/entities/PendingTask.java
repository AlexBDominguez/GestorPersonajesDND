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
@Table(name = "pending_tasks")
public class PendingTask {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    // Clase que originó esta tarea bajo multiclase (nullable: las tareas de personajes
    // mono-clase, o creadas antes de esto, no la necesitan para desambiguar nada).
    @ManyToOne
    @JoinColumn(name = "class_id")
    private DndClass dndClass;

    private String taskType;

    private int relatedLevel;

    @Column(columnDefinition = "TEXT")
    private String description;


    private boolean completed;

    @Column(columnDefinition = "TEXT")
    private String metadata;

    public PendingTask() {}

    public PendingTask(PlayerCharacter character, String taskType, int relatedLevel, String description, String metadata) {
        this.character = character;
        this.taskType = taskType;
        this.relatedLevel = relatedLevel;
        this.description = description;
        this.metadata = metadata;
        this.completed = false;
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

    public String getTaskType() {
        return taskType;
    }

    public void setTaskType(String taskType) {
        this.taskType = taskType;
    }

    public int getRelatedLevel() {
        return relatedLevel;
    }

    public void setRelatedLevel(int relatedLevel) {
        this.relatedLevel = relatedLevel;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isCompleted() {
        return completed;
    }

    public void setCompleted(boolean completed) {
        this.completed = completed;
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
    }

    

}
