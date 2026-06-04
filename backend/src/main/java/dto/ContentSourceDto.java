package dto;

public class ContentSourceDto {
    private Long id;
    private String shortName;
    private String fullName;
    private String description;
    private boolean isBase;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getShortName() { return shortName; }
    public void setShortName(String shortName) { this.shortName = shortName; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isBase() { return isBase; }
    public void setBase(boolean base) { isBase = base; }
}
