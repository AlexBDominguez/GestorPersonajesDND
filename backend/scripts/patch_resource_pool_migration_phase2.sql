-- Resource-pool mechanics layer, phase 2 (#8.2): migrate the resources that today only exist
-- as a frontend-only, session-scoped tracker (_kConsumableFeatures in
-- character_sheet_viewmodel.dart) into real class_resources rows, so they persist server-side
-- and survive app reload/rest like Blood Maledict/Grit already do.
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar. No toca ninguna fila existente.
-- No frontend change lands with this script — it is pure backend/data groundwork, verified via
-- the existing /api/characters/{id}/resources* endpoints, not through the app UI.
SET NAMES utf8mb4;

SET @barbarian_id = (SELECT id FROM classes WHERE index_name = 'barbarian');
SET @bard_id      = (SELECT id FROM classes WHERE index_name = 'bard');
SET @cleric_id    = (SELECT id FROM classes WHERE index_name = 'cleric');
SET @fighter_id   = (SELECT id FROM classes WHERE index_name = 'fighter');
SET @monk_id      = (SELECT id FROM classes WHERE index_name = 'monk');
SET @paladin_id   = (SELECT id FROM classes WHERE index_name = 'paladin');
SET @sorcerer_id  = (SELECT id FROM classes WHERE index_name = 'sorcerer');
SET @wizard_id    = (SELECT id FROM classes WHERE index_name = 'wizard');

-- Rage (Barbarian): scales per the class table, recovers on Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @barbarian_id, 'Rage', 'rage',
       'Number of times you can Rage, per the Barbarian rage-uses table. Recovered on Long Rest.',
       'barbarian_rage_table', 'LONG_REST', 1, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'rage');

-- Ki (Monk): equal to Monk level, recovers on short or long rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @monk_id, 'Ki', 'ki',
       'Ki points equal to your Monk level. Recovered on Short or Long Rest.',
       'level', 'SHORT_OR_LONG_REST', 2, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'ki');

-- Bardic Inspiration (Bard): one row replacing the 4 tiered public-API features
-- (bardic-inspiration-d6/d8/d10/d12) — die size stays a frontend display concern (only the
-- count, which doesn't change across tiers, is tracked here). Recovers on Long Rest per PHB.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Bardic Inspiration', 'bardic-inspiration',
       'Uses equal to your Charisma modifier (minimum 1). Die size scales with level (d6/d8/d10/d12), tracked client-side. Recovered on Long Rest.',
       'charisma_modifier', 'LONG_REST', 1, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'bardic-inspiration');

-- Channel Divinity (Paladin): 1 use, unlocked at level 3, recovers on short or long rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @paladin_id, 'Channel Divinity', 'channel-divinity',
       '1 use of Channel Divinity. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 3, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'channel-divinity');

-- Channel Divinity (Cleric): replaces the 3 tiered public-API features
-- (channel-divinity-1-rest/-2-rest/-3-rest) with one scaling resource. Recovers on short or long rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @cleric_id, 'Channel Divinity', 'channel-divinity-cleric',
       'Uses per the Cleric Channel Divinity table (1 at level 2, 2 at level 6, 3 at level 18). Recovered on Short or Long Rest.',
       'channel_divinity_cleric_table', 'SHORT_OR_LONG_REST', 2, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'channel-divinity-cleric');

-- Font of Magic / Sorcery Points (Sorcerer): equal to Sorcerer level, recovers on Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @sorcerer_id, 'Sorcery Points', 'font-of-magic',
       'Sorcery points equal to your Sorcerer level. Recovered on Long Rest.',
       'level', 'LONG_REST', 2, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'font-of-magic');

-- Superiority Dice (Battle Master Fighter): 4/5/6 dice by level 3/7/15, short or long rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Superiority Dice', 'battlemaster-combat-superiority',
       'Superiority dice per the Battle Master table (4 at level 3, 5 at level 7, 6 at level 15). Recovered on Short or Long Rest.',
       'battlemaster_superiority_dice_table', 'SHORT_OR_LONG_REST', 3, 'battle-master'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'battlemaster-combat-superiority');

-- Action Surge (Fighter): 1 use at level 2, 2 uses at level 17, short or long rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Action Surge', 'action-surge',
       'Uses per the Fighter Action Surge table (1 at level 2, 2 at level 17). Recovered on Short or Long Rest.',
       'action_surge_table', 'SHORT_OR_LONG_REST', 2, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'action-surge');

-- Indomitable (Fighter): 1 use at level 9, 2 at level 13, 3 at level 17. Long Rest only.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Indomitable', 'indomitable',
       'Uses per the Fighter Indomitable table (1 at level 9, 2 at level 13, 3 at level 17). Recovered on Long Rest.',
       'indomitable_table', 'LONG_REST', 9, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'indomitable');

-- Second Wind (Fighter): 1 use, short or long rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Second Wind', 'second-wind',
       '1 use of Second Wind. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 1, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'second-wind');

-- Lay on Hands (Paladin): pool of Paladin level x 5 hit points, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @paladin_id, 'Lay on Hands', 'lay-on-hands',
       'Healing pool equal to 5 x your Paladin level. Recovered on Long Rest.',
       'level_times_5', 'LONG_REST', 1, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'lay-on-hands');

-- Divine Sense (Paladin): 1 + Charisma modifier uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @paladin_id, 'Divine Sense', 'divine-sense',
       'Uses equal to 1 + your Charisma modifier. Recovered on Long Rest.',
       'one_plus_charisma_modifier', 'LONG_REST', 1, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'divine-sense');

-- Arcane Recovery (Wizard): 1 use per day, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'Arcane Recovery', 'arcane-recovery',
       '1 use of Arcane Recovery. Recovered on Long Rest.',
       '1', 'LONG_REST', 1, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'arcane-recovery');
