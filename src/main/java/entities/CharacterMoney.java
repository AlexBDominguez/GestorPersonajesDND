package entities;

import jakarta.persistence.*;

@Entity
@Table(name = "character_money")
public class CharacterMoney {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "character_id", nullable = false, unique = true)
    private PlayerCharacter character;

    private int platinum = 0;
    private int gold = 0;
    private int electrum = 0;
    private int silver = 0;
    private int copper = 0;

    public CharacterMoney() {}

    public CharacterMoney(PlayerCharacter character) {
        this.character = character;
    }

    /**
     * Calcula el total en piezas de oro (conversión estándar)
     * 1 pp = 10 gp
     * 1 gp = 1 gp
     * 1 ep = 0.5 gp
     * 1 sp = 0.1 gp
     * 1 cp = 0.01 gp
     */
    @Transient
    public double getTotalInGold() {
        return (platinum * 10) + gold + (electrum * 0.5) + (silver * 0.1) + (copper * 0.01);
    }

    /**
     * Calcula el peso total del dinero en libras
     * 50 monedas = 1 libra
     */
    @Transient
    public double getMoneyWeight() {
        int totalCoins = platinum + gold + electrum + silver + copper;
        return totalCoins / 50.0;
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

    public int getPlatinum() {
        return platinum;
    }

    public void setPlatinum(int platinum) {
        this.platinum = platinum;
    }

    public int getGold() {
        return gold;
    }

    public void setGold(int gold) {
        this.gold = gold;
    }

    public int getElectrum() {
        return electrum;
    }

    public void setElectrum(int electrum) {
        this.electrum = electrum;
    }

    public int getSilver() {
        return silver;
    }

    public void setSilver(int silver) {
        this.silver = silver;
    }

    public int getCopper() {
        return copper;
    }

    public void setCopper(int copper) {
        this.copper = copper;
    }
}