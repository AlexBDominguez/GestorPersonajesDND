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

    //Alineamiento
    private String alignment;

    // HP temporal (se pierde antes que el HP normal)
    private int temporaryHP = 0;

    //Death Saves
    private int deathSaveSuccesses = 0;
    private int deathSaveFailures = 0;

    //Inspiration dada por el DM
    private boolean hasInspiration = false;

    //Experiencia
    private int experiencePoints = 0;

    //Velocidad (puede ser modificada por condiciones, armadura, etc.)
    //El valor base viene de la raza, este es el modificador
    private int speedModifier = 0;

    //Armor Class base (sin armadura, normalmente 10 + DEX mod
    //Este campo se pued usar para AC natural de ciertas razas/clases
    private Integer naturalArmorBonus;

    //Initiative bonus adicional (además del DEX mod)
    private int initiativeBonus = 0;

    //Hit Dice disponibles (para recuperar HP durante un descanso corto)
    private int availableHitDice;

    //Edad, altura, peso, etc (campos descriptivos opcionales)
    private Integer age;
    private String height;
    private String weight;
    private String eyes;
    private String skin;
    private String hair;

    //Apariencia y descripción física
    @Column(columnDefinition = "TEXT")
    private String appearance;

    //Aliados y organizaciones
    @Column(columnDefinition = "TEXT")
    private String alliesAndOrganizations;

    //Tesoros y posesiones adicionales
    @Column(columnDefinition = "TEXT")
    private String additionalTreasure;

    //Historia del personaje (más detallada que el backstory)
    @Column(columnDefinition = "TEXT")
    private String characterHistory;

    //Getters y setters

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

    public String getAlignment() {
        return alignment;
    }

    public void setAlignment(String alignment) {
        this.alignment = alignment;
    }

    public int getTemporaryHP() {
        return temporaryHP;
    }

    public void setTemporaryHP(int temporaryHP) {
        this.temporaryHP = temporaryHP;
    }

    public int getDeathSaveSuccesses() {
        return deathSaveSuccesses;
    }

    public void setDeathSaveSuccesses(int deathSaveSuccesses) {
        this.deathSaveSuccesses = deathSaveSuccesses;
    }

    public int getDeathSaveFailures() {
        return deathSaveFailures;
    }

    public void setDeathSaveFailures(int deathSaveFailures) {
        this.deathSaveFailures = deathSaveFailures;
    }

    public boolean isHasInspiration() {
        return hasInspiration;
    }

    public void setHasInspiration(boolean hasInspiration) {
        this.hasInspiration = hasInspiration;
    }

    public int getExperiencePoints() {
        return experiencePoints;
    }

    public void setExperiencePoints(int experiencePoints) {
        this.experiencePoints = experiencePoints;
    }

    public int getSpeedModifier() {
        return speedModifier;
    }

    public void setSpeedModifier(int speedModifier) {
        this.speedModifier = speedModifier;
    }

    public Integer getNaturalArmorBonus() {
        return naturalArmorBonus;
    }

    public void setNaturalArmorBonus(Integer naturalArmorBonus) {
        this.naturalArmorBonus = naturalArmorBonus;
    }

    public int getInitiativeBonus() {
        return initiativeBonus;
    }

    public void setInitiativeBonus(int initiativeBonus) {
        this.initiativeBonus = initiativeBonus;
    }

    public int getAvailableHitDice() {
        return availableHitDice;
    }

    public void setAvailableHitDice(int availableHitDice) {
        this.availableHitDice = availableHitDice;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getHeight() {
        return height;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public String getWeight() {
        return weight;
    }

    public void setWeight(String weight) {
        this.weight = weight;
    }

    public String getEyes() {
        return eyes;
    }

    public void setEyes(String eyes) {
        this.eyes = eyes;
    }

    public String getSkin() {
        return skin;
    }

    public void setSkin(String skin) {
        this.skin = skin;
    }

    public String getHair() {
        return hair;
    }

    public void setHair(String hair) {
        this.hair = hair;
    }

    public String getAppearance() {
        return appearance;
    }

    public void setAppearance(String appearance) {
        this.appearance = appearance;
    }

    public String getAlliesAndOrganizations() {
        return alliesAndOrganizations;
    }

    public void setAlliesAndOrganizations(String alliesAndOrganizations) {
        this.alliesAndOrganizations = alliesAndOrganizations;
    }

    public String getAdditionalTreasure() {
        return additionalTreasure;
    }

    public void setAdditionalTreasure(String additionalTreasure) {
        this.additionalTreasure = additionalTreasure;
    }

    public String getCharacterHistory() {
        return characterHistory;
    }

    public void setCharacterHistory(String characterHistory) {
        this.characterHistory = characterHistory;
    }


    
}
