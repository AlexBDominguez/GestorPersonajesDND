-- #8.2 NUMERIC_BONUS: Fighting Style (Defense +1 AC while armored; Archery +2 ranged attack;
-- Dueling +2 melee damage with a single one-handed melee weapon and no other weapon equipped).
-- Migrates the last hardcoded backend NUMERIC_BONUS case (PlayerCharacterService used to check
-- "Defense".equalsIgnoreCase(fightingStyle)/"Archery".equalsIgnoreCase(fightingStyle) inline).
-- Behavior preserved exactly -- same +1/+2/+2, same armor/weapon requirements.
--
-- Same structural problem as Agonizing Blast: Fighting Style is a single feature ("Fighting
-- Style") the player picks ONE option for (Defense/Archery/Dueling/...), not a row per style, so
-- there's no ClassFeature/SubclassFeature to hang a grantsBonusKey off. Resolved with the same
-- "look up by targetField, match condition directly" pattern as
-- NumericBonusService.fightingStyleBonusFor() -- no UPDATE ... grants_bonus_key needed.
--
-- bonus_condition format: "HAS_SINGLE_CHOICE:<taskType>:<value>", with an optional
-- ";REQUIRES_ARMOR" suffix for Defense (only applies while wearing armor), or
-- ";REQUIRES_SINGLE_ONE_HANDED_MELEE_WEAPON" for Dueling (only applies while wielding exactly one
-- melee, non-two-handed weapon and no other weapon). Dueling was previously a hardcoded boolean
-- in tab_combat.dart (_duelingApplies); migrated here so a future admin-panel-added feature with
-- the same shape (+X melee damage under an equipment condition) works without touching Dart.
-- Two-Weapon Fighting (add ability mod to off-hand damage) is NOT migrated -- it's a rule
-- toggle, not an additive bonus, so it doesn't fit this shape regardless of who authors it; it
-- stays as a direct read of character.fightingStyle in the frontend.
--
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

INSERT INTO numeric_bonuses (name, bonus_key, target_field, formula, bonus_condition)
SELECT 'Fighting Style: Dueling', 'fighting-style-dueling', 'MELEE_DAMAGE', '2',
       'HAS_SINGLE_CHOICE:FIGHTING_STYLE:Dueling;REQUIRES_SINGLE_ONE_HANDED_MELEE_WEAPON'
WHERE NOT EXISTS (SELECT 1 FROM numeric_bonuses WHERE bonus_key = 'fighting-style-dueling');
