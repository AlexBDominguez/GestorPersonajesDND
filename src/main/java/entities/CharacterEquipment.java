package entities;

import jakarta.persistence.*;

@Entity
@Table(name = "character_equipment")
public class CharacterEquipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "character_id", nullable = false, unique = true)
    private PlayerCharacter character;

    // Slots de equipamiento
    @ManyToOne
    @JoinColumn(name = "main_hand_item_id")
    private Item mainHand;

    @ManyToOne
    @JoinColumn(name = "off_hand_item_id")
    private Item offHand;

    @ManyToOne
    @JoinColumn(name = "armor_id")
    private Item armor;

    @ManyToOne
    @JoinColumn(name = "helmet_id")
    private Item helmet;

    @ManyToOne
    @JoinColumn(name = "gloves_id")
    private Item gloves;

    @ManyToOne
    @JoinColumn(name = "boots_id")
    private Item boots;

    @ManyToOne
    @JoinColumn(name = "cloak_id")
    private Item cloak;

    @ManyToOne
    @JoinColumn(name = "amulet_id")
    private Item amulet;

    @ManyToOne
    @JoinColumn(name = "ring1_id")
    private Item ring1;

    @ManyToOne
    @JoinColumn(name = "ring2_id")
    private Item ring2;

    @ManyToOne
    @JoinColumn(name = "belt_id")
    private Item belt;

    public CharacterEquipment() {}

    public CharacterEquipment(PlayerCharacter character) {
        this.character = character;
    }

    // Getters y Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public PlayerCharacter getCharacter() {
        return character;
    }

    public void setCharacter(PlayerCharacter character) {
        this.character = character;
    }

    public Item getMainHand() {
        return mainHand;
    }

    public void setMainHand(Item mainHand) {
        this.mainHand = mainHand;
    }

    public Item getOffHand() {
        return offHand;
    }

    public void setOffHand(Item offHand) {
        this.offHand = offHand;
    }

    public Item getArmor() {
        return armor;
    }

    public void setArmor(Item armor) {
        this.armor = armor;
    }

    public Item getHelmet() {
        return helmet;
    }

    public void setHelmet(Item helmet) {
        this.helmet = helmet;
    }

    public Item getGloves() {
        return gloves;
    }

    public void setGloves(Item gloves) {
        this.gloves = gloves;
    }

    public Item getBoots() {
        return boots;
    }

    public void setBoots(Item boots) {
        this.boots = boots;
    }

    public Item getCloak() {
        return cloak;
    }

    public void setCloak(Item cloak) {
        this.cloak = cloak;
    }

    public Item getAmulet() {
        return amulet;
    }

    public void setAmulet(Item amulet) {
        this.amulet = amulet;
    }

    public Item getRing1() {
        return ring1;
    }

    public void setRing1(Item ring1) {
        this.ring1 = ring1;
    }

    public Item getRing2() {
        return ring2;
    }

    public void setRing2(Item ring2) {
        this.ring2 = ring2;
    }

    public Item getBelt() {
        return belt;
    }

    public void setBelt(Item belt) {
        this.belt = belt;
    }
}