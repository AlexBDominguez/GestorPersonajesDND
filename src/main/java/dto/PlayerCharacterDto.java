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
    private String alignment;
    private int temporaryHP;
    private int deathSaveSuccesses;
    private int deathSaveFailures;
    private boolean hasInspiration;
    private int experiencePoints;
    private int speedModifier;
    private Integer naturalArmorBonus;
    private int initiativeBonus;
    private int availableHitDice;
    private Integer age;
    private String height;
    private String weight;
    private String eyes;
    private String skin;
    private String hair;
    private String appearance;
    private String alliesAndOrganizations;
    private String additionalTreasure;
    private String characterHistory;
    private int armorClass;
    private int spellSaveDC;
    private int spellAttackBonus;
    private int initiativeModifier;
    private int currentSpeed;
    private int maxPreparedSpells;
    private int encumberedThreshold;
    private int heavilyEncumberedThreshold;
    private int meleeAttackBonus;
    private int rangedAttackBonus;
    private int finesseAttackBonus;
    private int experienceToNextLevel;
    private int experienceNeeded;
    private boolean isDying;
    private boolean isStable;
    private boolean isDead;
    private boolean isConscious;
    private int passivePerception;
    private int passiveInvestigation;
    private int passiveInsight;


    // Getters y setters


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

    public String getAlignment() {
        return alignment;
    }

    public void setAlignment(String alignment) {
        this.alignment = alignment;
    }

    public int getTemporaryHP() {
        return temporaryHP;
    }

    public void setTemporaryHP(int temporaryHP) {
        this.temporaryHP = temporaryHP;
    }

    public int getDeathSaveSuccesses() {
        return deathSaveSuccesses;
    }

    public void setDeathSaveSuccesses(int deathSaveSuccesses) {
        this.deathSaveSuccesses = deathSaveSuccesses;
    }

    public int getDeathSaveFailures() {
        return deathSaveFailures;
    }

    public void setDeathSaveFailures(int deathSaveFailures) {
        this.deathSaveFailures = deathSaveFailures;
    }

    public boolean isHasInspiration() {
        return hasInspiration;
    }

    public void setHasInspiration(boolean hasInspiration) {
        this.hasInspiration = hasInspiration;
    }

    public int getExperiencePoints() {
        return experiencePoints;
    }

    public void setExperiencePoints(int experiencePoints) {
        this.experiencePoints = experiencePoints;
    }

    public int getSpeedModifier() {
        return speedModifier;
    }

    public void setSpeedModifier(int speedModifier) {
        this.speedModifier = speedModifier;
    }

    public Integer getNaturalArmorBonus() {
        return naturalArmorBonus;
    }

    public void setNaturalArmorBonus(Integer naturalArmorBonus) {
        this.naturalArmorBonus = naturalArmorBonus;
    }

    public int getInitiativeBonus() {
        return initiativeBonus;
    }

    public void setInitiativeBonus(int initiativeBonus) {
        this.initiativeBonus = initiativeBonus;
    }

    public int getAvailableHitDice() {
        return availableHitDice;
    }

    public void setAvailableHitDice(int availableHitDice) {
        this.availableHitDice = availableHitDice;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getHeight() {
        return height;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public String getWeight() {
        return weight;
    }

    public void setWeight(String weight) {
        this.weight = weight;
    }

    public String getEyes() {
        return eyes;
    }

    public void setEyes(String eyes) {
        this.eyes = eyes;
    }

    public String getSkin() {
        return skin;
    }

    public void setSkin(String skin) {
        this.skin = skin;
    }

    public String getHair() {
        return hair;
    }

    public void setHair(String hair) {
        this.hair = hair;
    }

    public String getAppearance() {
        return appearance;
    }

    public void setAppearance(String appearance) {
        this.appearance = appearance;
    }

    public String getAlliesAndOrganizations() {
        return alliesAndOrganizations;
    }

    public void setAlliesAndOrganizations(String alliesAndOrganizations) {
        this.alliesAndOrganizations = alliesAndOrganizations;
    }

    public String getAdditionalTreasure() {
        return additionalTreasure;
    }

    public void setAdditionalTreasure(String additionalTreasure) {
        this.additionalTreasure = additionalTreasure;
    }

    public String getCharacterHistory() {
        return characterHistory;
    }

    public void setCharacterHistory(String characterHistory) {
        this.characterHistory = characterHistory;
    }

    public int getArmorClass() {
        return armorClass;
    }

    public void setArmorClass(int armorClass) {
        this.armorClass = armorClass;
    }

    public int getSpellSaveDC() {
        return spellSaveDC;
    }

    public void setSpellSaveDC(int spellSaveDC) {
        this.spellSaveDC = spellSaveDC;
    }

    public int getSpellAttackBonus() {
        return spellAttackBonus;
    }

    public void setSpellAttackBonus(int spellAttackBonus) {
        this.spellAttackBonus = spellAttackBonus;
    }

    public int getInitiativeModifier() {
        return initiativeModifier;
    }

    public void setInitiativeModifier(int initiativeModifier) {
        this.initiativeModifier = initiativeModifier;
    }

    public int getCurrentSpeed() {
        return currentSpeed;
    }

    public void setCurrentSpeed(int currentSpeed) {
        this.currentSpeed = currentSpeed;
    }

    public int getMaxPreparedSpells() {
        return maxPreparedSpells;
    }

    public void setMaxPreparedSpells(int maxPreparedSpells) {
        this.maxPreparedSpells = maxPreparedSpells;
    }

    public int getEncumberedThreshold() {
        return encumberedThreshold;
    }

    public void setEncumberedThreshold(int encumberedThreshold) {
        this.encumberedThreshold = encumberedThreshold;
    }

    public int getHeavilyEncumberedThreshold() {
        return heavilyEncumberedThreshold;
    }

    public void setHeavilyEncumberedThreshold(int heavilyEncumberedThreshold) {
        this.heavilyEncumberedThreshold = heavilyEncumberedThreshold;
    }

    public int getMeleeAttackBonus() {
        return meleeAttackBonus;
    }

    public void setMeleeAttackBonus(int meleeAttackBonus) {
        this.meleeAttackBonus = meleeAttackBonus;
    }

    public int getRangedAttackBonus() {
        return rangedAttackBonus;
    }

    public void setRangedAttackBonus(int rangedAttackBonus) {
        this.rangedAttackBonus = rangedAttackBonus;
    }

    public int getFinesseAttackBonus() {
        return finesseAttackBonus;
    }

    public void setFinesseAttackBonus(int finesseAttackBonus) {
        this.finesseAttackBonus = finesseAttackBonus;
    }

    public int getExperienceToNextLevel() {
        return experienceToNextLevel;
    }

    public void setExperienceToNextLevel(int experienceToNextLevel) {
        this.experienceToNextLevel = experienceToNextLevel;
    }

    public int getExperienceNeeded() {
        return experienceNeeded;
    }

    public void setExperienceNeeded(int experienceNeeded) {
        this.experienceNeeded = experienceNeeded;
    }

    public boolean isDying() {
        return isDying;
    }

    public void setDying(boolean isDying) {
        this.isDying = isDying;
    }

    public boolean isStable() {
        return isStable;
    }

    public void setStable(boolean isStable) {
        this.isStable = isStable;
    }

    public boolean isDead() {
        return isDead;
    }

    public void setDead(boolean isDead) {
        this.isDead = isDead;
    }

    public boolean isConscious() {
        return isConscious;
    }

    public void setConscious(boolean isConscious) {
        this.isConscious = isConscious;
    }

    public int getPassivePerception() {
        return passivePerception;
    }

    public void setPassivePerception(int passivePerception) {
        this.passivePerception = passivePerception;
    }

    public int getPassiveInvestigation() {
        return passiveInvestigation;
    }

    public void setPassiveInvestigation(int passiveInvestigation) {
        this.passiveInvestigation = passiveInvestigation;
    }

    public int getPassiveInsight() {
        return passiveInsight;
    }

    public void setPassiveInsight(int passiveInsight) {
        this.passiveInsight = passiveInsight;
    }

    

   

}
