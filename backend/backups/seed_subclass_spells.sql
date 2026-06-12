-- Subclass automatic spells: Cleric Domains and Paladin Oaths.
-- Uses INSERT IGNORE + JOIN so rows are silently skipped if the subclass or spell
-- is not yet in the DB (safe to run multiple times).
-- Spell index_api values come from the D&D 5e API (dnd5eapi.co).
-- required_level = character level at which the spell is unlocked.

-- ============================================================
-- CLERIC DOMAINS
-- ============================================================

-- Life Domain
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'bless'            WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'cure-wounds'      WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'lesser-restoration' WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'spiritual-weapon' WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'beacon-of-hope'   WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'revivify'         WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'death-ward'       WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'guardian-of-faith' WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'mass-cure-wounds' WHERE sc.index_name = 'life';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'raise-dead'       WHERE sc.index_name = 'life';

-- Knowledge Domain
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'command'          WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'identify'         WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'augury'           WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'suggestion'       WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'nondetection'     WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'speak-with-dead'  WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'arcane-eye'       WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'confusion'        WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'legend-lore'      WHERE sc.index_name = 'knowledge';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'scrying'          WHERE sc.index_name = 'knowledge';

-- Light Domain
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'burning-hands'    WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'faerie-fire'      WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'flaming-sphere'   WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'scorching-ray'    WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'daylight'         WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'fireball'         WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'guardian-of-faith' WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'wall-of-fire'     WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'flame-strike'     WHERE sc.index_name = 'light';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'scrying'          WHERE sc.index_name = 'light';

-- Nature Domain
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'animal-friendship' WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'speak-with-animals' WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'barkskin'         WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'spike-growth'     WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'plant-growth'     WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'wind-wall'        WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'dominate-beast'   WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'grasping-vine'    WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'insect-plague'    WHERE sc.index_name = 'nature';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'wall-of-stone'    WHERE sc.index_name = 'nature';

-- Tempest Domain
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'fog-cloud'        WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'thunderwave'      WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'gust-of-wind'     WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'shatter'          WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'call-lightning'   WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'sleet-storm'      WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'control-water'    WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'ice-storm'        WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'destructive-wave' WHERE sc.index_name = 'tempest';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'insect-plague'    WHERE sc.index_name = 'tempest';

-- Trickery Domain
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'charm-person'     WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'disguise-self'    WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'mirror-image'     WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'pass-without-trace' WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'blink'            WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'dispel-magic'     WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'dimension-door'   WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'polymorph'        WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'dominate-person'  WHERE sc.index_name = 'trickery';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'modify-memory'    WHERE sc.index_name = 'trickery';

-- War Domain
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'divine-favor'     WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 1 FROM subclasses sc JOIN spells sp ON sp.index_api = 'shield-of-faith'  WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'magic-weapon'     WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3 FROM subclasses sc JOIN spells sp ON sp.index_api = 'spiritual-weapon' WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'crusaders-mantle' WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5 FROM subclasses sc JOIN spells sp ON sp.index_api = 'spirit-guardians' WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'freedom-of-movement' WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 7 FROM subclasses sc JOIN spells sp ON sp.index_api = 'stoneskin'        WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'flame-strike'     WHERE sc.index_name = 'war';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9 FROM subclasses sc JOIN spells sp ON sp.index_api = 'hold-monster'     WHERE sc.index_name = 'war';

-- ============================================================
-- PALADIN OATHS
-- ============================================================

-- Oath of Devotion
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3  FROM subclasses sc JOIN spells sp ON sp.index_api = 'protection-from-evil-and-good' WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3  FROM subclasses sc JOIN spells sp ON sp.index_api = 'sanctuary'                     WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5  FROM subclasses sc JOIN spells sp ON sp.index_api = 'lesser-restoration'            WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5  FROM subclasses sc JOIN spells sp ON sp.index_api = 'zone-of-truth'                 WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9  FROM subclasses sc JOIN spells sp ON sp.index_api = 'beacon-of-hope'                WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9  FROM subclasses sc JOIN spells sp ON sp.index_api = 'dispel-magic'                  WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 13 FROM subclasses sc JOIN spells sp ON sp.index_api = 'freedom-of-movement'           WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 13 FROM subclasses sc JOIN spells sp ON sp.index_api = 'guardian-of-faith'             WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 17 FROM subclasses sc JOIN spells sp ON sp.index_api = 'commune'                       WHERE sc.index_name = 'devotion';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 17 FROM subclasses sc JOIN spells sp ON sp.index_api = 'flame-strike'                  WHERE sc.index_name = 'devotion';

-- Oath of the Ancients
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3  FROM subclasses sc JOIN spells sp ON sp.index_api = 'ensnaring-strike'   WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3  FROM subclasses sc JOIN spells sp ON sp.index_api = 'speak-with-animals' WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5  FROM subclasses sc JOIN spells sp ON sp.index_api = 'misty-step'         WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5  FROM subclasses sc JOIN spells sp ON sp.index_api = 'moonbeam'           WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9  FROM subclasses sc JOIN spells sp ON sp.index_api = 'plant-growth'       WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9  FROM subclasses sc JOIN spells sp ON sp.index_api = 'protection-from-energy' WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 13 FROM subclasses sc JOIN spells sp ON sp.index_api = 'ice-storm'          WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 13 FROM subclasses sc JOIN spells sp ON sp.index_api = 'stoneskin'          WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 17 FROM subclasses sc JOIN spells sp ON sp.index_api = 'commune-with-nature' WHERE sc.index_name = 'ancients';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 17 FROM subclasses sc JOIN spells sp ON sp.index_api = 'tree-stride'        WHERE sc.index_name = 'ancients';

-- Oath of Vengeance
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3  FROM subclasses sc JOIN spells sp ON sp.index_api = 'bane'                   WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 3  FROM subclasses sc JOIN spells sp ON sp.index_api = 'hunters-mark'           WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5  FROM subclasses sc JOIN spells sp ON sp.index_api = 'hold-person'            WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 5  FROM subclasses sc JOIN spells sp ON sp.index_api = 'misty-step'             WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9  FROM subclasses sc JOIN spells sp ON sp.index_api = 'haste'                  WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 9  FROM subclasses sc JOIN spells sp ON sp.index_api = 'protection-from-energy' WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 13 FROM subclasses sc JOIN spells sp ON sp.index_api = 'banishment'             WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 13 FROM subclasses sc JOIN spells sp ON sp.index_api = 'dimension-door'         WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 17 FROM subclasses sc JOIN spells sp ON sp.index_api = 'hold-monster'           WHERE sc.index_name = 'vengeance';
INSERT IGNORE INTO subclass_spells (subclass_id, spell_id, required_level)
SELECT sc.id, sp.id, 17 FROM subclasses sc JOIN spells sp ON sp.index_api = 'scrying'                WHERE sc.index_name = 'vengeance';
