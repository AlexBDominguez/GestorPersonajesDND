-- #8.2 NUMERIC_BONUS: Fighting Style (Defense +1 AC while armored; Archery +2 ranged attack).
-- Migrates the last hardcoded backend NUMERIC_BONUS case (PlayerCharacterService used to check
-- "Defense".equalsIgnoreCase(fightingStyle)/"Archery".equalsIgnoreCase(fightingStyle) inline).
-- Behavior preserved exactly -- same +1/+2, same armor requirement for Defense.
--
-- Same structural problem as Agonizing Blast: Fighting Style is a single feature ("Fighting
-- Style") the player picks ONE option for (Defense/Archery/Dueling/...), not a row per style, so
-- there's no ClassFeature/SubclassFeature to hang a grantsBonusKey off. Resolved with the same
-- "look up by targetField, match condition directly" pattern as
-- NumericBonusService.fightingStyleBonusFor() -- no UPDATE ... grants_bonus_key needed.
--
-- bonus_condition format: "HAS_SINGLE_CHOICE:<taskType>:<value>", with an optional
-- ";REQUIRES_ARMOR" suffix for Defense (only applies while wearing armor).
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, bonus_condition)
SELECT 'Fighting Style: Defense', 'fighting-style-defense', 'AC', '1',
       'HAS_SINGLE_CHOICE:FIGHTING_STYLE:Defense;REQUIRES_ARMOR'
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'fighting-style-defense');

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, bonus_condition)
SELECT 'Fighting Style: Archery', 'fighting-style-archery', 'RANGED_ATTACK', '2',
       'HAS_SINGLE_CHOICE:FIGHTING_STYLE:Archery'
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'fighting-style-archery');
