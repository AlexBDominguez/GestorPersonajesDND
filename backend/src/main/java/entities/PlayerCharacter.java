package entities;

import jakarta.persistence.*;

import java.util.HashSet;
import java.util.List;
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

    //Relación con el usuario
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    //Preferencia de encumbrance (activado en el wizard)
    private boolean useEncumbrance = false;


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

    public boolean isUseEncumbrance() {
        return useEncumbrance;
    }

    public void setUseEncumbrance(boolean useEncumbrance) {
        this.useEncumbrance = useEncumbrance;
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }


    // ========== MÉTODOS DE CÁLCULO AUTOMÁTICO ==========


    @Transient
    public int getAttunementSlotUsed(){
        //Lo calcularemos desde el servicio
        return 0; //Placeholder
    }

    @Transient
    public int getMaxAttunementSlots(){
        return 3;
    }

    @Transient
    public int calculateAbilityModifier(String abilityScore) {
        if (abilityScores == null || abilityScore == null) return 0;
        // Buscar insensible a mayúsculas/minúsculas para compatibilidad con datos existentes
        Integer score = abilityScores.get(abilityScore);
        if (score == null) score = abilityScores.get(abilityScore.toLowerCase());
        if (score == null) score = abilityScores.get(abilityScore.toUpperCase());
        if (score == null) return 0;
        return (score - 10) / 2;
    }


        /**
     * Calcula la Armor Class (AC) del personaje
     * Considera armadura equipada, modificador DEX, bonificador natural y efectos activos
     */
    @Transient
    public int getArmorClass(CharacterEquipment equipment, List<CharacterActiveEffect> activeEffects) {
        int baseAC = 10;
        int dexModifier = calculateAbilityModifier("dex");
        
        // Si tiene armadura equipada
        if (equipment != null && equipment.getArmor() != null) {
            Item armor = equipment.getArmor();
            Integer armorAC = armor.getArmorClass();
            
            if (armorAC != null) {
                String armorType = armor.getArmorType();
                
                if ("Light".equalsIgnoreCase(armorType)) {
                    baseAC = armorAC + dexModifier;
                    
                } else if ("Medium".equalsIgnoreCase(armorType)) {
                    int maxDexBonus = armor.getMaxDexBonus() != null ? armor.getMaxDexBonus() : 2;
                    baseAC = armorAC + Math.min(dexModifier, maxDexBonus);
                    
                } else if ("Heavy".equalsIgnoreCase(armorType)) {
                    baseAC = armorAC;
                }
            }
        } else {
            // Sin armadura: 10 + DEX
            baseAC = baseAC + dexModifier;
            
            // Bonificador de armadura natural (algunas razas)
            if (naturalArmorBonus != null) {
                baseAC = Math.max(baseAC, naturalArmorBonus + dexModifier);
            }
        }
        
        // Escudo (+2 AC si está equipado)
        if (equipment != null && equipment.getOffHand() != null) {
            Item offHand = equipment.getOffHand();
            if ("Shield".equalsIgnoreCase(offHand.getItemType())) {
                baseAC += 2;
            }
        }
        
        // Bonificadores de efectos activos (ej: Shield of Faith, Shield spell, etc.)
        if (activeEffects != null) {
            for (CharacterActiveEffect effect : activeEffects) {
                if (effect.isActive() && 
                    effect.getEffect().getModifierTypes() != null && 
                    effect.getEffect().getModifierTypes().contains(enumeration.EffectModifierType.AC)) {
                    
                    String modifierValue = effect.getEffect().getModifierValue();
                    baseAC += parseModifier(modifierValue);
                }
            }
        }
        
        return baseAC;
    }

    /**
     * Parsea un modificador en formato string (ej: "+2", "+5", etc.)
     * Para efectos más complejos como "+1d4" se podría extender
     */
    @Transient
    private int parseModifier(String modifierValue) {
        if (modifierValue == null || modifierValue.isEmpty()) {
            return 0;
        }
        
        try {
            // Remover el signo '+' si existe y parsear
            return Integer.parseInt(modifierValue.replace("+", ""));
        } catch (NumberFormatException e) {
            // Si no es un número simple (ej: "+1d4"), devolver 0
            // En el futuro se podría implementar un parser más complejo
            return 0;
        }
    }

    /**
     * Calcula el Spell Save DC (dificultad para resistir los hechizos del personaje)
     * Fórmula: 8 + proficiency bonus + spellcasting ability modifier
     * Solo aplica si la clase tiene spellcasting
     */

    @Transient
    public int getSpellSaveDC() {
        if (dndClass == null || dndClass.getSpellcastingAbility() == null) {
            return 0; // No es lanzador de hechizos

        }
        String spellcastingAbility = dndClass.getSpellcastingAbility();
        int abilityModifier = calculateAbilityModifier(spellcastingAbility);

        return 8 + proficiencyBonus + abilityModifier;
    }

    /**
     * Calcula el bonificador de ataque para hechizos
     * Fórmula: proficiency bonus + spellcasting ability modifier
     * Solo aplica si la clase tiene spellcasting
     */

    @Transient
    public int getSpellAttackBonus(){
        if(dndClass == null || dndClass.getSpellcastingAbility() == null) {
            return 0; // No es lanzador de hechizos
        }

        String spellcastingAbility = dndClass.getSpellcastingAbility();
        int abilityModifier = calculateAbilityModifier(spellcastingAbility);

        return proficiencyBonus + abilityModifier;
    }

    /**
     * Calcula el modificador de iniciativa
     * Base: DEX modifier + initiative bonus (de features, items, etc)
     */
    @Transient
    public int getInitiativeModifier(){
        int dexModifier = calculateAbilityModifier("dex");
        return dexModifier + initiativeBonus;
    }

    /**
     * Calcula la velocidad de movimiento actual
     * Base: velocidad de la raza + modificadores
     */
    @Transient
    public int getCurrentSpeed(){
        if(race == null) {
            return 30; // Velocidad base si no se ha seleccionado raza
        }

        int baseSpeed = race.getSpeed();
        int totalSpeed = baseSpeed + speedModifier;

        //no puede ser negativa
        return Math.max(0, totalSpeed);
    }

    /**
     * Calcula el bonificador de competencia según el nivel
     * Se podría usar en lugar de guardar el valor en la BD
     * Formula: 2 + ((nivel - 1) / 4)
     */

    @Transient
    public int calculateProficiencyBonus() {
        return 2 + ((level - 1) / 4);
    }


    /**
     * Calcula el numero maximo de hechizos que puede tener preparados
     * Formula: spellcasting ability modifier + nivel
     * Minimo 1
     * Solo para clases que preparan hechizos (Wizard, Cleric, Druid, Paladin)
     */

    @Transient
    public int getMaxPreparedSpells(){
        if(dndClass == null || dndClass.getSpellcastingAbility() == null) {
            return 0; // No es lanzador de hechizos
        }

    // Algunas clases no preparan hechizos (Bard, Sorcerer, Warlock, Ranger conocen hechizos)
    //Esto se podría refinar con un campo en DndClass
        String spellcastingAbility = dndClass.getSpellcastingAbility();
        int abilityModifier = calculateAbilityModifier(spellcastingAbility);

        return Math.max(1, abilityModifier + level);
    }

    /**
     * Calcula la capacidad de carga máxima
     * Fórmula: STR × 15 (en libras)
     */
    @Transient
    public int getCarryingCapacity() {
        Integer str = abilityScores.get("str");
        if (str == null) return 150; // Valor por defecto (STR 10)
        return str * 15;
    }

    /**
     * Calcula el peso que causa que el personaje esté Encumbered (sobrecargado)
     * Velocidad reducida en 10 pies
     * Fórmula: STR × 5
     */
    @Transient
    public int getEncumberedThreshold() {
        Integer str = abilityScores.get("str");
        if (str == null) return 50;
        return str * 5;
    }

    /**
     * Calcula el peso que causa que el personaje esté Heavily Encumbered
     * Velocidad reducida en 20 pies y desventaja en checks físicos
     * Fórmula: STR × 10
     */
    @Transient
    public int getHeavilyEncumberedThreshold() {
        Integer str = abilityScores.get("str");
        if (str == null) return 100;
        return str * 10;
    }

    /**
     * Calcula el bonificador de ataque cuerpo a cuerpo básico
     * Normalmente usa STR, pero algunas armas pueden usar DEX (finesse)
     * Fórmula: proficiency bonus + ability modifier (STR)
     */

    @Transient
    public int getMeleeAttackBonus(){
        int strModifier = calculateAbilityModifier("str");
        return proficiencyBonus + strModifier;
    }

    /**
    * Bonificador de ataque con armas Finesse (usando DEX)
    * Fórmula: proficiency bonus + DEX modifier
    */
    @Transient
    public int getFinesseAttackBonus() {
        int dexModifier = calculateAbilityModifier("dex");
        return proficiencyBonus + dexModifier;
    }

    /**
     * Calcula el bonificador de ataque a distancia
     * Fórmula: proficiency bonus + DEX modifier
     */
    @Transient
    public int getRangedAttackBonus() {
        int dexModifier = calculateAbilityModifier("dex");
        return proficiencyBonus + dexModifier;
    }

    /**
     * Calcula Passive Perception
     * Fórmula: 10 + WIS modifier + (proficiency si tiene proficiencia en Perception)
     */
    @Transient
    public int getPassivePerception(List<CharacterSkill> characterSkills) {
        int wisModifier = calculateAbilityModifier("wis");
        int bonus = 10 + wisModifier;
        
        // Verificar si tiene proficiencia en Perception
        boolean hasProficiency = characterSkills.stream()
                .anyMatch(cs -> cs.getSkill().getIndexName().equals("perception") && cs.isProficient());
        
        if (hasProficiency) {
            bonus += proficiencyBonus;
        }
        
        return bonus;
    }

    /**
     * Calcula Passive Investigation
     * Fórmula: 10 + INT modifier + (proficiency si tiene proficiencia en Investigation)
     */
    @Transient
    public int getPassiveInvestigation(List<CharacterSkill> characterSkills) {
        int intModifier = calculateAbilityModifier("int");
        int bonus = 10 + intModifier;
        
        // Verificar si tiene proficiencia en Investigation
        boolean hasProficiency = characterSkills.stream()
                .anyMatch(cs -> cs.getSkill().getIndexName().equals("investigation") && cs.isProficient());
        
        if (hasProficiency) {
            bonus += proficiencyBonus;
        }
        
        return bonus;
    }

    /**
     * Calcula Passive Insight
     * Fórmula: 10 + WIS modifier + (proficiency si tiene proficiencia en Insight)
     */
    @Transient
    public int getPassiveInsight(List<CharacterSkill> characterSkills) {
        int wisModifier = calculateAbilityModifier("wis");
        int bonus = 10 + wisModifier;
        
        // Verificar si tiene proficiencia en Insight
        boolean hasProficiency = characterSkills.stream()
                .anyMatch(cs -> cs.getSkill().getIndexName().equals("insight") && cs.isProficient());
        
        if (hasProficiency) {
            bonus += proficiencyBonus;
        }
        
        return bonus;
    }

    /**
     * DC para Death Saves (siempre es 10 en D&D 5e)
     */
    @Transient
    public int getDeathSaveDC() {
    return 10;
    }

    /**
     * Verifica si el persona está muriendo (a 0 HP pero no estabilizado)
     */

    @Transient
    public boolean isDying() {
        return currentHP == 0 && (deathSaveSuccesses < 3) && (deathSaveFailures < 3);
    }

    /**
     * Verifica si el personaje está estabilizado (a 0 HP pero con 3 saves exitosos)
     */
    @Transient
    public boolean isStable() {
        return currentHP == 0 && deathSaveSuccesses >= 3;
    }

    /**
     * Verifica si el personaje está muerto (3 death save failures)
     */
    @Transient
    public boolean isDead() {
        return deathSaveFailures >= 3;
    }

    /**
     * Verifica si el personaje está consciente
     */
    @Transient
    public boolean isConscious() {
    return currentHP > 0;
    }


    /**
     * Calcula la experiencia necesaria para el siguiente nivel
     * Basado en la tabla de progresión de D&D 5e
    */
    @Transient
    public int getExperienceToNextLevel() {
        // Tabla oficial de D&D 5e
        int[] xpTable = {
            0,      // Nivel 1
            300,    // Nivel 2
            900,    // Nivel 3
            2700,   // Nivel 4
            6500,   // Nivel 5
            14000,  // Nivel 6
            23000,  // Nivel 7
            34000,  // Nivel 8
            48000,  // Nivel 9
            64000,  // Nivel 10
            85000,  // Nivel 11
            100000, // Nivel 12
            120000, // Nivel 13
            140000, // Nivel 14
            165000, // Nivel 15
            195000, // Nivel 16
            225000, // Nivel 17
            265000, // Nivel 18
            305000, // Nivel 19
            355000  // Nivel 20
        };
        
        if (level >= 20) {
            return xpTable[19]; // Nivel máximo
        }
        
        return xpTable[level]; // XP necesaria para el siguiente nivel
    }

    /**
     * Calcula cuánta XP falta para el siguiente nivel
     */
    @Transient
    public int getExperienceNeeded() {
        return Math.max(0, getExperienceToNextLevel() - experiencePoints);
    }

    




}
    




    

