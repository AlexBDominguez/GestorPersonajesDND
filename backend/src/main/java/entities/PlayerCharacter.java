package entities;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.HashMap;
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
    @JoinColumn(name = "subrace_id")
    private Subrace subrace;

    @ManyToOne
    @JoinColumn(name = "class_id")
    private DndClass dndClass;

    @ManyToOne
    @JoinColumn(name = "subclass_id")
    private Subclass subclass;

    // Fundamento de multiclase: cada clase que ha tomado el personaje, con su propio nivel.
    // dndClass/subclass/level de arriba siguen siendo la fuente de verdad para personajes
    // mono-clase (se mantienen en paralelo, "dual-write") y reflejan la clase con classOrder=0.
    @OneToMany(mappedBy = "character", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<PlayerCharacterClass> classes = new HashSet<>();

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

    // Tirada de HP por nivel (nivel → valor tirado, sin incluir nivel 1, que siempre es
    // dado máximo + conMod). Si un nivel no tiene entrada aquí, su contribución al HP se
    // calculó con la media del dado (hitDie/2 + 1) en vez de una tirada manual del jugador.
    @ElementCollection
    @CollectionTable(name = "character_hp_rolls", joinColumns = @JoinColumn(name = "character_id"))
    @MapKeyColumn(name = "level")
    @Column(name = "roll")
    private Map<Integer, Integer> hpRolls = new HashMap<>();

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

    //Bonus a Passive Perception y Passive Investigation (p.ej. dote Observant: +5)
    private int passiveSensesBonus = 0;

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

    // Preferencia de visualización de ability scores en la ficha
    // Valores: "SCORES_TOP" (por defecto) o "MODIFIERS_TOP"
    private String abilityDisplayMode = "SCORES_TOP";

    @ElementCollection
    @CollectionTable(name = "character_selected_sources", joinColumns = @JoinColumn(name = "character_id"))
    @Column(name = "source")
    private List<String> selectedSources = new ArrayList<>(List.of("PHB"));


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

    public Subrace getSubrace() {
        return subrace;
    }

    public void setSubrace(Subrace subrace) {
        this.subrace = subrace;
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

    public Map<Integer, Integer> getHpRolls() {
        return hpRolls;
    }

    public void setHpRolls(Map<Integer, Integer> hpRolls) {
        this.hpRolls = hpRolls;
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

    public Set<PlayerCharacterClass> getClasses() {
        return classes;
    }

    public void setClasses(Set<PlayerCharacterClass> classes) {
        this.classes = classes;
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

    public int getPassiveSensesBonus() {
        return passiveSensesBonus;
    }

    public void setPassiveSensesBonus(int passiveSensesBonus) {
        this.passiveSensesBonus = passiveSensesBonus;
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
        // Magic Item Adept (nivel 10, 3->4), Savant (nivel 14, ->5) y Master (nivel 18, ->6):
        // features de clase base del Artificiero, fijas por nivel (no SubclassFeature), igual
        // que Magic Item Adept ya se trataba -- ver Aurora_Fixes.md #3.
        // Multiclase (mantenimiento): Artificer como clase secundaria también cuenta, no solo
        // la primaria -- hasClassNameStartingWith() mira classes además de dndClass.
        if (hasClassNameStartingWith("artificer")) {
            if (getLevel() >= 18) return 6;
            if (getLevel() >= 14) return 5;
            if (getLevel() >= 10) return 4;
        }
        return 3;
    }

    // Puntuaciones efectivas transitorias (aplicadas por items equipados/sintonizados)
    // No se persisten; se establecen durante el cálculo del DTO y se limpian al terminar.
    @Transient
    private Map<String, Integer> effectiveAbilityScores;

    public void applyEffectiveAbilityScores(Map<String, Integer> effective) {
        this.effectiveAbilityScores = effective;
    }

    public void clearEffectiveAbilityScores() {
        this.effectiveAbilityScores = null;
    }

    @Transient
    public int calculateAbilityModifier(String abilityScore) {
        Map<String, Integer> scores = effectiveAbilityScores != null ? effectiveAbilityScores : abilityScores;
        if (scores == null || abilityScore == null) return 0;
        // Buscar insensible a mayúsculas/minúsculas para compatibilidad con datos existentes
        Integer score = scores.get(abilityScore);
        if (score == null) score = scores.get(abilityScore.toLowerCase());
        if (score == null) score = scores.get(abilityScore.toUpperCase());
        if (score == null) return 0;
        return (score - 10) / 2;
    }


        /**
     * Calcula la Armor Class (AC) del personaje
     * Considera armadura equipada, modificador DEX, bonificador natural y efectos activos
     */
    @Transient
    public int getArmorClass(CharacterEquipment equipment, List<CharacterActiveEffect> activeEffects) {
        int dexModifier = calculateAbilityModifier("dex");

        Item armor = equipment != null ? equipment.getArmor() : null;
        Item offHand = equipment != null ? equipment.getOffHand() : null;

        boolean hasShield = offHand != null && "Shield".equalsIgnoreCase(offHand.getArmorType());

        int baseAC;

        if (armor != null && armor.getArmorClass() != null) {
            int armorAC = armor.getArmorClass();
            String armorType = armor.getArmorType();

            if ("Light".equalsIgnoreCase(armorType)) {
                baseAC = armorAC + dexModifier;
            } else if ("Medium".equalsIgnoreCase(armorType)) {
                int maxDexBonus = armor.getMaxDexBonus() != null ? armor.getMaxDexBonus() : 2;
                baseAC = armorAC + Math.min(dexModifier, maxDexBonus);
            } else if ("Heavy".equalsIgnoreCase(armorType)) {
                baseAC = armorAC;
            } else {
                baseAC = armorAC + dexModifier;
            }
        } else {
            // Sin armadura: aplicar Unarmored Defense según la clase. Multiclase
            // (mantenimiento): Barbarian/Monk cuentan aunque sean una clase secundaria, no
            // solo la primaria -- ver hasClassIndexName().
            boolean isBarbarian = hasClassIndexName("barbarian");
            // El Monje pierde Unarmored Defense si lleva escudo
            boolean isMonkUnarmored = hasClassIndexName("monk") && !hasShield;

            if (isBarbarian) {
                // Unarmored Defense del Bárbaro: 10 + DEX + CON (escudo permitido)
                int conModifier = calculateAbilityModifier("con");
                baseAC = 10 + dexModifier + conModifier;
            } else if (isMonkUnarmored) {
                // Unarmored Defense del Monje: 10 + DEX + WIS
                int wisModifier = calculateAbilityModifier("wis");
                baseAC = 10 + dexModifier + wisModifier;
            } else {
                baseAC = 10 + dexModifier;
            }

            // Armadura natural (Draconic Sorcerer, etc.): tomar el mayor
            if (naturalArmorBonus != null) {
                baseAC = Math.max(baseAC, naturalArmorBonus + dexModifier);
            }
        }

        // Escudo — el Monje con Unarmored Defense ya está excluido (isMonkUnarmored requiere !hasShield)
        if (hasShield) {
            int shieldBonus = equipment.getOffHand().getArmorClass() != null
                    ? equipment.getOffHand().getArmorClass() : 2;
            baseAC += shieldBonus;
        }

        // Bonificadores de efectos activos (ej: Shield of Faith, Shield spell, etc.)
        if (activeEffects != null) {
            for (CharacterActiveEffect effect : activeEffects) {
                if (effect.isActive() &&
                    effect.getEffect().getModifierTypes() != null &&
                    effect.getEffect().getModifierTypes().contains(enumeration.EffectModifierType.AC)) {
                    baseAC += parseModifier(effect.getEffect().getModifierValue());
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
        String spellcastingAbility = resolveSpellcastingAbility();
        if (spellcastingAbility == null) {
            return 0; // No es lanzador de hechizos
        }
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
        String spellcastingAbility = resolveSpellcastingAbility();
        if (spellcastingAbility == null) {
            return 0; // No es lanzador de hechizos
        }
        int abilityModifier = calculateAbilityModifier(spellcastingAbility);
        return proficiencyBonus + abilityModifier;
    }

    /**
     * Multiclase (Aurora_Fixes.md #17, mantenimiento): dndClass/subclass (arriba) son la
     * clase PRIMARIA -- si esa clase no lanza hechizos pero otra clase del personaje sí
     * (p.ej. Barbarian primaria / Druid secundaria), sin este fallback getSpellSaveDC()/
     * getSpellAttackBonus() devolvían 0 siempre, aunque el personaje sí sea lanzador.
     * Simplificación conocida: si hay dos clases lanzadoras con habilidades distintas
     * (p.ej. Cleric+Wizard), esta app solo modela un DC/bonus combinado, no uno por clase
     * -- se usa la de menor classOrder, mismo criterio que el resto del sistema de
     * hechizos bajo multiclase.
     */
    @Transient
    private String resolveSpellcastingAbility() {
        if (dndClass != null && dndClass.getSpellcastingAbility() != null
                && !dndClass.getSpellcastingAbility().isEmpty()) {
            return dndClass.getSpellcastingAbility();
        }
        if (subclass != null && subclass.getSpellcastingAbility() != null
                && !subclass.getSpellcastingAbility().isEmpty()) {
            return subclass.getSpellcastingAbility();
        }
        PlayerCharacterClass row = resolveSpellcastingClassRow();
        if (row == null) {
            return null;
        }
        if (row.getDndClass() != null && row.getDndClass().getSpellcastingAbility() != null
                && !row.getDndClass().getSpellcastingAbility().isEmpty()) {
            return row.getDndClass().getSpellcastingAbility();
        }
        if (row.getSubclass() != null && row.getSubclass().getSpellcastingAbility() != null
                && !row.getSubclass().getSpellcastingAbility().isEmpty()) {
            return row.getSubclass().getSpellcastingAbility();
        }
        return null;
    }

    /** La fila de `classes` (de menor classOrder) cuya clase o subclase lance hechizos, si hay alguna. */
    @Transient
    private PlayerCharacterClass resolveSpellcastingClassRow() {
        PlayerCharacterClass best = null;
        if (classes != null) {
            for (PlayerCharacterClass pcc : classes) {
                boolean casts = (pcc.getDndClass() != null && pcc.getDndClass().getSpellcastingAbility() != null
                            && !pcc.getDndClass().getSpellcastingAbility().isEmpty())
                        || (pcc.getSubclass() != null && pcc.getSubclass().getSpellcastingAbility() != null
                            && !pcc.getSubclass().getSpellcastingAbility().isEmpty());
                if (casts && (best == null || pcc.getClassOrder() < best.getClassOrder())) {
                    best = pcc;
                }
            }
        }
        return best;
    }

    /**
     * Multiclase (mantenimiento): true si dndClass (primaria) o cualquier clase de
     * `classes` (secundaria) tiene este indexName -- p.ej. "barbarian"/"monk" para
     * Unarmored Defense, que aplica sin importar si esa clase es la primaria o no.
     */
    @Transient
    private boolean hasClassIndexName(String indexName) {
        if (dndClass != null && indexName.equalsIgnoreCase(dndClass.getIndexName())) {
            return true;
        }
        if (classes != null) {
            for (PlayerCharacterClass pcc : classes) {
                if (pcc.getDndClass() != null && indexName.equalsIgnoreCase(pcc.getDndClass().getIndexName())) {
                    return true;
                }
            }
        }
        return false;
    }

    /** Igual que hasClassIndexName() pero comparando el nombre de clase por prefijo (p.ej. "artificer"). */
    @Transient
    private boolean hasClassNameStartingWith(String prefix) {
        if (dndClass != null && dndClass.getName() != null
                && dndClass.getName().toLowerCase().startsWith(prefix)) {
            return true;
        }
        if (classes != null) {
            for (PlayerCharacterClass pcc : classes) {
                DndClass c = pcc.getDndClass();
                if (c != null && c.getName() != null && c.getName().toLowerCase().startsWith(prefix)) {
                    return true;
                }
            }
        }
        return false;
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
     * Base: velocidad de la raza + modificadores + bonificaciones de clase
     */
    @Transient
    public int getCurrentSpeed(List<CharacterActiveEffect> activeEffects){
        if(race == null) {
            return 30; // Velocidad base si no se ha seleccionado raza
        }

        int baseSpeed = race.getSpeed();
        int totalSpeed = baseSpeed + speedModifier;

        // Class speed bonuses
        if (dndClass != null) {
            String className = dndClass.getName();
            if (className != null) {
                String cn = className.toLowerCase();
                // Barbarian Fast Movement: +10 ft at level 5+ (not while wearing heavy armor)
                if (cn.contains("barbarian") && level >= 5) {
                    totalSpeed += 10;
                }
                // Monk Unarmored Movement: scales with level
                if (cn.contains("monk") && level >= 2) {
                    int bonus = 0;
                    if      (level >= 18) bonus = 30;
                    else if (level >= 14) bonus = 25;
                    else if (level >= 10) bonus = 20;
                    else if (level >=  6) bonus = 15;
                    else                  bonus = 10;
                    totalSpeed += bonus;
                }
            }
        }

        // Bonificadores de feats/features genéricos (ver FeatMechanicalEffectService)
        if (activeEffects != null) {
            for (CharacterActiveEffect effect : activeEffects) {
                if (effect.isActive() &&
                    effect.getEffect().getModifierTypes() != null &&
                    effect.getEffect().getModifierTypes().contains(enumeration.EffectModifierType.SPEED)) {
                    totalSpeed += parseModifier(effect.getEffect().getModifierValue());
                }
            }
        }

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
        // Algunas clases no preparan hechizos (Bard, Sorcerer, Warlock, Ranger conocen hechizos)
        //Esto se podría refinar con un campo en DndClass
        if (dndClass != null && dndClass.getSpellcastingAbility() != null
                && !dndClass.getSpellcastingAbility().isEmpty()) {
            int abilityModifier = calculateAbilityModifier(dndClass.getSpellcastingAbility());
            return Math.max(1, abilityModifier + level);
        }

        // Multiclase (Aurora_Fixes.md #17, mantenimiento): la clase primaria (dndClass) no
        // siempre es la que prepara -- si otra clase del personaje sí (p.ej. Barbarian
        // primaria / Druid secundaria), antes esto devolvía 0 siempre, así que el límite de
        // hechizos preparados no se aplicaba nunca para esa clase secundaria. Usa el propio
        // nivel EN esa clase (no el nivel total de personaje), como pide la fórmula del PHB.
        PlayerCharacterClass row = resolveSpellcastingClassRow();
        if (row == null || row.getDndClass() == null || row.getDndClass().getSpellcastingAbility() == null
                || row.getDndClass().getSpellcastingAbility().isEmpty()) {
            return 0; // No es lanzador de hechizos
        }
        int abilityModifier = calculateAbilityModifier(row.getDndClass().getSpellcastingAbility());
        return Math.max(1, abilityModifier + row.getLevel());
    }

    /**
     * Multiclase (Aurora_Fixes.md #17, fase 4a): máximo de hechizos preparados POR CADA clase
     * preparadora del personaje (classId -> máximo), no solo la de menor classOrder --
     * necesario para aplicar el límite de cada clase por separado cuando hay dos (p.ej.
     * Cleric+Druid). getMaxPreparedSpells() (sin argumentos, arriba) se mantiene tal cual
     * para el código que todavía no es consciente de multiclase.
     */
    @Transient
    public java.util.Map<Long, Integer> getMaxPreparedSpellsByClass() {
        java.util.Map<Long, Integer> result = new java.util.HashMap<>();
        if (classes != null) {
            for (PlayerCharacterClass pcc : classes) {
                DndClass c = pcc.getDndClass();
                if (c != null && c.getSpellcastingAbility() != null && !c.getSpellcastingAbility().isEmpty()) {
                    int abilityModifier = calculateAbilityModifier(c.getSpellcastingAbility());
                    result.put(c.getId(), Math.max(1, abilityModifier + pcc.getLevel()));
                }
            }
        }
        return result;
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
        int bonus = 10 + wisModifier + passiveSensesBonus;

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
        int bonus = 10 + intModifier + passiveSensesBonus;

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

    public String getAbilityDisplayMode() {
        return abilityDisplayMode != null ? abilityDisplayMode : "SCORES_TOP";
    }

    public void setAbilityDisplayMode(String abilityDisplayMode) {
        this.abilityDisplayMode = abilityDisplayMode;
    }

    public List<String> getSelectedSources() { return selectedSources; }
    public void setSelectedSources(List<String> selectedSources) { this.selectedSources = selectedSources; }

}
    




    

