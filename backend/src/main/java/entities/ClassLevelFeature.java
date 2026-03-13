package entities;

import enumeration.FeatureType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;


@Entity
public class ClassLevelFeature{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private ClassLevelProgression progression;

    @Enumerated(EnumType.STRING)
    private FeatureType type;

    private boolean requiresChoice;

    @Column(columnDefinition = "TEXT")
    private String metadata;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public ClassLevelProgression getProgression() {
        return progression;
    }

    public void setProgression(ClassLevelProgression progression) {
        this.progression = progression;
    }

    public FeatureType getType() {
        return type;
    }

    public void setType(FeatureType type) {
        this.type = type;
    }

    public boolean isRequiresChoice() {
        return requiresChoice;
    }

    public void setRequiresChoice(boolean requiresChoice) {
        this.requiresChoice = requiresChoice;
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
    }



    
    
}