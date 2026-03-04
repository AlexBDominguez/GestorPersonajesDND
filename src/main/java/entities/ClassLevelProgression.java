package entities;

import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;

@Entity
public class ClassLevelProgression {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private DndClass dndClass;

    private int level;

    @OneToMany(mappedBy = "progression", cascade = CascadeType.ALL)
    private List<ClassLevelFeature> features;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public DndClass getDndClass() {
        return dndClass;
    }

    public void setDndClass(DndClass dndClass) {
        this.dndClass = dndClass;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public List<ClassLevelFeature> getFeatures() {
        return features;
    }

    public void setFeatures(List<ClassLevelFeature> features) {
        this.features = features;
    }


    
}
