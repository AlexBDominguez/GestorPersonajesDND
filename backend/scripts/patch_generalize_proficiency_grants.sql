-- #8.2 GRANT_PROFICIENCY generalization: migrates the automatic (non-choice) proficiency
-- grants that used to live as hardcoded switch/if chains in RacialTraitService.java and
-- SubclassProficiencyService.java into two data-driven join tables (racial_trait_proficiencies,
-- subclass_proficiency_grants), plus the 2 remaining hardcoded racial spell grants
-- (natural-illusionist, drow-magic) into the already-existing racial_trait_spells table (which
-- Aurora-sourced traits already used via AuroraRaceMapper -- PHB traits never did until now).
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar. No toca ninguna fila existente.
SET NAMES utf8mb4;

-- ============================================================================================
-- Racial trait -> spell grants (PHB traits that were hardcoded; Aurora traits already use
-- this same table via AuroraRaceMapper, untouched here).
-- ============================================================================================

-- Forest Gnome: Natural Illusionist -> knows Minor Illusion from level 1.
INSERT INTO racial_trait_spells (racial_trait_id, spell_id, required_level)
SELECT rt.id, s.id, 1
FROM racial_traits rt, spells s
WHERE rt.index_name = 'natural-illusionist' AND s.index_api = 'minor-illusion'
  AND NOT EXISTS (
    SELECT 1 FROM racial_trait_spells x WHERE x.racial_trait_id = rt.id AND x.spell_id = s.id
  );

-- Drow: Drow Magic -> Dancing Lights (1st), Faerie Fire (3rd), Darkness (5th).
INSERT INTO racial_trait_spells (racial_trait_id, spell_id, required_level)
SELECT rt.id, s.id, 1
FROM racial_traits rt, spells s
WHERE rt.index_name = 'drow-magic' AND s.index_api = 'dancing-lights'
  AND NOT EXISTS (
    SELECT 1 FROM racial_trait_spells x WHERE x.racial_trait_id = rt.id AND x.spell_id = s.id
  );
INSERT INTO racial_trait_spells (racial_trait_id, spell_id, required_level)
SELECT rt.id, s.id, 3
FROM racial_traits rt, spells s
WHERE rt.index_name = 'drow-magic' AND s.index_api = 'faerie-fire'
  AND NOT EXISTS (
    SELECT 1 FROM racial_trait_spells x WHERE x.racial_trait_id = rt.id AND x.spell_id = s.id
  );
INSERT INTO racial_trait_spells (racial_trait_id, spell_id, required_level)
SELECT rt.id, s.id, 5
FROM racial_traits rt, spells s
WHERE rt.index_name = 'drow-magic' AND s.index_api = 'darkness'
  AND NOT EXISTS (
    SELECT 1 FROM racial_trait_spells x WHERE x.racial_trait_id = rt.id AND x.spell_id = s.id
  );

-- ============================================================================================
-- Racial trait -> proficiency grants (new table).
-- ============================================================================================

-- Mountain Dwarf: Dwarven Armor Training -> heavy armor.
INSERT INTO racial_trait_proficiencies (racial_trait_id, proficiency_id)
SELECT rt.id, p.id
FROM racial_traits rt, proficiencies p
WHERE rt.index_name = 'dwarven-armor-training' AND p.index_name = 'armor-heavy'
  AND NOT EXISTS (
    SELECT 1 FROM racial_trait_proficiencies x WHERE x.racial_trait_id = rt.id AND x.proficiency_id = p.id
  );

-- Drow: Drow Weapon Training -> rapier, shortsword, hand crossbow.
INSERT INTO racial_trait_proficiencies (racial_trait_id, proficiency_id)
SELECT rt.id, p.id
FROM racial_traits rt, proficiencies p
WHERE rt.index_name = 'drow-weapon-training' AND p.index_name = 'rapier'
  AND NOT EXISTS (
    SELECT 1 FROM racial_trait_proficiencies x WHERE x.racial_trait_id = rt.id AND x.proficiency_id = p.id
  );
INSERT INTO racial_trait_proficiencies (racial_trait_id, proficiency_id)
SELECT rt.id, p.id
FROM racial_traits rt, proficiencies p
WHERE rt.index_name = 'drow-weapon-training' AND p.index_name = 'shortswords'
  AND NOT EXISTS (
    SELECT 1 FROM racial_trait_proficiencies x WHERE x.racial_trait_id = rt.id AND x.proficiency_id = p.id
  );
INSERT INTO racial_trait_proficiencies (racial_trait_id, proficiency_id)
SELECT rt.id, p.id
FROM racial_traits rt, proficiencies p
WHERE rt.index_name = 'drow-weapon-training' AND p.index_name = 'hand-crossbow'
  AND NOT EXISTS (
    SELECT 1 FROM racial_trait_proficiencies x WHERE x.racial_trait_id = rt.id AND x.proficiency_id = p.id
  );

-- ============================================================================================
-- Subclass -> proficiency grants (new table). One row per (subclass_id, proficiency).
-- Helper pattern: INSERT ... SELECT s.id, p.id FROM subclasses s, proficiencies p WHERE
-- s.index_name = '...' AND p.index_name = '...' AND NOT EXISTS(...).
-- ============================================================================================

-- Tempest Domain (Cleric): heavy armor + martial weapons.
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'tempest-domain' AND p.index_name = 'armor-heavy'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'tempest-domain' AND p.index_name = 'weapons-martial'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);

-- War Domain (Cleric): heavy armor + martial weapons. BUG FIX: the old hardcoded condition was
-- `idx.equals("war") || idx.contains("oath-of-the-war")`, but the real index_name is
-- "war-domain" -- neither branch ever matched, so War Domain never actually got this grant.
-- Fixed here as part of migrating to data (see Aurora_Fixes.md #8.2).
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'war-domain' AND p.index_name = 'armor-heavy'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'war-domain' AND p.index_name = 'weapons-martial'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);

-- Nature Domain (Cleric): heavy armor.
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'nature-domain' AND p.index_name = 'armor-heavy'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);

-- College of Valor (Bard): medium armor + shields + martial weapons.
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'college-of-valor' AND p.index_name = 'armor-medium'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'college-of-valor' AND p.index_name = 'armor-shields'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'college-of-valor' AND p.index_name = 'weapons-martial'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);

-- Armorer (Artificer, TCE only): heavy armor.
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name = 'ID_WOTC_TCOE_ARCHETYPE_ARTIFICER_ARMORER' AND p.index_name = 'armor-heavy'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);

-- Battle Smith (Artificer, ERLW + TCE): martial weapons + smith's tools.
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name IN ('ID_WOTC_ERLW_ARCHETYPE_ARTIFICER_BATTLE_SMITH', 'ID_WOTC_TCOE_ARCHETYPE_ARTIFICER_BATTLE_SMITH')
  AND p.index_name = 'weapons-martial'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name IN ('ID_WOTC_ERLW_ARCHETYPE_ARTIFICER_BATTLE_SMITH', 'ID_WOTC_TCOE_ARCHETYPE_ARTIFICER_BATTLE_SMITH')
  AND p.index_name = 'smiths-tools'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);

-- Alchemist (Artificer, ERLW + TCE): alchemist's supplies.
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name IN ('ID_WOTC_ERLW_ARCHETYPE_ARTIFICER_ALCHEMIST', 'ID_WOTC_TCOE_ARCHETYPE_ARTIFICER_ALCHEMIST')
  AND p.index_name = 'alchemists-supplies'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);

-- Artillerist (Artificer, ERLW + TCE): woodcarver's tools.
INSERT INTO subclass_proficiency_grants (subclass_id, proficiency_id)
SELECT s.id, p.id FROM subclasses s, proficiencies p
WHERE s.index_name IN ('ID_WOTC_ERLW_ARCHETYPE_ARTIFICER_ARTILLERIST', 'ID_WOTC_TCOE_ARCHETYPE_ARTIFICER_ARTILLERIST')
  AND p.index_name = 'woodcarvers-tools'
  AND NOT EXISTS (SELECT 1 FROM subclass_proficiency_grants x WHERE x.subclass_id = s.id AND x.proficiency_id = p.id);
