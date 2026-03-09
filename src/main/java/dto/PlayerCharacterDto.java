package dto;

import java.util.Map;

public class PlayerCharacterDto {
    private Long id;
    private String name;
    private int level;
    private Long RaceId;
    private String raceName;
    private Long dndClassId;
    private String dndClassName;
    private Map<String, Integer> abilityScores;
    private int maxHp;
    private int currentHp;
    private int proficiencyBonus;
    private String backstory;
    private Long backgroundId;
    private String backgroundName;
    private String personalityTrait1;
    private String personalityTrait2;
    private String ideal;
    private String bond;
    private String flaw;
    private Long subclassId;
    private String subclassName;



    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public Long getRaceId() {
        return RaceId;
    }

    public void setRaceId(Long raceId) {
        RaceId = raceId;
    }

    public String getRaceName() {
        return raceName;
    }

    public void setRaceName(String raceName) {
        this.raceName = raceName;
    }

    public Long getDndClassId() {
        return dndClassId;
    }

    public void setDndClassId(Long dndClassId) {
        this.dndClassId = dndClassId;
    }

    public String getDndClassName() {
        return dndClassName;
    }

    public void setDndClassName(String dndClassName) {
        this.dndClassName = dndClassName;
    }

    public Map<String, Integer> getAbilityScores() {
        return abilityScores;
    }

    public void setAbilityScores(Map<String, Integer> abilityScores) {
        this.abilityScores = abilityScores;
    }

    public int getMaxHp() {
        return maxHp;
    }

    public void setMaxHp(int maxHp) {
        this.maxHp = maxHp;
    }

    public int getCurrentHp() {
        return currentHp;
    }

    public void setCurrentHp(int currentHp) {
        this.currentHp = currentHp;
    }

    public int getProficiencyBonus() {
        return proficiencyBonus;
    }

    public void setProficiencyBonus(int proficiencyBonus) {
        this.proficiencyBonus = proficiencyBonus;
    }

    public String getBackstory() {
        return backstory;
    }

    public void setBackstory(String backstory) {
        this.backstory = backstory;
    }

    public Long getBackgroundId() {
        return backgroundId;
    }

    public void setBackgroundId(Long backgroundId) {
        this.backgroundId = backgroundId;
    }

    public String getBackgroundName() {
        return backgroundName;
    }

    public void setBackgroundName(String backgroundName) {
        this.backgroundName = backgroundName;
    }

    public String getPersonalityTrait1() {
        return personalityTrait1;
    }

    public void setPersonalityTrait1(String personalityTrait1) {
        this.personalityTrait1 = personalityTrait1;
    }

    public String getPersonalityTrait2() {
        return personalityTrait2;
    }

    public void setPersonalityTrait2(String personalityTrait2) {
        this.personalityTrait2 = personalityTrait2;
    }

    public String getIdeal() {
        return ideal;
    }

    public void setIdeal(String ideal) {
        this.ideal = ideal;
    }

    public String getBond() {
        return bond;
    }

    public void setBond(String bond) {
        this.bond = bond;
    }

    public String getFlaw() {
        return flaw;
    }

    public void setFlaw(String flaw) {
        this.flaw = flaw;
    }

    public Long getSubclassId() {
        return subclassId;
    }

    public void setSubclassId(Long subclassId) {
        this.subclassId = subclassId;
    }

    public String getSubclassName() {
        return subclassName;
    }

    public void setSubclassName(String subclassName) {
        this.subclassName = subclassName;
    }

    

   

}
