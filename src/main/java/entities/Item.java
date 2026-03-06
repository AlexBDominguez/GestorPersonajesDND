package entities;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;

@Entity
@Table(name = "items")
public class Item {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String indexName;

    private String name;

    private String itemType;

    private String category;

    private double weight;

    private int costInCopper;

    @Column(columnDefinition = "TEXT")
    private String description;

    //Para armas
    private String damageDice;
    private String damageType;
    private String weaponRange;

    @ElementCollection
    @CollectionTable(name = "item_properties", joinColumns = @JoinColumn(name = "item_id"))
    @Column(name = "property")
    private java.util.List<String> weaponProperties;

    //Para armaduras
    private Integer armorClass;
    private String armorType;
    private Integer maxDexBonus;
    private Integer minimumStrength;
    private boolean stealthDisadvantage;

    //Para magic items
    private String rarity;
    private boolean requiresAttunement;
    private String attunementRequierement;

    public Item(){}

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

    public java.util.List<String> getWeaponProperties() {
        return weaponProperties;
    }

    public void setWeaponProperties(java.util.List<String> weaponProperties) {
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

    public Integer getMaxDexBonus() {
        return maxDexBonus;
    }

    public void setMaxDexBonus(Integer maxDexBonus) {
        this.maxDexBonus = maxDexBonus;
    }

    public Integer getMinimumStrength() {
        return minimumStrength;
    }

    public void setMinimumStrength(Integer minimumStrength) {
        this.minimumStrength = minimumStrength;
    }

    public boolean isStealthDisadvantage() {
        return stealthDisadvantage;
    }

    public void setStealthDisadvantage(boolean stealthDisadvantage) {
        this.stealthDisadvantage = stealthDisadvantage;
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

    public String getAttunementRequierement() {
        return attunementRequierement;
    }

    public void setAttunementRequierement(String attunementRequierement) {
        this.attunementRequierement = attunementRequierement;
    }

        
    
}
