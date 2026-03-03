package entities;

import org.hibernate.annotations.ManyToAny;

import enumeration.FeatureType;
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

    private String metadata;
    
}