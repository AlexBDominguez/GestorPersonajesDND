-- #8.2 RESOURCE_POOL: Rune Knight (Fighter, TCE) -- the runa content the Aurora sync never
-- brought (Rune Carver only synced as one summary feature, the 6 individual runes were never
-- captured as structured data). Content below paraphrased from published mechanical summaries
-- of Tasha's Cauldron of Everything's Rune Knight (verified against multiple independent
-- sources, not reproduced verbatim from the book), not from Aurora.
--
-- Each rune is its OWN independent ClassResource -- unlike every other multi-choice case so far
-- (Eldritch Invocations/Fighting Style), a Rune Knight needs a separate counter per rune known,
-- not one shared pool or an invisible passive bonus. Gated via the new
-- requires_multi_choice column (mirrors NumericBonus.bonus_condition's "HAS_MULTI_CHOICE:
-- <taskType>:<value>" format, resolved by the same PendingChoiceService) against a new
-- RUNE_CHOICE wizard task -- so only the runes the player actually picked get initialized,
-- not all 6 for every Rune Knight.
--
-- All six use the same recovery/formula shape: 1 use (2 from level 15, Master of Runes),
-- short or long rest.
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

SET @fighter_id = (SELECT id FROM classes WHERE index_name = 'fighter');
-- index_name esperado según la convención de subclases Aurora ya confirmada en esta sesión
-- (ver #8.2 fase 5) -- no necesita re-verificación, ya se usó con éxito para Giant's Might/
-- Runic Shield en el mismo Rune Knight.
SET @rune_knight = 'ID_WOTC_TCOE_ARCHETYPE_FIGHTER_RUNE_KNIGHT';

INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction, requires_multi_choice)
SELECT @fighter_id, 'Cloud Rune', 'cloud-rune',
       'Passive: advantage on Dexterity (Sleight of Hand) and Charisma (Deception) checks. Invoke as a reaction to redirect an attack made within 30 feet of you to another creature.',
       'rune_knight_charges_table', 'SHORT_OR_LONG_REST', 3, @rune_knight, 'HAS_MULTI_CHOICE:RUNE_CHOICE:Cloud Rune'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'cloud-rune');

INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction, requires_multi_choice)
SELECT @fighter_id, 'Fire Rune', 'fire-rune',
       'Passive: double proficiency bonus on tool checks. Invoke on a weapon hit to deal an extra 2d6 fire damage and restrain the target (Strength save) for 1 minute, taking 2d6 fire damage each turn it fails to escape.',
       'rune_knight_charges_table', 'SHORT_OR_LONG_REST', 3, @rune_knight, 'HAS_MULTI_CHOICE:RUNE_CHOICE:Fire Rune'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'fire-rune');

INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction, requires_multi_choice)
SELECT @fighter_id, 'Frost Rune', 'frost-rune',
       'Passive: advantage on Wisdom (Animal Handling) and Charisma (Intimidation) checks. Invoke as a bonus action for a +2 bonus to Strength/Constitution ability checks and saving throws for 10 minutes.',
       'rune_knight_charges_table', 'SHORT_OR_LONG_REST', 3, @rune_knight, 'HAS_MULTI_CHOICE:RUNE_CHOICE:Frost Rune'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'frost-rune');

INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction, requires_multi_choice)
SELECT @fighter_id, 'Hill Rune', 'hill-rune',
       'Passive: advantage on saving throws against poison, resistance to poison damage. Invoke for resistance to bludgeoning, piercing, and slashing damage for 1 minute.',
       'rune_knight_charges_table', 'SHORT_OR_LONG_REST', 3, @rune_knight, 'HAS_MULTI_CHOICE:RUNE_CHOICE:Hill Rune'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'hill-rune');

INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction, requires_multi_choice)
SELECT @fighter_id, 'Stone Rune', 'stone-rune',
       'Passive: advantage on Wisdom (Insight) checks, darkvision out to 120 feet. Invoke to force a Wisdom save on a creature within 30 feet; on a failure it is charmed, its speed becomes 0, and it is incapacitated for 1 minute (or until it succeeds on a save on its turn).',
       'rune_knight_charges_table', 'SHORT_OR_LONG_REST', 3, @rune_knight, 'HAS_MULTI_CHOICE:RUNE_CHOICE:Stone Rune'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'stone-rune');

INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction, requires_multi_choice)
SELECT @fighter_id, 'Storm Rune', 'storm-rune',
       'Passive: advantage on Intelligence (Arcana) checks, can''t be surprised. Invoke to enter a prophetic state for 1 minute: once during that time, force an attack roll, saving throw, or ability check made within 60 feet of you to be rolled with advantage or disadvantage, your choice.',
       'rune_knight_charges_table', 'SHORT_OR_LONG_REST', 3, @rune_knight, 'HAS_MULTI_CHOICE:RUNE_CHOICE:Storm Rune'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'storm-rune');
