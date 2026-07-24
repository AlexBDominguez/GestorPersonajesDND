package dto;

public class CharacterInventoryDto {
    private Long id;
    private Long characterId;
    private String characterName;
    private Long itemId;
    private String itemName;
    private String itemType;
    private int quantity;
    private double weight;
    private double totalWeight; // weight * quantity
    private boolean equipped;
    private boolean attuned;
    private boolean requiresAttunement;
    private String notes;
    private String description;
    private String damageDice;
    private String damageType;
    private String weaponRange;
    private java.util.List<String> weaponProperties = new java.util.ArrayList<>();
    private int bonusAc;
    private int bonusToHit;
    private int bonusSavingThrows;
    private String infusionName;
    private String infusionDescription;
    private String infusionBonusTarget;
    private int infusionBonusValue;
    private boolean needsBaseWeaponChoice;
    private String baseWeaponIndexName;
    private String baseWeaponName;

    // Getters y Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getCharacterId() {
        return characterId;
    }

    public void setCharacterId(Long characterId) {
        this.characterId = characterId;
    }

    public String getCharacterName() {
        return characterName;
    }

    public void setCharacterName(String characterName) {
        this.characterName = characterName;
    }

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getItemType() {
        return itemType;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getWeight() {
        return weight;
    }

    public void setWeight(double weight) {
        this.weight = weight;
    }

    public double getTotalWeight() {
        return totalWeight;
    }

    public void setTotalWeight(double totalWeight) {
        this.totalWeight = totalWeight;
    }

    public boolean isEquipped() {
        return equipped;
    }

    public void setEquipped(boolean equipped) {
        this.equipped = equipped;
    }

    public boolean isAttuned() {
        return attuned;
    }

    public void setAttuned(boolean attuned) {
        this.attuned = attuned;
    }
    

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public boolean isRequiresAttunement() {
        return requiresAttunement;
    }

    public void setRequiresAttunement(boolean requiresAttunement) {
        this.requiresAttunement = requiresAttunement;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDamageDice() {
        return damageDice;
    }

    public void setDamageDice(String damageDice) {
        this.damageDice = damageDice;
    }

    public String getDamageType() {
        return damageType;
    }

    public void setDamageType(String damageType) {
        this.damageType = damageType;
    }

    public String getWeaponRange() {
        return weaponRange;
    }

    public void setWeaponRange(String weaponRange) {
        this.weaponRange = weaponRange;
    }

    public java.util.List<String> getWeaponProperties() {
        return weaponProperties;
    }

    public void setWeaponProperties(java.util.List<String> weaponProperties) {
        this.weaponProperties = weaponProperties;
    }

    public int getBonusAc() {
        return bonusAc;
    }

    public void setBonusAc(int bonusAc) {
        this.bonusAc = bonusAc;
    }

    public int getBonusToHit() {
        return bonusToHit;
    }

    public void setBonusToHit(int bonusToHit) {
        this.bonusToHit = bonusToHit;
    }

    public int getBonusSavingThrows() {
        return bonusSavingThrows;
    }

    public void setBonusSavingThrows(int bonusSavingThrows) {
        this.bonusSavingThrows = bonusSavingThrows;
    }

    public String getInfusionName() {
        return infusionName;
    }

    public void setInfusionName(String infusionName) {
        this.infusionName = infusionName;
    }

    public String getInfusionDescription() {
        return infusionDescription;
    }

    public void setInfusionDescription(String infusionDescription) {
        this.infusionDescription = infusionDescription;
    }

    public String getInfusionBonusTarget() {
        return infusionBonusTarget;
    }

    public void setInfusionBonusTarget(String infusionBonusTarget) {
        this.infusionBonusTarget = infusionBonusTarget;
    }

    public int getInfusionBonusValue() {
        return infusionBonusValue;
    }

    public void setInfusionBonusValue(int infusionBonusValue) {
        this.infusionBonusValue = infusionBonusValue;
    }

    public boolean isNeedsBaseWeaponChoice() {
        return needsBaseWeaponChoice;
    }

    public void setNeedsBaseWeaponChoice(boolean needsBaseWeaponChoice) {
        this.needsBaseWeaponChoice = needsBaseWeaponChoice;
    }

    public String getBaseWeaponIndexName() {
        return baseWeaponIndexName;
    }

    public void setBaseWeaponIndexName(String baseWeaponIndexName) {
        this.baseWeaponIndexName = baseWeaponIndexName;
    }

    public String getBaseWeaponName() {
        return baseWeaponName;
    }

    public void setBaseWeaponName(String baseWeaponName) {
        this.baseWeaponName = baseWeaponName;
    }
}