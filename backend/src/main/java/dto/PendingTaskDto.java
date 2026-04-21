package dto;

public class PendingTaskDto {
    private Long id;
    private String taskType;
    private int relatedLevel;
    private String description;
    private boolean completed;
    private String metadata; //JSON string con opciones disponibles si aplica

    
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
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
