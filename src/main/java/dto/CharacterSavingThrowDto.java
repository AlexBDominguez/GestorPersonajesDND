package dto;

public class CharacterSavingThrowDto {
    private Long id;
    private String abilityScore;
    private boolean proficient;
    private int bonus;

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getAbilityScore() {
        return abilityScore;
    }

    public void setAbilityScore(String abilityScore) {
        this.abilityScore = abilityScore;
    }

    public boolean isProficient() {
        return proficient;
    }

    public void setProficient(boolean proficient) {
        this.proficient = proficient;
    }

    public int getBonus() {
        return bonus;
    }

    public void setBonus(int bonus) {
        this.bonus = bonus;
    }
}