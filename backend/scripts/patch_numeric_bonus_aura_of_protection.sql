-- #8.2 NUMERIC_BONUS, first migrated case: Paladin's Aura of Protection (level 6+,
-- +Charisma modifier -- floor of +0, matching the exact behavior the old hardcoded
-- PlayerCharacterService check had -- to all saving throws within range). Replaces the
-- `hasPaladinAura`/`paladinAuraBonus` if-check that used to live inline in
-- PlayerCharacterService.getById()/toDto().
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, condition)
SELECT 'Aura of Protection', 'aura-of-protection', 'SAVING_THROW_ALL', 'charisma_modifier_min0', NULL
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'aura-of-protection');

-- indexName esperado según la convención kebab-case habitual de dnd5eapi.co (mismo patrón que
-- 'channel-divinity', 'extra-attack', etc.) -- no verificado contra una auditoría en vivo como sí
-- se hizo para el contenido de Aurora; si esta UPDATE afecta a 0 filas, comprobar el indexName
-- real con `SELECT index_name, name FROM class_features WHERE name LIKE 'Aura of Protection%';`
-- en el VPS y ajustar.
UPDATE class_features
SET grants_bonus_key = 'aura-of-protection'
WHERE index_name = 'aura-of-protection';
