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

   
    
}
