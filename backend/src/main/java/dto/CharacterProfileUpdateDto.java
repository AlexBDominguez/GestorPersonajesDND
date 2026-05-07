package dto;

public class CharacterProfileUpdateDto {
    private String name;
    private String alignment;
    private String personalityTrait;
    private String ideal;
    private String bond;
    private String flaw;
    private Integer age;
    private String height;
    private String weight;
    private String eyes;
    private String skin;
    private String hair;
    private String abilityDisplayMode;
    private Boolean useEncumbrance;
    private Long subclassId;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAlignment() { return alignment; }
    public void setAlignment(String alignment) { this.alignment = alignment; }

    public String getPersonalityTrait() { return personalityTrait; }
    public void setPersonalityTrait(String personalityTrait) { this.personalityTrait = personalityTrait; }

    public String getIdeal() { return ideal; }
    public void setIdeal(String ideal) { this.ideal = ideal; }

    public String getBond() { return bond; }
    public void setBond(String bond) { this.bond = bond; }

    public String getFlaw() { return flaw; }
    public void setFlaw(String flaw) { this.flaw = flaw; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }

    public String getHeight() { return height; }
    public void setHeight(String height) { this.height = height; }

    public String getWeight() { return weight; }
    public void setWeight(String weight) { this.weight = weight; }

    public String getEyes() { return eyes; }
    public void setEyes(String eyes) { this.eyes = eyes; }

    public String getSkin() { return skin; }
    public void setSkin(String skin) { this.skin = skin; }

    public String getHair() { return hair; }
    public void setHair(String hair) { this.hair = hair; }

    public String getAbilityDisplayMode() { return abilityDisplayMode; }
    public void setAbilityDisplayMode(String abilityDisplayMode) { this.abilityDisplayMode = abilityDisplayMode; }

    public Boolean getUseEncumbrance() { return useEncumbrance; }
    public void setUseEncumbrance(Boolean useEncumbrance) { this.useEncumbrance = useEncumbrance; }

    public Long getSubclassId() { return subclassId; }
    public void setSubclassId(Long subclassId) { this.subclassId = subclassId; }
}
