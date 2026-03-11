package entities;

import enumeration.DamageRelationType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "character_damage_relations")
public class CharacterDamageRelation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "damage_type_id", nullable = false)
    private DamageType damageType;

    @Enumerated(EnumType.STRING)
    private DamageRelationType relationType;

    //Fuente de la resistencia/inmunidad (ej. Raza, Trasfondo, etc)
    private String source;

    //Si es temporal(ej: de un hechizo)
    private boolean temporary;

    //Condiciones específicas (ej: only against non-magical attacks)
    @Column(columnDefinition = "TEXT")
    private String conditions;

    //Notas adicionales
    @Column(columnDefinition = "TEXT")
    private String notes;

    public CharacterDamageRelation() {}

    public CharacterDamageRelation(PlayerCharacter character, DamageType damageType, DamageRelationType relationType, String source){
        this.character = character;
        this.damageType = damageType;
        this.relationType = relationType;
        this.source = source;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public PlayerCharacter getCharacter() {
        return character;
    }

    public void setCharacter(PlayerCharacter character) {
        this.character = character;
    }

    public DamageType getDamageType() {
        return damageType;
    }

    public void setDamageType(DamageType damageType) {
        this.damageType = damageType;
    }

    public DamageRelationType getRelationType() {
        return relationType;
    }

    public void setRelationType(DamageRelationType relationType) {
        this.relationType = relationType;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public boolean isTemporary() {
        return temporary;
    }

    public void setTemporary(boolean temporary) {
        this.temporary = temporary;
    }

    public String getConditions() {
        return conditions;
    }

    public void setConditions(String conditions) {
        this.conditions = conditions;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }


    
    
}
