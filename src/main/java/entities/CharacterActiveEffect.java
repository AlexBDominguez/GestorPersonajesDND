package entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "character_active_effects")
public class CharacterActiveEffect {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "character_id", nullable = false)
    private PlayerCharacter character;

    @ManyToOne
    @JoinColumn(name = "effect_id", nullable = false)
    private ActiveEffect effect;

    // Si el efecto está actualmente activo
    private boolean active;

    // Cuándo se aplicó el efecto
    private LocalDateTime appliedAt;

    // Rounds restantes (para efectos en combate)
    private Integer remainingRounds;

    // Nivel del caster (para efectos escalables como Bless)
    private Integer casterLevel;

    // Notas adicionales
    @Column(columnDefinition = "TEXT")
    private String notes;

    public CharacterActiveEffect() {
        this.appliedAt = LocalDateTime.now();
        this.active = true;
    }

    public CharacterActiveEffect(PlayerCharacter character, ActiveEffect effect) {
        this.character = character;
        this.effect = effect;
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

    public ActiveEffect getEffect() {
        return effect;
    }

    public void setEffect(ActiveEffect effect) {
        this.effect = effect;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public LocalDateTime getAppliedAt() {
        return appliedAt;
    }

    public void setAppliedAt(LocalDateTime appliedAt) {
        this.appliedAt = appliedAt;
    }

    public Integer getRemainingRounds() {
        return remainingRounds;
    }

    public void setRemainingRounds(Integer remainingRounds) {
        this.remainingRounds = remainingRounds;
    }

    public Integer getCasterLevel() {
        return casterLevel;
    }

    public void setCasterLevel(Integer casterLevel) {
        this.casterLevel = casterLevel;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}