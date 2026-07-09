-- #8.2 NUMERIC_BONUS: Draconic Resilience (Sorcerer, Draconic Bloodline, level 1) -- the +1 max
-- HP per level half of this feature. Closes a real #8.1 gap: this half was never implemented at
-- all (unlike the AC half -- "AC = 13 + DEX while unarmored" -- which already worked via
-- PlayerCharacter.naturalArmorBonus, set by a hardcoded subclass-name switch in
-- applySubclassStatEffects(); that switch is NOT touched by this script, the AC math is a
-- "take the higher of two formulas" pattern that doesn't fit an additive NUMERIC_BONUS anyway).
--
-- New targetField "MAX_HP_PER_LEVEL", gated the normal way via grantsBonusKey (Draconic
-- Resilience is a real SubclassFeature row, no choice involved, same shape as Elemental
-- Affinity/Empowered Evocation). Applied in two places since max HP is persisted, not
-- recomputed live like AC/damage: retroactively for already-attained levels right after subclass
-- assignment (PlayerCharacterService.create() and PendingTaskService's CHOOSE_SUBCLASS handler),
-- and incrementally on every subsequent level-up (PlayerCharacterService.addHitPoints()).
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, bonus_condition)
SELECT 'Draconic Resilience', 'draconic-resilience', 'MAX_HP_PER_LEVEL', '1', NULL
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'draconic-resilience');

-- indexName esperado según la convención kebab-case habitual de dnd5eapi.co -- no verificado
-- contra una auditoría en vivo; si esta UPDATE afecta a 0 filas, comprobar el indexName real con
-- `SELECT index_name, name FROM subclass_features WHERE name LIKE 'Draconic Resilience%';` en el VPS.
UPDATE subclass_features
SET grants_bonus_key = 'draconic-resilience'
WHERE index_name = 'draconic-resilience';
