package dto;

public class CharacterMoneyDto {
    private Long id;
    private Long characterId;
    private String characterName;
    private int platinum;
    private int gold;
    private int electrum;
    private int silver;
    private int copper;
    private double totalInGold; // Calculado
    private double moneyWeight; // Calculado

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

    public double getTotalInGold() {
        return totalInGold;
    }

    public void setTotalInGold(double totalInGold) {
        this.totalInGold = totalInGold;
    }

    public double getMoneyWeight() {
        return moneyWeight;
    }

    public void setMoneyWeight(double moneyWeight) {
        this.moneyWeight = moneyWeight;
    }
}