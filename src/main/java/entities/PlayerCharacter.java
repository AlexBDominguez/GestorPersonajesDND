package entities;

import jakarta.persistence.*;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;


@Entity
@Table(name = "characters")
public class PlayerCharacter {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private int level;
    
    
    @ManyToOne
    @JoinColumn(name = "race_id")
    private Race race;

    @ManyToOne
    @JoinColumn(name = "class_id")
    private DndClass dndClass;

    @ManyToOne
    @JoinColumn(name = "subclass_id")
    private Subclass subclass;

    @ManyToOne
    @JoinColumn(name = "background_id")
    private Background background;

    //Monedas
    private int copperPieces = 0;
    private int silverPieces = 0;
    private int electrumPieces = 0;
    private int goldPieces = 0;
    private int platinumPieces = 0;

    //Métodos transient para calcular

    @Transient
    public int getCarryingCapacity() {
        Integer str = abilityScores.get("str");
        if (str == null) return 150;
        return str * 15;
    }

    @Transient
    public int getAttunementSlotUsed(){
        //Lo calcularemos desde el servicio
        return 0; //Placeholder
    }

    @Transient
    public int getMaxAttunementSlots(){
        return 3;
    }
        

    //Características personales elegidas por el jugador
    @Column(columnDefinition = "TEXT")
    private String personalityTraits;

    @Column(columnDefinition = "TEXT")
    private String ideals;

    @Column(columnDefinition = "TEXT")
    private String bonds;

    @Column(columnDefinition = "TEXT")
    private String flaws;

    @ElementCollection
    @CollectionTable(name = "character_abilities", joinColumns = @JoinColumn(name = "character_id"))
    @MapKeyColumn(name = "ability")
    @Column(name = "score")
    private Map<String, Integer> abilityScores;

    private int maxHP;
    private int currentHP;

    private int proficiencyBonus;

    @Column(columnDefinition = "TEXT")
    private String backstory;

    @OneToMany(mappedBy = "character", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<CharacterSpell> characterSpells = new HashSet<>();


    @Transient
    public int calculateAbilityModifier(String abilityScore) {
        Integer score = abilityScores.get(abilityScore);
        if (score == null) return 0;
        return (score - 10) / 2;
    }

    @Transient
    public int getPassivePerception(){
        //Buscar skill de Perception
        //Deolver 10 + WIS mod
        return 10 + calculateAbilityModifier("wis");        
    }

    @Transient
    public int getPassiveInvestigation(){
        return 10 + calculateAbilityModifier("int");
    }

    @Transient
    public int getPassiveInsight(){
        return 10 + calculateAbilityModifier("wis");
    }

    

    public PlayerCharacter(){}

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

    public Race getRace() {
        return race;
    }

    public void setRace(Race race) {
        this.race = race;
    }

    public DndClass getDndClass() {
        return dndClass;
    }

    public void setDndClass(DndClass dndClass) {
        this.dndClass = dndClass;
    }

    public Map<String, Integer> getAbilityScores() {
        return abilityScores;
    }

    public void setAbilityScores(Map<String, Integer> abilityScores) {
        this.abilityScores = abilityScores;
    }

    public int getMaxHP() {
        return maxHP;
    }

    public void setMaxHP(int maxHP) {
        this.maxHP = maxHP;
    }

    public int getCurrentHP() {
        return currentHP;
    }

    public void setCurrentHP(int currentHP) {
        this.currentHP = currentHP;
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

    public Background getBackground() {
        return background;
    }

    public void setBackground(Background background) {
        this.background = background;
    }

    public Subclass getSubclass() {
        return subclass;
    }

    public void setSubclass(Subclass subclass) {
        this.subclass = subclass;
    }

    public String getPersonalityTraits() {
        return personalityTraits;
    }

    public void setPersonalityTraits(String personalityTraits) {
        this.personalityTraits = personalityTraits;
    }

    public String getIdeals() {
        return ideals;
    }

    public void setIdeals(String ideals) {
        this.ideals = ideals;
    }

    public String getBonds() {
        return bonds;
    }

    public void setBonds(String bonds) {
        this.bonds = bonds;
    }

    public String getFlaws() {
        return flaws;
    }

    public void setFlaws(String flaws) {
        this.flaws = flaws;
    }

    public Set<CharacterSpell> getCharacterSpells() {
        return characterSpells;
    }

    public void setCharacterSpells(Set<CharacterSpell> characterSpells) {
        this.characterSpells = characterSpells;
    }

    public int getCopperPieces() {
        return copperPieces;
    }

    public void setCopperPieces(int copperPieces) {
        this.copperPieces = copperPieces;
    }

    public int getSilverPieces() {
        return silverPieces;
    }

    public void setSilverPieces(int silverPieces) {
        this.silverPieces = silverPieces;
    }

    public int getElectrumPieces() {
        return electrumPieces;
    }

    public void setElectrumPieces(int electrumPieces) {
        this.electrumPieces = electrumPieces;
    }

    public int getGoldPieces() {
        return goldPieces;
    }

    public void setGoldPieces(int goldPieces) {
        this.goldPieces = goldPieces;
    }

    public int getPlatinumPieces() {
        return platinumPieces;
    }

    public void setPlatinumPieces(int platinumPieces) {
        this.platinumPieces = platinumPieces;
    }

    



    
}
