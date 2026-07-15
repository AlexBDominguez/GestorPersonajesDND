-- #8: Artificer Infusions (Infuse Item) -- "el gap más grande de todo el inventario, sistema
-- entero inexistente" per Aurora_Fixes.md. Two halves:
--   1) infusions catalog (this script's INSERTs into `infusions`).
--   2) class_level_feature rows so the backend creates an INFUSION_CHOICE PendingTask at
--      Artificer levels 2 (pick 4), 6/10/14/18 (pick 2 each) -- same FeatureType-driven
--      mechanism Eldritch Invocations already uses, applies to BOTH Artificer variants
--      (ERLW/TCE, class_id 13/14) via LOWER(index_name) LIKE '%artificer%', matching
--      patch_artificer_progression.sql's existing pattern. class_level_progression rows for
--      every level 1-20 were already seeded by that script, so this only adds the new feature
--      rows, not new progression rows.
--
-- Effect shapes (see entities/Infusion.java, PlayerCharacterService inventory loop):
--   bonus_target='AC'                    -> summed into AC while the infused item is active.
--   bonus_target='WEAPON_ATTACK_DAMAGE'  -> summed into attack AND damage rolls for that weapon.
--   bonus_target='SPELL_ATTACK'          -> summed into spell attack bonus.
--   bonus_target=NULL                    -> descriptive only (not a number this app tracks) --
--     Armor of Magical Strength/Mind Sharpener/Spell-Refueling Ring/Boots of the Winding
--     Path/Resistant Armor/Helm of Awareness/Arcane Propulsion Armor's charge-based reactions,
--     Homunculus Servant (companion), Replicate Magic Item (its own item-selection sub-list) --
--     all deliberately out of scope this pass, same "descriptive only" treatment as e.g. Great
--     Weapon Fighting/Protection already get. bonus_formula is only meaningful when bonus_target
--     is set.
--
-- Descriptions are paraphrased summaries, not reproduced verbatim from the book (same
-- convention as every other manually-authored infusion/rune/maneuver content in this project).
-- Idempotente: INSERT ... WHERE NOT EXISTS.
SET NAMES utf8mb4;

-- ── 1. Infusion catalog ─────────────────────────────────────────────────────
INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'enhanced-arcane-focus', 'Enhanced Arcane Focus',
       'While attuned and holding this rod, staff, or wand, gain a bonus to spell attack rolls (+1, or +2 from 10th level) and ignore half cover when targeting with a spell.',
       0, 1, 'SPELL_ATTACK', 'infusion_enhancement_bonus_table'
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'enhanced-arcane-focus');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'enhanced-defense', 'Enhanced Defense',
       'Bonus to AC while wearing this armor or wielding this shield (+1, or +2 from 10th level).',
       0, 0, 'AC', 'infusion_enhancement_bonus_table'
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'enhanced-defense');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'enhanced-weapon', 'Enhanced Weapon',
       'Bonus to attack and damage rolls with this simple or martial weapon (+1, or +2 from 10th level).',
       0, 0, 'WEAPON_ATTACK_DAMAGE', 'infusion_enhancement_bonus_table'
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'enhanced-weapon');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'repeating-shot', 'Repeating Shot',
       'While attuned, this ranged weapon ignores the loading property and generates its own ammunition. +1 to attack and damage rolls made with it.',
       0, 1, 'WEAPON_ATTACK_DAMAGE', '1'
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'repeating-shot');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'returning-weapon', 'Returning Weapon',
       'This thrown weapon flies back to your hand immediately after a ranged attack. +1 to attack and damage rolls made with it.',
       0, 0, 'WEAPON_ATTACK_DAMAGE', '1'
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'returning-weapon');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'armor-of-magical-strength', 'Armor of Magical Strength',
       'While wearing this armor, 6 charges (regain 1d6 daily) to add your Intelligence modifier to a Strength check or saving throw, or to avoid being knocked prone. Not tracked as a charge pool in this app yet.',
       0, 1, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'armor-of-magical-strength');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'mind-sharpener', 'Mind Sharpener',
       'While wearing this armor or robes, 4 charges (regain 1d4 daily) to automatically succeed a failed Constitution saving throw to maintain concentration. Not tracked as a charge pool in this app yet.',
       0, 0, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'mind-sharpener');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'homunculus-servant', 'Homunculus Servant',
       'Turns a gem or crystal worth at least 100 gp into a Tiny construct companion loyal to you. Not tracked as a companion creature in this app.',
       0, 0, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'homunculus-servant');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'replicate-magic-item', 'Replicate Magic Item',
       'Learn the formula for a specific existing magic item instead of a fixed effect (which items are available depends on your level; can be learned more than once). Not tracked mechanically here — if the target item already exists in this app''s catalog, add it to inventory directly instead.',
       0, 0, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'replicate-magic-item');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'radiant-weapon', 'Radiant Weapon',
       '+1 to attack and damage rolls with this simple or martial weapon. It sheds bright light in a 30-foot radius and dim light for an additional 30 feet. 4 charges (regain 1d4 daily) to blind an attacker you hit or force a Constitution save — charges not tracked in this app yet.',
       6, 1, 'WEAPON_ATTACK_DAMAGE', '1'
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'radiant-weapon');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'repulsion-shield', 'Repulsion Shield',
       '+1 to AC while wielding this shield. Reaction: spend 1 of 4 charges (regain 1d4 daily) to push an attacker within 5 feet back 15 feet — charges not tracked in this app yet.',
       6, 1, 'AC', '1'
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'repulsion-shield');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'resistant-armor', 'Resistant Armor',
       'Choose a damage type (acid, cold, fire, force, lightning, necrotic, poison, psychic, radiant, or thunder) when this infusion is applied. Resistance to that damage type while wearing this armor. Not enforced automatically in this app yet.',
       6, 1, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'resistant-armor');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'boots-of-the-winding-path', 'Boots of the Winding Path',
       'While wearing these boots, teleport as a bonus action to an unoccupied space you can see that you occupied at some point during your current turn.',
       6, 1, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'boots-of-the-winding-path');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'spell-refueling-ring', 'Spell-Refueling Ring',
       'This ring has 1 charge (regains at dawn). Spend it as an action to regain one expended spell slot of 3rd level or lower. Not tracked as a charge pool in this app yet.',
       6, 1, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'spell-refueling-ring');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'helm-of-awareness', 'Helm of Awareness',
       'While wearing this helmet, you have advantage on initiative rolls, and you can''t be surprised while conscious.',
       10, 1, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'helm-of-awareness');

INSERT INTO infusions (index_name, name, description, min_level, requires_attunement, bonus_target, bonus_formula)
SELECT 'arcane-propulsion-armor', 'Arcane Propulsion Armor',
       'Grants a +5 ft walking speed and integrated force-powered gauntlets (1d8 force damage on a melee hit; can be thrown 20/60 ft and return to your hand). Can''t be removed against your will and can replace a missing arm or leg.',
       14, 1, NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM infusions WHERE index_name = 'arcane-propulsion-armor');

-- ── 2. INFUSION_CHOICE class_level_feature rows (both Artificer variants) ──────────────────
DROP TEMPORARY TABLE IF EXISTS tmp_infusion_artificer_ids;
CREATE TEMPORARY TABLE tmp_infusion_artificer_ids AS
  SELECT id FROM classes WHERE LOWER(index_name) LIKE '%artificer%';

-- Nivel 2: 4 infusiones conocidas iniciales
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'INFUSION_CHOICE', 1, '{"count":4}'
FROM class_level_progression p
JOIN tmp_infusion_artificer_ids a ON p.dnd_class_id = a.id
WHERE p.level = 2
  AND NOT EXISTS (
    SELECT 1 FROM class_level_feature f
    WHERE f.progression_id = p.id AND f.type = 'INFUSION_CHOICE'
  );

-- Niveles 6, 10, 14, 18: +2 infusiones conocidas cada uno
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'INFUSION_CHOICE', 1, '{"count":2}'
FROM class_level_progression p
JOIN tmp_infusion_artificer_ids a ON p.dnd_class_id = a.id
WHERE p.level IN (6, 10, 14, 18)
  AND NOT EXISTS (
    SELECT 1 FROM class_level_feature f
    WHERE f.progression_id = p.id AND f.type = 'INFUSION_CHOICE'
  );

DROP TEMPORARY TABLE IF EXISTS tmp_infusion_artificer_ids;
