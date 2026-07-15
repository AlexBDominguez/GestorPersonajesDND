package entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Catalog of artificer infusions (Infuse Item, #8/#8.1 — biggest remaining gap, "sistema
 * entero inexistente" per Aurora_Fixes.md). One row per infusion, shared across every
 * character — same role as ClassResource/NumericBonus for the other #8.2 mechanic types, but
 * scoped to a specific inventory item rather than to the whole character
 * (see CharacterInventory.infusionIndexName).
 */
@Entity
@Table(name = "infusions")
public class Infusion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, name = "index_name")
    private String indexName;

    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    // Nivel mínimo de Artificiero para poder aprenderla (0 = disponible desde el nivel 2, el
    // propio Infuse Item). Radiant Weapon/Repulsion Shield/Resistant Armor/Spell-Refueling
    // Ring/Boots of the Winding Path = 6; Helm of Awareness = 10; Arcane Propulsion Armor = 14.
    @Column(name = "min_level")
    private int minLevel;

    @Column(name = "requires_attunement")
    private boolean requiresAttunement;

    // A qué se suma el bono cuando el objeto infusionado está activo (equipado, y si
    // requiresAttunement también sintonizado) -- null si la infusión no tiene un efecto
    // numérico modelado (p.ej. Resistant Armor, Helm of Awareness: solo descriptivas).
    // Valores: "AC" (Enhanced Defense/Repulsion Shield), "WEAPON_ATTACK_DAMAGE" (Enhanced
    // Weapon/Repeating Shot/Returning Weapon/Radiant Weapon), "SPELL_ATTACK" (Enhanced Arcane
    // Focus). Ver PlayerCharacterService, mismo punto donde ya se suman itemBonusAc/itemBonusToHit.
    @Column(name = "bonus_target")
    private String bonusTarget;

    // Fórmula DSL (CharacterFormulaService) para el valor del bono -- "1" fijo para la mayoría,
    // "infusion_enhancement_bonus_table" para las 3 que escalan a +2 en nivel 10 (Enhanced
    // Weapon/Defense/Arcane Focus).
    @Column(name = "bonus_formula")
    private String bonusFormula;

    public Infusion() {
    }

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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getMinLevel() {
        return minLevel;
    }

    public void setMinLevel(int minLevel) {
        this.minLevel = minLevel;
    }

    public boolean isRequiresAttunement() {
        return requiresAttunement;
    }

    public void setRequiresAttunement(boolean requiresAttunement) {
        this.requiresAttunement = requiresAttunement;
    }

    public String getBonusTarget() {
        return bonusTarget;
    }

    public void setBonusTarget(String bonusTarget) {
        this.bonusTarget = bonusTarget;
    }

    public String getBonusFormula() {
        return bonusFormula;
    }

    public void setBonusFormula(String bonusFormula) {
        this.bonusFormula = bonusFormula;
    }
}
