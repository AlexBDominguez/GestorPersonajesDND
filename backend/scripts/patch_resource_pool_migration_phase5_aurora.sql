-- Resource-pool mechanics layer, phase 5 (#8.2): Aurora content pass. Migrates limited-use
-- features from the ~88 non-PHB subclasses (Aurora sync) into class_resources rows / links them
-- to existing resources, following the same idempotent style as
-- patch_resource_pool_migration_phase2.sql. Every INSERT uses WHERE NOT EXISTS; every UPDATE only
-- touches consumes_resource_index_name on the specific subclass_features rows named. No existing
-- row's other columns are touched.
--
-- Drafted by an agent auditing aurora_subclass_audit_output.txt (mysql -t dump of all non-PHB
-- subclass_features), then reviewed by hand: every ID_WOTC_* index_name referenced below was
-- cross-checked against the raw dump (all 125 distinct references found verbatim, including one
-- that looks like a typo -- ID_WOTC_SCAG_ARCHETYPEFEATURE_MASTER_DUELIST, missing underscore --
-- but is the real value stored by the Aurora sync, not a transcription error), and every
-- consumes_resource_index_name reference resolves to either a resource created in this same
-- script or one already seeded in phase 2 / patch_blood_hunter_resources.sql.
--
-- NOTES:
--  1. Section 0 creates 'wild-shape' for base Druid (PHB) -- this was never seeded in phases
--     1/2/4 even though it's a PHB feature, and several Aurora Druid subclasses need it to
--     exist before their "expend a use of your Wild Shape" features can link to it.
--  2. Three ability-mod formulas needed here (constitution_modifier_min1, strength_modifier_min1,
--     one_plus_level) did not exist in CharacterClassResourceService.calculateMaxAmount() --
--     added there in the same change as this script, mirroring the existing wisdom_modifier_min1/
--     intelligence_modifier_min1/one_plus_charisma_modifier cases.
--  3. A few features don't fit the LONG_REST/SHORT_REST/SHORT_OR_LONG_REST recovery model at all
--     (e.g. "1d4 long rests", "resets to 1 not to max on long rest", "regain on natural 20" or "on
--     rolling initiative with 0 uses left"). Deliberately NOT included -- see Aurora_Fixes.md #8.2
--     for the full list and reasoning per case.
--  4. Rune Knight's Rune Carver/Master of Runes (per-rune independent charges, doubled at 15th
--     level) needs a design decision before it's worth modeling -- deliberately left out.
--
SET NAMES utf8mb4;

SET @barbarian_id = (SELECT id FROM classes WHERE index_name = 'barbarian');
SET @bard_id       = (SELECT id FROM classes WHERE index_name = 'bard');
SET @cleric_id     = (SELECT id FROM classes WHERE index_name = 'cleric');
SET @druid_id      = (SELECT id FROM classes WHERE index_name = 'druid');
SET @fighter_id    = (SELECT id FROM classes WHERE index_name = 'fighter');
SET @monk_id       = (SELECT id FROM classes WHERE index_name = 'monk');
SET @paladin_id    = (SELECT id FROM classes WHERE index_name = 'paladin');
SET @ranger_id     = (SELECT id FROM classes WHERE index_name = 'ranger');
SET @rogue_id      = (SELECT id FROM classes WHERE index_name = 'rogue');
SET @sorcerer_id   = (SELECT id FROM classes WHERE index_name = 'sorcerer');
SET @warlock_id    = (SELECT id FROM classes WHERE index_name = 'warlock');
SET @wizard_id     = (SELECT id FROM classes WHERE index_name = 'wizard');

-- =====================================================================================
-- SECTION 0 -- prerequisite gap found while cross-checking, not itself Aurora content:
-- Wild Shape (Druid, PHB) was never migrated in phases 1/2/4 (Druid isn't in that script's
-- class list at all). Several Aurora Circle subclasses say "expend a use of your Wild Shape
-- feature", which needs a real 'wild-shape' row to link to. PHB Wild Shape is a flat 2 uses
-- (no scaling formula in the DSL matches "2, growing only via optional variant rules"), so a
-- literal "2" is used, matching the "or literal integer string" DSL rule.
-- =====================================================================================
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Wild Shape', 'wild-shape',
       '2 uses of Wild Shape. Recovered on Short or Long Rest.',
       '2', 'SHORT_OR_LONG_REST', 2, NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'wild-shape');

-- =====================================================================================
-- SECTION 1 -- Barbarian (Aurora)
-- =====================================================================================

-- Zealous Presence (Path of the Zealot, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @barbarian_id, 'Zealous Presence', 'zealous-presence',
       '1 use of Zealous Presence. Recovered on Long Rest.',
       '1', 'LONG_REST', 10, 'ID_WOTC_XGTE_ARCHETYPE_PATH_OF_THE_ZEALOT'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'zealous-presence');

UPDATE subclass_features SET consumes_resource_index_name = 'zealous-presence'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_ZEALOT_ZEALOUS_PRESENCE';

-- =====================================================================================
-- SECTION 2 -- Bard (Aurora)
-- All "expend one use of your Bardic Inspiration" features link to the existing
-- 'bardic-inspiration' resource (case B) -- no new resource needed for these.
-- =====================================================================================

UPDATE subclass_features SET consumes_resource_index_name = 'bardic-inspiration'
WHERE index_name IN (
    'ID_WOTC_VRGTR_ARCHETYPE_FEATURE_BARD_SPIRITS_TALES_FROM_BEYOND',       -- College of Spirits: Tales from Beyond
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_BARD_SWORDS_BLADE_FLOURISH',           -- College of Swords: Blade Flourish (all 3 options)
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_BARD_WHISPERS_PSYCHIC_BLADES',         -- College of Whispers: Psychic Blades
    'ID_WOTC_MOOT_ARCHETYPE_FEATURE_ELOQUENCE_UNSETTLING_WORDS',           -- College of Eloquence (MOT): Unsettling Words
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_COLLEGE_OF_ELOQUENCE_UNSETTLING_WORDS',-- College of Eloquence (TCE): Unsettling Words
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_BARD_GLAMOUR_MANTLE_OF_INSPIRATION'    -- College of Glamour: Mantle of Inspiration
);

-- Spirit Session (College of Spirits, VRGtR): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Spirit Session', 'spirit-session',
       '1 use of Spirit Session. Recovered on Long Rest.',
       '1', 'LONG_REST', 6, 'ID_WOTC_VRGTR_ARCHETYPE_COLLEGE_OF_SPIRITS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'spirit-session');
UPDATE subclass_features SET consumes_resource_index_name = 'spirit-session'
WHERE index_name = 'ID_WOTC_VRGTR_ARCHETYPE_FEATURE_BARD_SPIRITS_SPIRIT_SESSION';

-- Words of Terror (College of Whispers, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Words of Terror', 'words-of-terror',
       '1 use of Words of Terror. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 3, 'ID_WOTC_XGTE_ARCHETYPE_COLLEGE_OF_WHISPERS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'words-of-terror');
UPDATE subclass_features SET consumes_resource_index_name = 'words-of-terror'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_BARD_WHISPERS_WORDS_OF_TERROR';

-- Mantle of Whispers (College of Whispers, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Mantle of Whispers', 'mantle-of-whispers',
       '1 use of Mantle of Whispers. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 6, 'ID_WOTC_XGTE_ARCHETYPE_COLLEGE_OF_WHISPERS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'mantle-of-whispers');
UPDATE subclass_features SET consumes_resource_index_name = 'mantle-of-whispers'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_BARD_WHISPERS_MANTLE_OF_WHISPERS';

-- Shadow Lore (College of Whispers, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Shadow Lore', 'shadow-lore',
       '1 use of Shadow Lore. Recovered on Long Rest.',
       '1', 'LONG_REST', 14, 'ID_WOTC_XGTE_ARCHETYPE_COLLEGE_OF_WHISPERS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'shadow-lore');
UPDATE subclass_features SET consumes_resource_index_name = 'shadow-lore'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_BARD_WHISPERS_SHADOW_LORE';

-- Performance of Creation (College of Creation, TCE): 1 use, Long Rest (spell-slot alt-use not modeled).
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Performance of Creation', 'performance-of-creation',
       '1 use of Performance of Creation. Recovered on Long Rest.',
       '1', 'LONG_REST', 3, 'ID_WOTC_TCOE_ARCHETYPE_BARD_COLLEGE_OF_CREATION'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'performance-of-creation');
UPDATE subclass_features SET consumes_resource_index_name = 'performance-of-creation'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_COLLEGE_OF_CREATION_PERFORMANCE_OF_CREATION';

-- Animating Performance (College of Creation, TCE): 1 use, Long Rest (spell-slot alt-use not modeled).
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Animating Performance', 'animating-performance',
       '1 use of Animating Performance. Recovered on Long Rest.',
       '1', 'LONG_REST', 6, 'ID_WOTC_TCOE_ARCHETYPE_BARD_COLLEGE_OF_CREATION'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'animating-performance');
UPDATE subclass_features SET consumes_resource_index_name = 'animating-performance'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_COLLEGE_OF_CREATION_ANIMATING_PERFORMANCE';

-- Universal Speech (College of Eloquence): reprinted in MOT and TCE -- two separate subclass
-- rows in this DB, so two separate resources (subclass_restriction is single-value equality).
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Universal Speech', 'universal-speech-mot',
       '1 use of Universal Speech. Recovered on Long Rest.',
       '1', 'LONG_REST', 6, 'ID_WOTC_MOOT_ARCHETYPE_BARD_COLLEGE_OF_ELOQUENCE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'universal-speech-mot');
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Universal Speech', 'universal-speech-tce',
       '1 use of Universal Speech. Recovered on Long Rest.',
       '1', 'LONG_REST', 6, 'ID_WOTC_TCOE_ARCHETYPE_BARD_COLLEGE_OF_ELOQUENCE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'universal-speech-tce');
UPDATE subclass_features SET consumes_resource_index_name = 'universal-speech-mot'
WHERE index_name = 'ID_WOTC_MOOT_ARCHETYPE_FEATURE_ELOQUENCE_UNIVERSAL_SPEECH';
UPDATE subclass_features SET consumes_resource_index_name = 'universal-speech-tce'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_COLLEGE_OF_ELOQUENCE_UNIVERSAL_SPEECH';

-- Infectious Inspiration (College of Eloquence): does NOT expend Bardic Inspiration (explicitly
-- "without expending any of your Bardic Inspiration uses") -- genuinely separate resource.
-- Reprinted in MOT and TCE -- two rows again.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Infectious Inspiration', 'infectious-inspiration-mot',
       'Uses equal to your Charisma modifier (minimum 1). Recovered on Long Rest.',
       'charisma_modifier', 'LONG_REST', 14, 'ID_WOTC_MOOT_ARCHETYPE_BARD_COLLEGE_OF_ELOQUENCE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'infectious-inspiration-mot');
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Infectious Inspiration', 'infectious-inspiration-tce',
       'Uses equal to your Charisma modifier (minimum 1). Recovered on Long Rest.',
       'charisma_modifier', 'LONG_REST', 14, 'ID_WOTC_TCOE_ARCHETYPE_BARD_COLLEGE_OF_ELOQUENCE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'infectious-inspiration-tce');
UPDATE subclass_features SET consumes_resource_index_name = 'infectious-inspiration-mot'
WHERE index_name = 'ID_WOTC_MOOT_ARCHETYPE_FEATURE_ELOQUENCE_INFECTIOUS_INSPIRATION';
UPDATE subclass_features SET consumes_resource_index_name = 'infectious-inspiration-tce'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_COLLEGE_OF_ELOQUENCE_INFECTIOUS_INSPIRATION';

-- Enthralling Performance (College of Glamour, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Enthralling Performance', 'enthralling-performance',
       '1 use of Enthralling Performance. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 3, 'ID_WOTC_XGTE_ARCHETYPE_COLLEGE_OF_GLAMOUR'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'enthralling-performance');
UPDATE subclass_features SET consumes_resource_index_name = 'enthralling-performance'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_BARD_GLAMOUR_ENTHRALLING_PERFORMANCE';

-- Mantle of Majesty (College of Glamour, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bard_id, 'Mantle of Majesty', 'mantle-of-majesty',
       '1 use of Mantle of Majesty. Recovered on Long Rest.',
       '1', 'LONG_REST', 6, 'ID_WOTC_XGTE_ARCHETYPE_COLLEGE_OF_GLAMOUR'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'mantle-of-majesty');
UPDATE subclass_features SET consumes_resource_index_name = 'mantle-of-majesty'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_BARD_GLAMOUR_MANTLE_OF_MAJESTY';

-- =====================================================================================
-- SECTION 3 -- Cleric (Aurora)
-- =====================================================================================

-- Channel Divinity options that consume the existing 'channel-divinity-cleric' resource (case B).
UPDATE subclass_features SET consumes_resource_index_name = 'channel-divinity-cleric'
WHERE index_name IN (
    'ID_WOTC_SCAG_ARCHETYPE_FEATURE_ARCANA_DOMAIN_CD_ARCANE_ABJURATION',     -- Arcana Domain: Arcane Abjuration
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_FORGE_DOMAIN_CD_ARTISANS_BLESSING',      -- Forge Domain: Artisan's Blessing
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_TWILIGHT_DOMAIN_CD_TWILIGHT_SANCTUARY'   -- Twilight Domain: Twilight Sanctuary
);

-- Eyes of the Grave (Grave Domain, XGtE): Wisdom modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @cleric_id, 'Eyes of the Grave', 'eyes-of-the-grave',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 1, 'ID_WOTC_XGTE_ARCHETYPE_CLERIC_GRAVE_DOMAIN'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'eyes-of-the-grave');
UPDATE subclass_features SET consumes_resource_index_name = 'eyes-of-the-grave'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_GRAVE_DOMAIN_EYES_OF_THE_GRAVE';

-- Sentinel at Death's Door (Grave Domain, XGtE): Wisdom modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @cleric_id, 'Sentinel at Death''s Door', 'sentinel-at-deaths-door',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 6, 'ID_WOTC_XGTE_ARCHETYPE_CLERIC_GRAVE_DOMAIN'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'sentinel-at-deaths-door');
UPDATE subclass_features SET consumes_resource_index_name = 'sentinel-at-deaths-door'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_GRAVE_DOMAIN_SENTINEL_AT_DEATHS_DOOR';
-- NOTE: Keeper of Souls (Grave Domain, level 17) is NOT included -- it recharges "at the start
-- of your next turn", not on any rest. Doesn't fit the resource model. See report section 3.

-- Embodiment of the Law (Order Domain): reprinted in GGtR and TCE -- two subclass rows, two resources.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @cleric_id, 'Embodiment of the Law', 'embodiment-of-the-law-ggtr',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 6, 'ID_WOTC_GGTR_ARCHETYPE_CLERIC_ORDER_DOMAIN'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'embodiment-of-the-law-ggtr');
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @cleric_id, 'Embodiment of the Law', 'embodiment-of-the-law-tce',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 6, 'ID_WOTC_TCOE_ARCHETYPE_Order_Domain'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'embodiment-of-the-law-tce');
UPDATE subclass_features SET consumes_resource_index_name = 'embodiment-of-the-law-ggtr'
WHERE index_name = 'ID_WOTC_GGTR_ARCHETYPE_FEATURE_ORDER_DOMAIN_EMBODIMENT_OF_THE_LAW';
UPDATE subclass_features SET consumes_resource_index_name = 'embodiment-of-the-law-tce'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_ORDER_DOMAIN_EMBODIMENT_OF_THE_LAW';

-- Emboldening Bond (Peace Domain, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @cleric_id, 'Emboldening Bond', 'emboldening-bond',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 1, 'ID_WOTC_TCOE_ARCHETYPE_PEACE_DOMAIN'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'emboldening-bond');
UPDATE subclass_features SET consumes_resource_index_name = 'emboldening-bond'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_PEACE_DOMAIN_EMBOLDENING_BOND';

-- Eyes of Night (Twilight Domain, TCE): 1 use, Long Rest (spell-slot alt-use not modeled).
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @cleric_id, 'Eyes of Night', 'eyes-of-night',
       '1 use of Eyes of Night (sharing darkvision). Recovered on Long Rest.',
       '1', 'LONG_REST', 1, 'ID_WOTC_TCOE_ARCHETYPE_CLERIC_TWILIGHT_DOMAIN'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'eyes-of-night');
UPDATE subclass_features SET consumes_resource_index_name = 'eyes-of-night'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_TWILIGHT_DOMAIN_EYES_OF_NIGHT';

-- Blessing of the Forge (Forge Domain, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @cleric_id, 'Blessing of the Forge', 'blessing-of-the-forge',
       '1 use of Blessing of the Forge. Recovered on Long Rest.',
       '1', 'LONG_REST', 1, 'ID_WOTC_XGTE_ARCHETYPE_CLERIC_FORGE_DOMAIN'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'blessing-of-the-forge');
UPDATE subclass_features SET consumes_resource_index_name = 'blessing-of-the-forge'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_FORGE_DOMAIN_BLESSING_OF_THE_FORGE';

-- =====================================================================================
-- SECTION 4 -- Druid (Aurora)   (see SECTION 0 for the 'wild-shape' prerequisite row)
-- =====================================================================================

-- Features that expend a use of Wild Shape instead of transforming (case B, once Section 0 lands).
UPDATE subclass_features SET consumes_resource_index_name = 'wild-shape'
WHERE index_name IN (
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CIRCLE_OF_SPORES_SYMBIOTIC_ENTITY',  -- Circle of Spores (TCE): Symbiotic Entity
    'ID_WOTC_GGTR_ARCHETYPE_FEATURE_CIRCLE_SPORES_SYMBIOTIC_ENTITY',     -- Circle of Spores (GGtR): Symbiotic Entity
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CIRCLE_OF_STARS_STARRY_FORM',        -- Circle of Stars: Starry Form
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CIRCLE_OF_WILDFIRE_SUMMON_WILDFIRE_SPIRIT' -- Circle of Wildfire: Summon Wildfire Spirit
);

-- Fungal Infestation (Circle of Spores): reprinted TCE + GGtR -- two resources.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Fungal Infestation', 'fungal-infestation-tce',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 6, 'ID_WOTC_TCOE_ARCHETYPE_DRUID_CIRCLE_OF_SPORES'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'fungal-infestation-tce');
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Fungal Infestation', 'fungal-infestation-ggtr',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 6, 'ID_WOTC_GGTR_ARCHETYPE_CIRCLE_SPORES'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'fungal-infestation-ggtr');
UPDATE subclass_features SET consumes_resource_index_name = 'fungal-infestation-tce'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CIRCLE_OF_SPORES_FUNGAL_INFESTATION';
UPDATE subclass_features SET consumes_resource_index_name = 'fungal-infestation-ggtr'
WHERE index_name = 'ID_WOTC_GGTR_ARCHETYPE_FEATURE_CIRCLE_SPORES_FUNGAL_INFESTATION';

-- Star Map's at-will guiding bolt (Circle of Stars, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Star Map (Guiding Bolt)', 'circle-of-stars-guiding-bolt',
       'Uses equal to your proficiency bonus for casting guiding bolt without a spell slot. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 2, 'ID_WOTC_TCOE_ARCHETYPE_CIRCLE_OF_STARS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'circle-of-stars-guiding-bolt');
UPDATE subclass_features SET consumes_resource_index_name = 'circle-of-stars-guiding-bolt'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CIRCLE_OF_STARS_STAR_MAP';

-- Cosmic Omen (Circle of Stars, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Cosmic Omen', 'cosmic-omen',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 6, 'ID_WOTC_TCOE_ARCHETYPE_CIRCLE_OF_STARS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'cosmic-omen');
UPDATE subclass_features SET consumes_resource_index_name = 'cosmic-omen'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CIRCLE_OF_STARS_COSMIC_OMEN';

-- Balm of the Summer Court (Circle of the Dreams, XGtE): d6 pool equal to druid level, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Balm of the Summer Court', 'balm-of-the-summer-court',
       'Pool of d6s equal to your druid level. Recovered on Long Rest.',
       'level', 'LONG_REST', 2, 'ID_WOTC_XGTE_ARCHETYPE_CIRCLE_OF_DREAMS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'balm-of-the-summer-court');
UPDATE subclass_features SET consumes_resource_index_name = 'balm-of-the-summer-court'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_DREAMS_BALM_OF_THE_SUMMER_COURT';

-- Hidden Paths (Circle of the Dreams, XGtE): Wisdom modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Hidden Paths', 'hidden-paths',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 10, 'ID_WOTC_XGTE_ARCHETYPE_CIRCLE_OF_DREAMS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'hidden-paths');
UPDATE subclass_features SET consumes_resource_index_name = 'hidden-paths'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_DREAMS_HIDDEN_PATHS';

-- Walker in Dreams (Circle of the Dreams, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Walker in Dreams', 'walker-in-dreams',
       '1 use of Walker in Dreams. Recovered on Long Rest.',
       '1', 'LONG_REST', 14, 'ID_WOTC_XGTE_ARCHETYPE_CIRCLE_OF_DREAMS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'walker-in-dreams');
UPDATE subclass_features SET consumes_resource_index_name = 'walker-in-dreams'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_DREAMS_WALKER_IN_DREAMS';

-- Spirit Totem (Circle of the Shepherd, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Spirit Totem', 'spirit-totem',
       '1 use of Spirit Totem. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 2, 'ID_WOTC_XGTE_ARCHETYPE_CIRCLE_OF_THE_SHEPHERD'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'spirit-totem');
UPDATE subclass_features SET consumes_resource_index_name = 'spirit-totem'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_SHEPHERD_SPIRIT_TOTEM';

-- Cauterizing Flames (Circle of Wildfire, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Cauterizing Flames', 'cauterizing-flames-wildfire',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 10, 'ID_WOTC_TCOE_ARCHETYPE_DRUID_CIRCLE_OF_WILDFIRE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'cauterizing-flames-wildfire');
UPDATE subclass_features SET consumes_resource_index_name = 'cauterizing-flames-wildfire'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CIRCLE_OF_WILDFIRE_CAUTERIZING_FLAMES';

-- Blazing Revival (Circle of Wildfire, TCE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @druid_id, 'Blazing Revival', 'blazing-revival',
       '1 use of Blazing Revival. Recovered on Long Rest.',
       '1', 'LONG_REST', 14, 'ID_WOTC_TCOE_ARCHETYPE_DRUID_CIRCLE_OF_WILDFIRE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'blazing-revival');
UPDATE subclass_features SET consumes_resource_index_name = 'blazing-revival'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CIRCLE_OF_WILDFIRE_BLAZING_REVIVAL';

-- =====================================================================================
-- SECTION 5 -- Fighter (Aurora)
-- =====================================================================================

-- Rapid Repair (Gunslinger, CR): consumes existing 'grit' resource (case B).
UPDATE subclass_features SET consumes_resource_index_name = 'grit'
WHERE index_name = 'gunslinger-rapid-repair';
-- NOTE: existing 'grit' row (id 2) has recovery_type = SHORT_REST, but the Gunslinger's own
-- Adept Marksman text says "Regain all grit on a short OR long rest". Under the current
-- recoverResources() query, a SHORT_REST-only resource does NOT recover on longRest() (only
-- LONG_REST and SHORT_OR_LONG_REST rows do). This looks like a pre-existing bug from an
-- earlier phase, outside this Aurora pass's scope -- flagged in the report, not changed here.

-- Arcane Shot (Arcane Archer, XGtE): 2 uses (fixed), Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Arcane Shot', 'arcane-shot',
       '2 uses of Arcane Shot. Recovered on Short or Long Rest.',
       '2', 'SHORT_OR_LONG_REST', 3, 'ID_WOTC_XGTE_ARCHETYPE_FIGHTER_ARCANE_ARCHER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'arcane-shot');
UPDATE subclass_features SET consumes_resource_index_name = 'arcane-shot'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_ARCANE_ARCHER_ARCANE_SHOT';
-- NOTE: Ever-ready Shot (level 15) regains 1 use "if you roll initiative with 0 uses left" --
-- an event-triggered regen the current resource system doesn't model. Not included; see report.

-- Unwavering Mark (Cavalier, XGtE): Strength modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Unwavering Mark', 'unwavering-mark',
       'Uses equal to your Strength modifier (minimum 1). Recovered on Long Rest.',
       'strength_modifier_min1', 'LONG_REST', 3, 'ID_WOTC_XGTE_ARCHETYPE_FIGHTER_CAVALIER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'unwavering-mark');
UPDATE subclass_features SET consumes_resource_index_name = 'unwavering-mark'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_CAVALIER_UNWAVERING_MARK';

-- Warding Maneuver (Cavalier, XGtE): Constitution modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Warding Maneuver', 'warding-maneuver',
       'Uses equal to your Constitution modifier (minimum 1). Recovered on Long Rest.',
       'constitution_modifier_min1', 'LONG_REST', 7, 'ID_WOTC_XGTE_ARCHETYPE_FIGHTER_CAVALIER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'warding-maneuver');
UPDATE subclass_features SET consumes_resource_index_name = 'warding-maneuver'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_CAVALIER_WARDING_MANEUVER';

-- Unleash Incarnation (Echo Knight, EGtW): Constitution modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Unleash Incarnation', 'unleash-incarnation',
       'Uses equal to your Constitution modifier (minimum 1). Recovered on Long Rest.',
       'constitution_modifier_min1', 'LONG_REST', 3, 'ID_WOTC_EGTW_ARCHETYPE_FIGHTER_ECHO_KNIGHT'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'unleash-incarnation');
UPDATE subclass_features SET consumes_resource_index_name = 'unleash-incarnation'
WHERE index_name = 'ID_WOTC_EGTW_ARCHETYPE_FEATURE_ECHO_KNIGHT_UNLEASH_INCARNATION';

-- Reclaim Potential (Echo Knight, EGtW): Constitution modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Reclaim Potential', 'reclaim-potential',
       'Uses equal to your Constitution modifier (minimum 1). Recovered on Long Rest.',
       'constitution_modifier_min1', 'LONG_REST', 15, 'ID_WOTC_EGTW_ARCHETYPE_FIGHTER_ECHO_KNIGHT'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'reclaim-potential');
UPDATE subclass_features SET consumes_resource_index_name = 'reclaim-potential'
WHERE index_name = 'ID_WOTC_EGTW_ARCHETYPE_FEATURE_ECHO_KNIGHT_RECLAIM_POTENTIAL';

-- Giant's Might (Rune Knight, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Giant''s Might', 'giants-might',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 3, 'ID_WOTC_TCOE_ARCHETYPE_FIGHTER_RUNE_KNIGHT'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'giants-might');
UPDATE subclass_features SET consumes_resource_index_name = 'giants-might'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_RUNE_KNIGHT_GIANTS_MIGHT';

-- Runic Shield (Rune Knight, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Runic Shield', 'runic-shield',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 7, 'ID_WOTC_TCOE_ARCHETYPE_FIGHTER_RUNE_KNIGHT'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'runic-shield');
UPDATE subclass_features SET consumes_resource_index_name = 'runic-shield'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_RUNE_KNIGHT_RUNIC_SHIELD';
-- NOTE: Rune Carver (level 3) and Master of Runes (level 15) are DELIBERATELY NOT modeled here.
-- Each individual rune (Cloud, Fire, Frost, etc.) has its OWN independent "once per short/long
-- rest" use, doubled to twice by Master of Runes. That's either 6+ near-identical per-rune
-- resources or a genuinely new "per-rune pool" concept, and Master of Runes would need a new
-- level-threshold table formula (1 use below level 15, 2 at 15+) that doesn't exist yet. This
-- needs a design decision from you before it's worth writing SQL for -- see report section 3.

-- Fighting Spirit (Samurai, XGtE): 3 uses (fixed), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Fighting Spirit', 'fighting-spirit',
       '3 uses of Fighting Spirit. Recovered on Long Rest.',
       '3', 'LONG_REST', 3, 'ID_WOTC_XGTE_ARCHETYPE_FIGHTER_SAMURAI'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'fighting-spirit');
UPDATE subclass_features SET consumes_resource_index_name = 'fighting-spirit'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_SAMURAI_FIGHTING_SPIRIT';
-- NOTE: Tireless Spirit (level 10) has the same "regain on initiative roll if empty" pattern as
-- Ever-ready Shot above -- not modeled, see report.

-- Psionic Power / Psionic Energy dice (Psi Warrior, TCE): twice proficiency bonus, Long Rest.
-- (Full recovery is Long Rest; the bonus-action "regain 1 die, once per short/long rest" partial
-- recharge is a feature-level mechanic the simple resource model doesn't capture -- see report.)
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id, 'Psionic Energy Dice', 'psionic-energy-dice-fighter',
       'd6 dice equal to twice your proficiency bonus. Recovered on Long Rest.',
       'twice_proficiency_bonus', 'LONG_REST', 3, 'ID_WOTC_TCOE_ARCHETYPE_FIGHTER_PSI_WARRIOR'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'psionic-energy-dice-fighter');
UPDATE subclass_features SET consumes_resource_index_name = 'psionic-energy-dice-fighter'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_PSI_WARRIOR_PSIONIC_POWER';

-- =====================================================================================
-- SECTION 6 -- Monk (Aurora)   -- all of these consume the existing 'ki' resource (case B).
-- =====================================================================================

UPDATE subclass_features SET consumes_resource_index_name = 'ki'
WHERE index_name IN (
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_WAY_OF_MERCY_HAND_OF_HEALING',                 -- Way of Mercy: Hand of Healing
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_WAY_OF_MERCY_HAND_OF_ULTIMATE_MERCY',          -- Way of Mercy: Hand of Ultimate Mercy
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_WAY_OF_THE_ASTRAL_SELF_ARMS_OF_THE_ASTRAL_SELF',   -- Astral Self: Arms
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_WAY_OF_THE_ASTRAL_SELF_VISAGE_OF_THE_ASTRAL_SELF', -- Astral Self: Visage
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_WAY_OF_THE_ASTRAL_SELF_AWAKENED_ASTRAL_SELF',      -- Astral Self: Awakened Astral Self
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_DRUNKEN_MASTER_TIPSY_SWAY',                    -- Drunken Master: Tipsy Sway (Redirect Attack)
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_DRUNKEN_MASTER_DRUNKARDS_LUCK',                -- Drunken Master: Drunkard's Luck
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_KENSEI_ONE_WITH_THE_BLADE',                    -- Kensei: One with the Blade (Deft Strike)
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_KENSEI_SHARPEN_THE_BLADE',                     -- Kensei: Sharpen the Blade
    'ID_WOTC_SCAG_ARCHETYPE_FEATURE_WAY_OF_THE_LONG_DEATH_MASTERY_OF_DEATH',       -- Long Death: Mastery of Death
    'ID_WOTC_SCAG_ARCHETYPE_FEATURE_WAY_OF_THE_LONG_DEATH_TOUCH_OF_THE_LONG_DEATH',-- Long Death: Touch of the Long Death
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_SUN_SOUL_RADIANT_SUN_BOLT',                    -- Sun Soul (XGtE): Radiant Sun Bolt
    'ID_WOTC_SCAG_ARCHETYPE_FEATURE_WAY_OF_THE_SUN_SOUL_RADIANT_SUN_BOLT',         -- Sun Soul (SCAG): Radiant Sun Bolt
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_SUN_SOUL_SEARING_ARC_STRIKE',                  -- Sun Soul (XGtE): Searing Arc Strike
    'ID_WOTC_SCAG_ARCHETYPE_FEATURE_WAY_OF_THE_SUN_SOUL_SEARING_ARC_STRIKE',       -- Sun Soul (SCAG): Searing Arc Strike
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_SUN_SOUL_SEARING_SUNBURST',                    -- Sun Soul (XGtE): Searing Sunburst
    'ID_WOTC_SCAG_ARCHETYPE_FEATURE_WAY_OF_THE_SUN_SOUL_SEARING_SUNBURST'          -- Sun Soul (SCAG): Searing Sunburst
);
-- NOTE: all index_name values above were transcribed by hand from a text dump of section 2/2b
-- of the audit (mysql -t output). Recommend running each UPDATE's WHERE clause as a SELECT
-- COUNT(*) first to confirm row counts match expectations before committing to UPDATE, in case
-- of a transcription slip.

-- Breath of the Dragon (Way of the Ascendant Dragon, FToD): proficiency bonus uses, Long Rest
-- (alt-use for 2 ki points when out of uses is a feature-level mechanic, not modeled).
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @monk_id, 'Breath of the Dragon', 'breath-of-the-dragon',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 3, 'ID_WOTC_FTOD_ARCHETYPE_MONK_WAY_OF_THE_ASCENDANT_DRAGON'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'breath-of-the-dragon');
UPDATE subclass_features SET consumes_resource_index_name = 'breath-of-the-dragon'
WHERE index_name = 'ID_WOTC_FTOD_ARCHETYPE_FEATURE_WAY_OF_THE_ASCENDANT_DRAGON_BREATH_OF_THE_DRAGON';

-- Wings Unfurled (Way of the Ascendant Dragon, FToD): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @monk_id, 'Wings Unfurled', 'wings-unfurled',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 6, 'ID_WOTC_FTOD_ARCHETYPE_MONK_WAY_OF_THE_ASCENDANT_DRAGON'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'wings-unfurled');
UPDATE subclass_features SET consumes_resource_index_name = 'wings-unfurled'
WHERE index_name = 'ID_WOTC_FTOD_ARCHETYPE_FEATURE_WAY_OF_THE_ASCENDANT_DRAGON_WINGS_UNFURLED';

-- =====================================================================================
-- SECTION 7 -- Paladin (Aurora)
-- =====================================================================================

-- Channel Divinity options that consume the existing 'channel-divinity' resource (case B).
UPDATE subclass_features SET consumes_resource_index_name = 'channel-divinity'
WHERE index_name IN (
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_OATH_OF_CONQUEST_CHANNEL_DIVINITY',       -- Oath of Conquest
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_OATH_OF_GLORY_CHANNEL_DIVINITY',         -- Oath of Glory (TCE)
    'ID_WOTC_MOOT_ARCHETYPE_FEATURE_GLORY_CHANNEL_DIVINITY',                 -- Oath of Glory (MOT)
    'ID_WOTC_SCAG_ARCHETYPE_FEATURE_OATH_OF_THE_CROWN_CHANNEL_DIVINITY',     -- Oath of the Crown
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_OATH_OF_THE_WATCHERS_CHANNEL_DIVINITY'   -- Oath of the Watchers
);

-- Invincible Conqueror (Oath of Conquest, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @paladin_id, 'Invincible Conqueror', 'invincible-conqueror',
       '1 use of Invincible Conqueror. Recovered on Long Rest.',
       '1', 'LONG_REST', 20, 'ID_WOTC_XGTE_ARCHETYPE_OATH_OF_CONQUEST'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'invincible-conqueror');
UPDATE subclass_features SET consumes_resource_index_name = 'invincible-conqueror'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_OATH_OF_CONQUEST_INVINCIBLE_CONQUEROR';

-- Glorious Defense (Oath of Glory): reprinted TCE + MOT -- two resources.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @paladin_id, 'Glorious Defense', 'glorious-defense-tce',
       'Uses equal to your Charisma modifier (minimum 1). Recovered on Long Rest.',
       'charisma_modifier', 'LONG_REST', 15, 'ID_WOTC_TCOE_ARCHETYPE_PALADIN_OATH_OF_GLORY'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'glorious-defense-tce');
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @paladin_id, 'Glorious Defense', 'glorious-defense-mot',
       'Uses equal to your Charisma modifier (minimum 1). Recovered on Long Rest.',
       'charisma_modifier', 'LONG_REST', 15, 'ID_WOTC_MOOT_ARCHETYPE_PALADIN_OATH_OF_GLORY'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'glorious-defense-mot');
UPDATE subclass_features SET consumes_resource_index_name = 'glorious-defense-tce'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_OATH_OF_GLORY_GLORIOUS_DEFENSE';
UPDATE subclass_features SET consumes_resource_index_name = 'glorious-defense-mot'
WHERE index_name = 'ID_WOTC_MOOT_ARCHETYPE_FEATURE_GLORY_GLORIOUS_DEFENSE';

-- =====================================================================================
-- SECTION 8 -- Ranger (Aurora)
-- =====================================================================================

-- Perfected Bond (Drakewarden, FToD): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @ranger_id, 'Perfected Bond (Reflexive Resistance)', 'perfected-bond',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 15, 'ID_WOTC_FTOD_ARCHETYPE_RANGER_DRAKEWARDEN'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'perfected-bond');
UPDATE subclass_features SET consumes_resource_index_name = 'perfected-bond'
WHERE index_name = 'ID_WOTC_FTOD_ARCHETYPE_FEATURE_DRAKEWARDEN_PERFECTED_BOND';

-- Misty Wanderer (Fey Wanderer, TCE): Wisdom modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @ranger_id, 'Misty Wanderer', 'misty-wanderer',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 15, 'ID_WOTC_TCOE_ARCHETYPE_RANGER_FEY_WANDERER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'misty-wanderer');
UPDATE subclass_features SET consumes_resource_index_name = 'misty-wanderer'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_FEY_WANDERER_MISTY_WANDERER';

-- Detect Portal (Horizon Walker, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @ranger_id, 'Detect Portal', 'detect-portal',
       '1 use of Detect Portal. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 3, 'ID_WOTC_XGTE_ARCHETYPE_HORIZON_WALKER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'detect-portal');
UPDATE subclass_features SET consumes_resource_index_name = 'detect-portal'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_HORIZON_WALKER_DETECT_PORTAL';

-- Ethereal Step (Horizon Walker, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @ranger_id, 'Ethereal Step', 'ethereal-step',
       '1 use of Ethereal Step. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 7, 'ID_WOTC_XGTE_ARCHETYPE_HORIZON_WALKER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'ethereal-step');
UPDATE subclass_features SET consumes_resource_index_name = 'ethereal-step'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_HORIZON_WALKER_ETHEREAL_STEP';

-- Hunter's Sense (Monster Slayer, XGtE): Wisdom modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @ranger_id, 'Hunter''s Sense', 'hunters-sense',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 3, 'ID_WOTC_XGTE_ARCHETYPE_RANGER_MONSTER_SLAYER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'hunters-sense');
UPDATE subclass_features SET consumes_resource_index_name = 'hunters-sense'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_RANGER_SLAYER_HUNTERS_SENSE';

-- Magic-user's Nemesis (Monster Slayer, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @ranger_id, 'Magic-user''s Nemesis', 'magic-users-nemesis',
       '1 use of Magic-user''s Nemesis. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 11, 'ID_WOTC_XGTE_ARCHETYPE_RANGER_MONSTER_SLAYER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'magic-users-nemesis');
UPDATE subclass_features SET consumes_resource_index_name = 'magic-users-nemesis'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_RANGER_SLAYER_MAGICUSERS_NEMESIS';

-- Writhing Tide (Swarmkeeper, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @ranger_id, 'Writhing Tide', 'writhing-tide',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 7, 'ID_WOTC_TCOE_ARCHETYPE_RANGER_SWARMKEEPER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'writhing-tide');
UPDATE subclass_features SET consumes_resource_index_name = 'writhing-tide'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_SWARMKEEPER_WRITHING_TIDE';

-- Swarming Dispersal (Swarmkeeper, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @ranger_id, 'Swarming Dispersal', 'swarming-dispersal',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 15, 'ID_WOTC_TCOE_ARCHETYPE_RANGER_SWARMKEEPER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'swarming-dispersal');
UPDATE subclass_features SET consumes_resource_index_name = 'swarming-dispersal'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_SWARMKEEPER_SWARMING_DISPERSAL';

-- =====================================================================================
-- SECTION 9 -- Rogue (Aurora)
-- =====================================================================================

-- Unerring Eye (Inquisitive, XGtE): Wisdom modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @rogue_id, 'Unerring Eye', 'unerring-eye',
       'Uses equal to your Wisdom modifier (minimum 1). Recovered on Long Rest.',
       'wisdom_modifier_min1', 'LONG_REST', 13, 'ID_WOTC_XGTE_ARCHETYPE_INQUISITIVE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'unerring-eye');
UPDATE subclass_features SET consumes_resource_index_name = 'unerring-eye'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_INQUISITIVE_UNERRING_EYE';

-- Wails from the Grave (Phantom, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @rogue_id, 'Wails from the Grave', 'wails-from-the-grave',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 3, 'ID_WOTC_TCOE_ARCHETYPE_ROGUE_PHANTOM'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'wails-from-the-grave');
UPDATE subclass_features SET consumes_resource_index_name = 'wails-from-the-grave'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_PHANTOM_WAILS_FROM_THE_GRAVE';

-- Ghost Walk (Phantom, TCE): 1 use, Long Rest (alt-use by destroying a soul trinket not modeled).
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @rogue_id, 'Ghost Walk', 'ghost-walk',
       '1 use of Ghost Walk. Recovered on Long Rest.',
       '1', 'LONG_REST', 13, 'ID_WOTC_TCOE_ARCHETYPE_ROGUE_PHANTOM'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'ghost-walk');
UPDATE subclass_features SET consumes_resource_index_name = 'ghost-walk'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_PHANTOM_GHOST_WALK';
-- NOTE: Tokens of the Departed (Phantom, level 9) is NOT included -- soul trinkets accumulate
-- opportunistically when a nearby creature dies (capped at proficiency bonus), not on a rest
-- cycle. Doesn't fit the LONG_REST/SHORT_REST model; see report.

-- Psionic Power / Psionic Energy dice (Soulknife, TCE): twice proficiency bonus, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @rogue_id, 'Psionic Energy Dice', 'psionic-energy-dice-rogue',
       'd6 dice equal to twice your proficiency bonus. Recovered on Long Rest.',
       'twice_proficiency_bonus', 'LONG_REST', 3, 'ID_WOTC_TCOE_ARCHETYPE_ROGUE_SOULKNIFE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'psionic-energy-dice-rogue');
UPDATE subclass_features SET consumes_resource_index_name = 'psionic-energy-dice-rogue'
WHERE index_name IN (
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_SOULKNIFE_PSIONIC_POWER',
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_SOULKNIFE_SOUL_BLADES',   -- Homing Strikes / Psychic Teleportation
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_SOULKNIFE_PSYCHIC_VEIL',
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_SOULKNIFE_REND_MIND'
);

-- Master Duelist (Swashbuckler, SCAG): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @rogue_id, 'Master Duelist', 'master-duelist',
       '1 use of Master Duelist. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 17, 'ID_WOTC_SCAG_ARCHETYPE_SWASHBUCKLER'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'master-duelist');
UPDATE subclass_features SET consumes_resource_index_name = 'master-duelist'
WHERE index_name = 'ID_WOTC_SCAG_ARCHETYPEFEATURE_MASTER_DUELIST';

-- =====================================================================================
-- SECTION 10 -- Sorcerer (Aurora)
-- =====================================================================================

-- Features that spend existing Sorcery Points ('font-of-magic') instead of a spell slot (case B).
UPDATE subclass_features SET consumes_resource_index_name = 'font-of-magic'
WHERE index_name IN (
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_ABERRANT_MIND_PSIONIC_SORCERY',      -- Aberrant Mind: Psionic Sorcery
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_ABERRANT_MIND_REVELATION_IN_FLESH',  -- Aberrant Mind: Revelation in Flesh
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_ABERRANT_MIND_WARPING_IMPLOSION',    -- Aberrant Mind: Warping Implosion
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CLOCKWORK_SOUL_BASTION_OF_LAW',      -- Clockwork Soul: Bastion of Law
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CLOCKWORK_SOUL_TRANCE_OF_ORDER',     -- Clockwork Soul: Trance of Order
    'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CLOCKWORK_SOUL_CLOCKWORK_CAVALCADE', -- Clockwork Soul: Clockwork Cavalcade
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_DIVINE_SOUL_EMPOWERED_HEALING',      -- Divine Soul: Empowered Healing
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_SHADOW_MAGIC_HOUND_OF_ILL_OMEN',     -- Shadow Magic: Hound of Ill Omen
    'ID_WOTC_XGTE_ARCHETYPE_FEATURE_SHADOW_MAGIC_EYES_OF_THE_DARK'       -- Shadow Magic: Eyes of the Dark (darkness spell)
);

-- Restore Balance (Clockwork Soul, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @sorcerer_id, 'Restore Balance', 'restore-balance',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 1, 'ID_WOTC_TCOE_ARCHETYPE_SORCERER_CLOCKWORK_SOUL'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'restore-balance');
UPDATE subclass_features SET consumes_resource_index_name = 'restore-balance'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_CLOCKWORK_SOUL_RESTORE_BALANCE';

-- Favored by the Gods (Divine Soul, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @sorcerer_id, 'Favored by the Gods', 'favored-by-the-gods',
       '1 use of Favored by the Gods. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 1, 'ID_WOTC_XGTE_SORCERER_ARCHETYPE_DIVINE_SOUL'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'favored-by-the-gods');
UPDATE subclass_features SET consumes_resource_index_name = 'favored-by-the-gods'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_DIVINE_SOUL_FAVORED_BY_THE_GODS';

-- Unearthly Recovery (Divine Soul, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @sorcerer_id, 'Unearthly Recovery', 'unearthly-recovery-divine-soul',
       '1 use of Unearthly Recovery. Recovered on Long Rest.',
       '1', 'LONG_REST', 18, 'ID_WOTC_XGTE_SORCERER_ARCHETYPE_DIVINE_SOUL'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'unearthly-recovery-divine-soul');
UPDATE subclass_features SET consumes_resource_index_name = 'unearthly-recovery-divine-soul'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_DIVINE_SOUL_UNEARTHLY_RECOVERY';

-- Wind Soul (Storm Sorcery, SCAG): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @sorcerer_id, 'Wind Soul', 'wind-soul',
       '1 use of Wind Soul (reduced flying speed group grant). Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 18, 'ID_WOTC_SCAG_ARCHETYPE_STORM_SORCERY'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'wind-soul');
UPDATE subclass_features SET consumes_resource_index_name = 'wind-soul'
WHERE index_name = 'ID_WOTC_SCAG_ARCHETYPE_FEATURE_STORM_SORCERY_WIND_SOUL';

-- =====================================================================================
-- SECTION 11 -- Warlock (Aurora)
-- =====================================================================================

-- Healing Light (The Celestial, XGtE): pool of d6s equal to 1 + warlock level, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Healing Light', 'healing-light',
       'd6 pool equal to 1 + your warlock level. Recovered on Long Rest.',
       'one_plus_level', 'LONG_REST', 1, 'ID_WOTC_XGTE_ARCHETYPE_CELESTIAL'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'healing-light');
UPDATE subclass_features SET consumes_resource_index_name = 'healing-light'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_CELESTIAL_HEALING_LIGHT';

-- Searing Vengeance (The Celestial, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Searing Vengeance', 'searing-vengeance',
       '1 use of Searing Vengeance. Recovered on Long Rest.',
       '1', 'LONG_REST', 14, 'ID_WOTC_XGTE_ARCHETYPE_CELESTIAL'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'searing-vengeance');
UPDATE subclass_features SET consumes_resource_index_name = 'searing-vengeance'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_CELESTIAL_SEARING_VENGEANCE';

-- Tentacle of the Deeps (The Fathomless, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Tentacle of the Deeps', 'tentacle-of-the-deeps',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 1, 'ID_WOTC_TCOE_ARCHETYPE_WARLOCK_THE_FATHOMLESS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'tentacle-of-the-deeps');
UPDATE subclass_features SET consumes_resource_index_name = 'tentacle-of-the-deeps'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_THE_FATHOMLESS_TENTACLE_OF_THE_DEEPS';

-- Grasping Tentacles (The Fathomless, TCE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Grasping Tentacles', 'grasping-tentacles',
       '1 use of Grasping Tentacles (free cast of Evard''s black tentacles). Recovered on Long Rest.',
       '1', 'LONG_REST', 10, 'ID_WOTC_TCOE_ARCHETYPE_WARLOCK_THE_FATHOMLESS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'grasping-tentacles');
UPDATE subclass_features SET consumes_resource_index_name = 'grasping-tentacles'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_THE_FATHOMLESS_GRASPING_TENTACLES';

-- Fathomless Plunge (The Fathomless, TCE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Fathomless Plunge', 'fathomless-plunge',
       '1 use of Fathomless Plunge. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 14, 'ID_WOTC_TCOE_ARCHETYPE_WARLOCK_THE_FATHOMLESS'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'fathomless-plunge');
UPDATE subclass_features SET consumes_resource_index_name = 'fathomless-plunge'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_THE_FATHOMLESS_FATHOMLESS_PLUNGE';

-- Bottled Respite (The Genie, TCE): 1 use, Long Rest. (Narrative safe-room feature, low combat
-- value, but it does fit the "once you use X, can't again until long rest" shape.)
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Bottled Respite', 'bottled-respite',
       '1 use of Bottled Respite (entering your Genie''s Vessel). Recovered on Long Rest.',
       '1', 'LONG_REST', 1, 'ID_WOTC_TCOE_ARCHETYPE_WARLOCK_THE_GENIE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'bottled-respite');
UPDATE subclass_features SET consumes_resource_index_name = 'bottled-respite'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_THE_GENIE_GENIES_VESSEL';

-- Elemental Gift (The Genie, TCE): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Elemental Gift', 'elemental-gift',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 6, 'ID_WOTC_TCOE_ARCHETYPE_WARLOCK_THE_GENIE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'elemental-gift');
UPDATE subclass_features SET consumes_resource_index_name = 'elemental-gift'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_THE_GENIE_ELEMENTAL_GIFT';
-- NOTE: Limited Wish (level 14) is NOT included -- "can't use again until you finish 1d4 long
-- rests" is a random multi-rest recharge the current model can't express. See report.

-- Hexblade's Curse (The Hexblade, XGtE): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Hexblade''s Curse', 'hexblades-curse',
       '1 use of Hexblade''s Curse. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 1, 'ID_WOTC_XGTE_ARCHETYPE_HEXBLADE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'hexblades-curse');
UPDATE subclass_features SET consumes_resource_index_name = 'hexblades-curse'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_HEXBLADE_HEXBLADES_CURSE';

-- Accursed Specter (The Hexblade, XGtE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Accursed Specter', 'accursed-specter',
       '1 use of Accursed Specter. Recovered on Long Rest.',
       '1', 'LONG_REST', 6, 'ID_WOTC_XGTE_ARCHETYPE_HEXBLADE'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'accursed-specter');
UPDATE subclass_features SET consumes_resource_index_name = 'accursed-specter'
WHERE index_name = 'ID_WOTC_XGTE_ARCHETYPE_FEATURE_HEXBLADE_ACCURSED_SPECTER';

-- Form of Dread (The Undead, VRGtR): proficiency bonus uses, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Form of Dread', 'form-of-dread',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 1, 'ID_WOTC_VRGTR_ARCHETYPE_WARLOCK_THE_UNDEAD'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'form-of-dread');
UPDATE subclass_features SET consumes_resource_index_name = 'form-of-dread'
WHERE index_name = 'ID_WOTC_VRGTR_ARCHETYPE_FEATURE_WARLOCK_UNDEAD_FORM_OF_DREAD';
-- NOTE: Necrotic Husk (level 10) is NOT included -- same "1d4 long rests" recharge pattern as
-- Limited Wish above. See report.

-- Defy Death (The Undying, SCAG): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Defy Death', 'defy-death-undying',
       '1 use of Defy Death. Recovered on Long Rest.',
       '1', 'LONG_REST', 6, 'ID_WOTC_SCAG_ARCHETYPE_UNDYING'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'defy-death-undying');
UPDATE subclass_features SET consumes_resource_index_name = 'defy-death-undying'
WHERE index_name = 'ID_WOTC_SCAG_ARCHETYPE_FEATURE_UNDYING_DEFY_DEATH';

-- Indestructable Life (The Undying, SCAG): 1 use, Short or Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @warlock_id, 'Indestructable Life', 'indestructable-life',
       '1 use of Indestructable Life. Recovered on Short or Long Rest.',
       '1', 'SHORT_OR_LONG_REST', 14, 'ID_WOTC_SCAG_ARCHETYPE_UNDYING'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'indestructable-life');
UPDATE subclass_features SET consumes_resource_index_name = 'indestructable-life'
WHERE index_name = 'ID_WOTC_SCAG_ARCHETYPE_FEATURE_UNDYING_INDESTRUCTABLE_LIFE';

-- =====================================================================================
-- SECTION 12 -- Wizard (Aurora)
-- =====================================================================================

-- Bladesong (Bladesinging): reprinted SCAG + TCE -- two resources.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'Bladesong', 'bladesong-scag',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 2, 'ID_WOTC_SCAG_ARCHETYPE_BLADESINGING'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'bladesong-scag');
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'Bladesong', 'bladesong-tce',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 2, 'ID_WOTC_TCOE_ARCHETYPE_WIZARD_BLADESINGING'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'bladesong-tce');
UPDATE subclass_features SET consumes_resource_index_name = 'bladesong-scag'
WHERE index_name = 'ID_WOTC_SCAG_ARCHETYPE_FEATURE_BLADESINGING_BLADESONG';
UPDATE subclass_features SET consumes_resource_index_name = 'bladesong-tce'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_BLADESINGING_BLADESONG';

-- Chronal Shift (Chronurgy Magic, EGtW): 2 uses (fixed), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'Chronal Shift', 'chronal-shift',
       '2 uses of Chronal Shift. Recovered on Long Rest.',
       '2', 'LONG_REST', 2, 'ID_WOTC_EGTW_ARCHETYPE_WIZARD_CHRONURGY_MAGIC'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'chronal-shift');
UPDATE subclass_features SET consumes_resource_index_name = 'chronal-shift'
WHERE index_name = 'ID_WOTC_EGTW_ARCHETYPE_FEATURE_CHRONURGY_CHRONAL_SHIFT';

-- Momentary Stasis (Chronurgy Magic, EGtW): Intelligence modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'Momentary Stasis', 'momentary-stasis',
       'Uses equal to your Intelligence modifier (minimum 1). Recovered on Long Rest.',
       'intelligence_modifier_min1', 'LONG_REST', 6, 'ID_WOTC_EGTW_ARCHETYPE_WIZARD_CHRONURGY_MAGIC'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'momentary-stasis');
UPDATE subclass_features SET consumes_resource_index_name = 'momentary-stasis'
WHERE index_name = 'ID_WOTC_EGTW_ARCHETYPE_FEATURE_CHRONURGY_MOMENTARY_STASIS';

-- Violent Attraction (Graviturgy Magic, EGtW): Intelligence modifier (min 1), Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'Violent Attraction', 'violent-attraction',
       'Uses equal to your Intelligence modifier (minimum 1). Recovered on Long Rest.',
       'intelligence_modifier_min1', 'LONG_REST', 10, 'ID_WOTC_EGTW_ARCHETYPE_WIZARD_GRAVITURGY_MAGIC'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'violent-attraction');
UPDATE subclass_features SET consumes_resource_index_name = 'violent-attraction'
WHERE index_name = 'ID_WOTC_EGTW_ARCHETYPE_FEATURE_GRAVITURGY_VIOLENT_ATTRACTION';

-- Awakened Spellbook ritual-casting benefit (Order of Scribes, TCE): 1 use, Long Rest
-- (spell-slot alt-use not modeled).
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'Awakened Spellbook (Ritual Casting)', 'awakened-spellbook-ritual',
       '1 use of the Awakened Spellbook ritual-casting-time benefit. Recovered on Long Rest.',
       '1', 'LONG_REST', 2, 'ID_WOTC_TCOE_ARCHETYPE_WIZARD_ORDER_OF_SCRIBES'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'awakened-spellbook-ritual');
UPDATE subclass_features SET consumes_resource_index_name = 'awakened-spellbook-ritual'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_ORDER_OF_SCRIBES_AWAKENED_SPELLBOOK';

-- Manifest Mind (Order of Scribes, TCE): proficiency bonus uses, Long Rest (spell-slot alt-use
-- to reconjure the mind not modeled).
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'Manifest Mind', 'manifest-mind',
       'Uses equal to your proficiency bonus. Recovered on Long Rest.',
       'proficiency_bonus', 'LONG_REST', 6, 'ID_WOTC_TCOE_ARCHETYPE_WIZARD_ORDER_OF_SCRIBES'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'manifest-mind');
UPDATE subclass_features SET consumes_resource_index_name = 'manifest-mind'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_ORDER_OF_SCRIBES_MANIFEST_MIND';

-- One with the Word (Order of Scribes, TCE): 1 use, Long Rest.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @wizard_id, 'One with the Word', 'one-with-the-word',
       '1 use of One with the Word (damage-negation reaction). Recovered on Long Rest.',
       '1', 'LONG_REST', 14, 'ID_WOTC_TCOE_ARCHETYPE_WIZARD_ORDER_OF_SCRIBES'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'one-with-the-word');
UPDATE subclass_features SET consumes_resource_index_name = 'one-with-the-word'
WHERE index_name = 'ID_WOTC_TCOE_ARCHETYPE_FEATURE_ORDER_OF_SCRIBES_ONE_WITH_THE_WORD';

-- War Magic (XGtE): Power Surge and Arcane Deflection are DELIBERATELY NOT included here.
-- Power Surge resets to 1 (not to max) on a long rest and can also be gained mid-adventure by
-- landing a counterspell/dispel magic or ending a short rest empty -- none of that fits
-- recoverResources()'s "set current = max" behavior. Arcane Deflection is an at-will reaction
-- with a casting-restriction downside, not a use-limited resource. See report section 3.
