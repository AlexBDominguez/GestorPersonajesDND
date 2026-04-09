package dto;

public class CharacterSpellSummaryDto {
    private Long id; //ID del spell
    private String name;
    private int level;
    private String school;
    private String castingTime;
    private String range;
    private String duration;
    private String components;
    private String description;
    private boolean prepared;
    private boolean learned;
    private String spellSource; //"CLASS", "SUBCLASS", "RACE", "FEAT"
    private String attackType;
    private String dcType;
    private String damageType;
    private String damageBase;

    public CharacterSpellSummaryDto() {}

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

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
    }

    public String getCastingTime() {
        return castingTime;
    }

    public void setCastingTime(String castingTime) {
        this.castingTime = castingTime;
    }

    public String getRange() {
        return range;
    }

    public void setRange(String range) {
        this.range = range;
    }

    public String getDuration() {
        return duration;
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }

    public String getComponents() {
        return components;
    }

    public void setComponents(String components) {
        this.components = components;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isPrepared() {
        return prepared;
    }

    public void setPrepared(boolean prepared) {
        this.prepared = prepared;
    }

    public boolean isLearned() {
        return learned;
    }

    public void setLearned(boolean learned) {
        this.learned = learned;
    }

    public String getSpellSource() {
        return spellSource;
    }

    public void setSpellSource(String spellSource) {
        this.spellSource = spellSource;
    }

    public String getAttackType() { return attackType; }
    public void setAttackType(String attackType) { this.attackType = attackType; }

    public String getDcType() { return dcType; }
    public void setDcType(String dcType) { this.dcType = dcType; }

    public String getDamageType() { return damageType; }
    public void setDamageType(String damageType) { this.damageType = damageType; }

    public String getDamageBase() { return damageBase; }
    public void setDamageBase(String damageBase) { this.damageBase = damageBase; }
    
}
