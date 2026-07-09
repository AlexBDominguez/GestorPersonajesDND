-- #8.2 NUMERIC_BONUS: Empowered Evocation (Wizard, School of Evocation, level 10+). Adds the
-- Intelligence modifier to one damage roll of any Evocation-school spell the character casts.
-- Closes a real #8.1 gap. PHB text: "you can add your Intelligence modifier to one damage roll
-- of any wizard evocation spell you cast" -- no separate per-turn/per-rest limit in the rule
-- itself (unlike a resource-pool feature), so this is a plain always-available bonus gated only
-- by "does the character have this feature", same shape as Elemental Affinity but matching by
-- spell school instead of by a player-chosen damage type -- no PendingTask resolution needed,
-- bonus_condition is just the literal school name.
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, bonus_condition)
SELECT 'Empowered Evocation', 'empowered-evocation', 'SPELL_DAMAGE_MATCHING_SCHOOL',
       'intelligence_modifier_raw', 'evocation'
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'empowered-evocation');

-- indexName esperado según la convención kebab-case habitual de dnd5eapi.co -- no verificado
-- contra una auditoría en vivo; si esta UPDATE afecta a 0 filas, comprobar el indexName real con
-- `SELECT index_name, name FROM subclass_features WHERE name LIKE 'Empowered Evocation%';` en el VPS.
UPDATE subclass_features
SET grants_bonus_key = 'empowered-evocation'
WHERE index_name = 'empowered-evocation';
