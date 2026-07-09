-- #8.2 NUMERIC_BONUS: Agonizing Blast (Warlock, Eldritch Invocation). Adds the Charisma
-- modifier to Eldritch Blast's damage. Closes a real #8.1 gap -- arguably the most commonly
-- taken Warlock invocation, and previously did nothing at all (not even the base cantrip
-- damage had any ability modifier applied to it, see Aurora_Fixes.md #8.2).
--
-- Structurally different from every other NumericBonus so far: Eldritch Invocations aren't
-- synced ClassFeature/SubclassFeature rows (they're a fixed option list the player picks from,
-- frontend/lib/config/dnd_choice_options.dart's kEldritchInvocations), so there's no feature row
-- to hang a grantsBonusKey off. This row is looked up directly by bonus_key in
-- NumericBonusService.spellDamageBonusForNamedSpell() instead of via the usual
-- ClassFeature/SubclassFeature scan -- no UPDATE ... grants_bonus_key needed for this one.
--
-- bonus_condition "HAS_MULTI_CHOICE:INVOCATION:Agonizing Blast" checks whether "Agonizing Blast"
-- appears among the character's resolved INVOCATION task choices (comma-separated, same storage
-- convention as Battle Master Maneuvers -- see PendingTaskService.resolveTask()).
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, bonus_condition)
SELECT 'Agonizing Blast', 'agonizing-blast', 'SPELL_DAMAGE_IF_MULTI_CHOICE_CONTAINS',
       'charisma_modifier_raw', 'HAS_MULTI_CHOICE:INVOCATION:Agonizing Blast'
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'agonizing-blast');
