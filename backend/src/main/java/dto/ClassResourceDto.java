package dto;

public class ClassResourceDto {
    private Long id;
    private Long classId;
    private String className;
    private String name;
    private String indexName;
    private String description;
    private String maxFormula;
    private String recoveryType;
    private int levelUnlocked;

    
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public Long getClassId() {
        return classId;
    }
    public void setClassId(Long classId) {
        this.classId = classId;
    }
    public String getClassName() {
        return className;
    }
    public void setClassName(String className) {
        this.className = className;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getIndexName() {
        return indexName;
    }
    public void setIndexName(String indexName) {
        this.indexName = indexName;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String getMaxFormula() {
        return maxFormula;
    }
    public void setMaxFormula(String maxFormula) {
        this.maxFormula = maxFormula;
    }
    public String getRecoveryType() {
        return recoveryType;
    }
    public void setRecoveryType(String recoveryType) {
        this.recoveryType = recoveryType;
    }
    public int getLevelUnlocked() {
        return levelUnlocked;
    }
    public void setLevelUnlocked(int levelUnlocked) {
        this.levelUnlocked = levelUnlocked;
    }

    // Getters and Setters

    
    
}
