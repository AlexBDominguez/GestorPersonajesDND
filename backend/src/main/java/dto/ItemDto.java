package dto;

import java.util.List;

public class ItemDto {
    private Long id;
    private String indexName;
    private String name;
    private String itemType;
    private String category;
    private double weight;
    private int costInCopper;
    private String description;

    //Weapon
    private String damageDice;
    private String damageType;
    private String weaponRange;
    private List<String> weaponProperties;

    //Armor
    private Integer armorClass;
    private String armorType;

    //Magic
    private String rarity;
    private boolean requiresAttunement;

    // Bonos mecánicos (#21) -- ausentes de este DTO hasta ahora, aunque ya existen en Item
    // desde que #21 les dio efecto real. Necesarios para que un item creado a mano en el
    // panel de admin (#9) pueda tener un bono de verdad, no solo texto descriptivo.
    private int bonusAc;
    private int bonusToHit;
    private int bonusDamage;
    private int bonusSavingThrows;
    private Integer setStrTo;
    private Integer setDexTo;
    private Integer setConTo;
    private Integer setIntTo;
    private Integer setWisTo;
    private Integer setChaTo;


     //Getters & setters
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getIndexName() {
        return indexName;
    }
    public void setIndexName(String indexName) {
        this.indexName = indexName;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getItemType() {
        return itemType;
    }
    public void setItemType(String itemType) {
        this.itemType = itemType;
    }
    public String getCategory() {
        return category;
    }
    public void setCategory(String category) {
        this.category = category;
    }
    public double getWeight() {
        return weight;
    }
    public void setWeight(double weight) {
        this.weight = weight;
    }
    public int getCostInCopper() {
        return costInCopper;
    }
    public void setCostInCopper(int costInCopper) {
        this.costInCopper = costInCopper;
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
    public List<String> getWeaponProperties() {
        return weaponProperties;
    }
    public void setWeaponProperties(List<String> weaponProperties) {
        this.weaponProperties = weaponProperties;
    }
    public Integer getArmorClass() {
        return armorClass;
    }
    public void setArmorClass(Integer armorClass) {
        this.armorClass = armorClass;
    }
    public String getArmorType() {
        return armorType;
    }
    public void setArmorType(String armorType) {
        this.armorType = armorType;
    }
    public String getRarity() {
        return rarity;
    }
    public void setRarity(String rarity) {
        this.rarity = rarity;
    }
    public boolean isRequiresAttunement() {
        return requiresAttunement;
    }
    public void setRequiresAttunement(boolean requiresAttunement) {
        this.requiresAttunement = requiresAttunement;
    }

    public int getBonusAc() { return bonusAc; }
    public void setBonusAc(int bonusAc) { this.bonusAc = bonusAc; }

    public int getBonusToHit() { return bonusToHit; }
    public void setBonusToHit(int bonusToHit) { this.bonusToHit = bonusToHit; }

    public int getBonusDamage() { return bonusDamage; }
    public void setBonusDamage(int bonusDamage) { this.bonusDamage = bonusDamage; }

    public int getBonusSavingThrows() { return bonusSavingThrows; }
    public void setBonusSavingThrows(int bonusSavingThrows) { this.bonusSavingThrows = bonusSavingThrows; }

    public Integer getSetStrTo() { return setStrTo; }
    public void setSetStrTo(Integer setStrTo) { this.setStrTo = setStrTo; }

    public Integer getSetDexTo() { return setDexTo; }
    public void setSetDexTo(Integer setDexTo) { this.setDexTo = setDexTo; }

    public Integer getSetConTo() { return setConTo; }
    public void setSetConTo(Integer setConTo) { this.setConTo = setConTo; }

    public Integer getSetIntTo() { return setIntTo; }
    public void setSetIntTo(Integer setIntTo) { this.setIntTo = setIntTo; }

    public Integer getSetWisTo() { return setWisTo; }
    public void setSetWisTo(Integer setWisTo) { this.setWisTo = setWisTo; }

    public Integer getSetChaTo() { return setChaTo; }
    public void setSetChaTo(Integer setChaTo) { this.setChaTo = setChaTo; }
}
