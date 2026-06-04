package entities;

import jakarta.persistence.*;

@Entity
@Table(name = "content_sources")
public class ContentSource {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String shortName;

    @Column(nullable = false)
    private String fullName;

    @Column(columnDefinition = "TEXT")
    private String description;

    private boolean isBase = false;

    public ContentSource() {}

    public ContentSource(String shortName, String fullName, String description, boolean isBase) {
        this.shortName = shortName;
        this.fullName = fullName;
        this.description = description;
        this.isBase = isBase;
    }

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
