package entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "character_conditions")
public class CharacterCondition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "condition_id", nullable = false)
    private Condition condition;
    
    // Duración en rounds (null = indefinido hasta que se remueva manualmente)
    private Integer durationRounds;
    
    // Rounds restantes (se actualiza en combate)
    private Integer remainingRounds;
    
    // Si tiene un saving throw al final del turno
    private boolean hasSavingThrow;
    
    // DC del saving throw
    private Integer savingThrowDC;
    
    // Ability score del saving throw (ej: "con", "wis")
    private String savingThrowAbility;
    
    // Fuente de la condición (ej: "Spell: Hold Person", "Monster: Ghoul")
    private String source;
    
    // Notas adicionales
    @Column(columnDefinition = "TEXT")
    private String notes;
    
    // Timestamp de cuándo se aplicó
    private LocalDateTime appliedAt;
    
    // Si está activa o ya se removió
    private boolean active;

    public CharacterCondition() {
        this.appliedAt = LocalDateTime.now();
        this.active = true;
    }

    public CharacterCondition(PlayerCharacter character, Condition condition, String source) {
        this.character = character;
        this.condition = condition;
        this.source = source;
        this.appliedAt = LocalDateTime.now();
        this.active = true;
    }

    // Getters y Setters
    
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

    public Condition getCondition() {
        return condition;
    }

    public void setCondition(Condition condition) {
        this.condition = condition;
    }

    public Integer getDurationRounds() {
        return durationRounds;
    }

    public void setDurationRounds(Integer durationRounds) {
        this.durationRounds = durationRounds;
    }

    public Integer getRemainingRounds() {
        return remainingRounds;
    }

    public void setRemainingRounds(Integer remainingRounds) {
        this.remainingRounds = remainingRounds;
    }

    public boolean isHasSavingThrow() {
        return hasSavingThrow;
    }

    public void setHasSavingThrow(boolean hasSavingThrow) {
        this.hasSavingThrow = hasSavingThrow;
    }

    public Integer getSavingThrowDC() {
        return savingThrowDC;
    }

    public void setSavingThrowDC(Integer savingThrowDC) {
        this.savingThrowDC = savingThrowDC;
    }

    public String getSavingThrowAbility() {
        return savingThrowAbility;
    }

    public void setSavingThrowAbility(String savingThrowAbility) {
        this.savingThrowAbility = savingThrowAbility;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getAppliedAt() {
        return appliedAt;
    }

    public void setAppliedAt(LocalDateTime appliedAt) {
        this.appliedAt = appliedAt;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}