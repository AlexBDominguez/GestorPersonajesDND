package dto;

public class PlayerCharacterClassDto {
    private Long id;
    private Long dndClassId;
    private String dndClassName;
    private Long subclassId;
    private String subclassName;
    private int level;
    private int classOrder;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getDndClassId() {
        return dndClassId;
    }

    public void setDndClassId(Long dndClassId) {
        this.dndClassId = dndClassId;
    }

    public String getDndClassName() {
        return dndClassName;
    }

    public void setDndClassName(String dndClassName) {
        this.dndClassName = dndClassName;
    }

    public Long getSubclassId() {
        return subclassId;
    }

    public void setSubclassId(Long subclassId) {
        this.subclassId = subclassId;
    }

    public String getSubclassName() {
        return subclassName;
    }

    public void setSubclassName(String subclassName) {
        this.subclassName = subclassName;
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
