-- #8.2 NUMERIC_BONUS: Elemental Affinity (Sorcerer, Draconic Bloodline, level 6+). Adds the
-- Charisma modifier to one damage roll of a spell whose damage type matches the character's
-- Draconic Ancestry (e.g. a Red dragon ancestor -> fire spells). Closes a real #8.1 gap
-- (Draconic Bloodline previously did nothing for this feature). No floor -- unlike most
-- RESOURCE_POOL formulas, a flat damage bonus should not be forced up to +1 for a low-Charisma
-- character, hence "charisma_modifier_raw" and not "charisma_modifier".
--
-- This is the first NumericBonus whose condition isn't "the character has the feature" alone --
-- it also depends on a resolved DRACONIC_ANCESTRY choice (see
-- NumericBonusService.resolveChosenDamageType()). bonus_condition encodes which choice to look
-- up: "MATCH_DAMAGE_TYPE_FROM_CHOICE:DRACONIC_ANCESTRY".
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, bonus_condition)
SELECT 'Elemental Affinity', 'elemental-affinity', 'SPELL_DAMAGE_MATCHING_CHOSEN_TYPE',
       'charisma_modifier_raw', 'MATCH_DAMAGE_TYPE_FROM_CHOICE:DRACONIC_ANCESTRY'
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'elemental-affinity');

-- indexName esperado según la convención kebab-case habitual de dnd5eapi.co (Draconic Bloodline
-- es una subclase PHB) -- no verificado contra una auditoría en vivo; si esta UPDATE afecta a 0
-- filas, comprobar el indexName real con
-- `SELECT index_name, name FROM subclass_features WHERE name LIKE 'Elemental Affinity%';` en el VPS.
UPDATE subclass_features
SET grants_bonus_key = 'elemental-affinity'
WHERE index_name = 'elemental-affinity';
