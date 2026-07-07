package entities;

import jakarta.persistence.*;

/**
 * #8.2 NUMERIC_BONUS: a numeric bonus a feature can grant, described declaratively instead of
 * as inline if/else in PlayerCharacterService (mirrors ClassResource for RESOURCE_POOL).
 * A ClassFeature/SubclassFeature links to one of these via its grantsBonusKey field, the same
 * way it links to a ClassResource via consumesResourceIndexName.
 *
 * targetField is a plain string, not an enum, so new targets don't need a migration — the only
 * value currently read by application code is "SAVING_THROW_ALL" (see NumericBonusService).
 * Adding a target (e.g. "AC", "RANGED_ATTACK") means teaching the relevant aggregation point
 * (PlayerCharacter.getArmorClass(), PlayerCharacterService's ranged attack calc...) to ask
 * NumericBonusService for it — see Aurora_Fixes.md #8.2 for what's wired today vs. what a new
 * target field still needs.
 */
@Entity
@Table(name = "numeric_bonuses")
public class NumericBonus {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(name = "bonus_key", unique = true)
    private String bonusKey;

    @Column(name = "target_field")
    private String targetField;

    // Misma DSL que ClassResource.maxFormula, evaluada por CharacterFormulaService.
    private String formula;

    // Condición adicional bajo la que aplica el bonus (p.ej. "WHILE_ARMORED"), o null si es
    // incondicional mientras el personaje tenga la feature que lo otorga. Sin uso todavía
    // (ningún bonus migrado hasta ahora lo necesita) -- reservado para cuando se migre algo
    // como Fighting Style: Defense ("+1 AC mientras lleves armadura").
    // Columna "bonus_condition", no "condition": CONDITION es palabra reservada en MySQL
    // (usada en el manejo de condiciones de procedimientos/triggers) y rompe el SQL sin backticks.
    @Column(name = "bonus_condition")
    private String condition;

    public NumericBonus() {}

    public Long getId() { return id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getBonusKey() { return bonusKey; }
    public void setBonusKey(String bonusKey) { this.bonusKey = bonusKey; }

    public String getTargetField() { return targetField; }
    public void setTargetField(String targetField) { this.targetField = targetField; }

    public String getFormula() { return formula; }
    public void setFormula(String formula) { this.formula = formula; }

    public String getCondition() { return condition; }
    public void setCondition(String condition) { this.condition = condition; }
}
