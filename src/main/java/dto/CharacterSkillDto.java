package dto;

public class CharacterSkillDto {
    private Long id;
    private String skillName;
    private String abilityScore;
    private boolean proficient;
    private boolean expertise;
    private int bonus;

    
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getSkillName() {
        return skillName;
    }
    public void setSkillName(String skillName) {
        this.skillName = skillName;
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
    public boolean isExpertise() {
        return expertise;
    }
    public void setExpertise(boolean expertise) {
        this.expertise = expertise;
    }
    public int getBonus() {
        return bonus;
    }
    public void setBonus(int bonus) {
        this.bonus = bonus;
    }

    
    
}
