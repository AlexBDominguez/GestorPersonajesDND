-- #8.2 NUMERIC_BONUS: Remarkable Athlete (Fighter Champion, level 7+). Half proficiency bonus
-- (rounded up) added to Strength/Dexterity/Constitution checks the character isn't already
-- proficient in. Closes a real #8.1 gap (Champion) -- this feature previously did nothing.
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, bonus_condition)
SELECT 'Remarkable Athlete', 'remarkable-athlete', 'ABILITY_CHECK_PHYSICAL_UNPROFICIENT',
       'half_proficiency_bonus_round_up', NULL
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'remarkable-athlete');

-- indexName esperado según la convención kebab-case habitual de dnd5eapi.co -- no verificado
-- contra una auditoría en vivo; si esta UPDATE afecta a 0 filas, comprobar el indexName real con
-- `SELECT index_name, name FROM subclass_features WHERE name LIKE 'Remarkable Athlete%';` en el
-- VPS y ajustar.
UPDATE subclass_features
SET grants_bonus_key = 'remarkable-athlete'
WHERE index_name = 'remarkable-athlete';
