package dto;

import java.util.List;
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
    private String personalityTrait;
    private String ideal;
    private String bond;
    private String flaw;
    private Long subclassId;
    private String subclassName;
    private Long subraceId;
    private String subraceName;
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
    private Long userId;
    private List<CharacterSpellSummaryDto> characterSpells;
    private List<Long> spellIds; //Ids de spells seleccionados en el wizard
    private List<Long> magicalSecretSpellIds; //Ids de Magical Secrets (any-class) seleccionados en el wizard
    private List<Long> featIds;
    private List<SpellSlotDto> spellSlots;
    private boolean useEncumbrance = false;
    private String abilityDisplayMode = "SCORES_TOP";
    private List<CharacterSkillDto> skills;
    private List<CharacterSavingThrowDto> savingThrows;
    private List<String> classSkillIndices; // input: class skill picks from wizard
    


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

    public String getPersonalityTrait() {
        return personalityTrait;
    }

    public void setPersonalityTrait(String personalityTrait) {
        this.personalityTrait = personalityTrait;
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

    public Long getSubraceId() {
        return subraceId;
    }

    public void setSubraceId(Long subraceId) {
        this.subraceId = subraceId;
    }

    public String getSubraceName() {
        return subraceName;
    }

    public void setSubraceName(String subraceName) {
        this.subraceName = subraceName;
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

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public List<SpellSlotDto> getSpellSlots() {
        return spellSlots;
    }

    public void setSpellSlots(List<SpellSlotDto> spellSlots) {
        this.spellSlots = spellSlots;
    }

    public List<CharacterSkillDto> getSkills() {
        return skills;
    }

    public void setSkills(List<CharacterSkillDto> skills) {
        this.skills = skills;
    }

    public List<CharacterSavingThrowDto> getSavingThrows() {
        return savingThrows;
    }
    public void setSavingThrows(List<CharacterSavingThrowDto> savingThrows) {
        this.savingThrows = savingThrows;
    }

    public List<String> getClassSkillIndices() {
        return classSkillIndices;
    }

    public void setClassSkillIndices(List<String> classSkillIndices) {
        this.classSkillIndices = classSkillIndices;
    }

    public List<CharacterSpellSummaryDto> getCharacterSpells() {
        return characterSpells;
    }

    public void setCharacterSpells(List<CharacterSpellSummaryDto> characterSpells) {
        this.characterSpells = characterSpells;
    }

    public List<Long> getSpellIds() {
        return spellIds;
    }

    public void setSpellIds(List<Long> spellIds) {
        this.spellIds = spellIds;
    }

    public List<Long> getMagicalSecretSpellIds() {
        return magicalSecretSpellIds;
    }

    public void setMagicalSecretSpellIds(List<Long> magicalSecretSpellIds) {
        this.magicalSecretSpellIds = magicalSecretSpellIds;
    }

    public List<Long> getFeatIds() {
        return featIds;
    }

    public void setFeatIds(List<Long> featIds) {
        this.featIds = featIds;
    }

    public boolean isUseEncumbrance() {
        return useEncumbrance;
    }

    public void setUseEncumbrance(boolean useEncumbrance) {
        this.useEncumbrance = useEncumbrance;
    }

    public String getAbilityDisplayMode() {
        return abilityDisplayMode;
    }

    public void setAbilityDisplayMode(String abilityDisplayMode) {
        this.abilityDisplayMode = abilityDisplayMode;
    }

}
