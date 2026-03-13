package dto;

public class SpellDto {

    private Long id;
    private String name;
    private int level;
    private String school;
    private String description;

    public SpellDto() {}

    public SpellDto(Long id, String name, int level, String school, String description) {
        this.id = id;
        this.name = name;
        this.level = level;
        this.school = school;
        this.description = description;
    }

    // Getters and Setters


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}