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
@Table(name = "class_features")
public class ClassFeature {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "class_id", nullable = false)
    private DndClass dndClass;

    private String indexName;
    private String name;

    //nivel al que se obtiene la característica
    private int level;

    @Column(columnDefinition = "TEXT")
    private String description;

    //URL de la API para obtener detalles adicionales
    private String apiUrl;

    // Si no es null, esta feature no es un recurso en sí misma: gasta usos del ClassResource
    // cuyo indexName coincide con este valor (p.ej. "flurry-of-blows" -> "ki").
    private String consumesResourceIndexName;

    // Si no es null, tener esta feature (a partir de su nivel) otorga automáticamente el
    // NumericBonus cuyo bonusKey coincide con este valor (p.ej. "aura-of-protection" ->
    // bonificador de Carisma a todas las salvaciones). Ver #8.2 NUMERIC_BONUS.
    private String grantsBonusKey;

    public ClassFeature(){

    }

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

    public String getIndexName() {
        return indexName;
    }

    public void setIndexName(String indexName) {
        this.indexName = indexName;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getApiUrl() {
        return apiUrl;
    }

    public void setApiUrl(String apiUrl) {
        this.apiUrl = apiUrl;
    }

    public String getConsumesResourceIndexName() {
        return consumesResourceIndexName;
    }

    public void setConsumesResourceIndexName(String consumesResourceIndexName) {
        this.consumesResourceIndexName = consumesResourceIndexName;
    }

    public String getGrantsBonusKey() {
        return grantsBonusKey;
    }

    public void setGrantsBonusKey(String grantsBonusKey) {
        this.grantsBonusKey = grantsBonusKey;
    }

}
