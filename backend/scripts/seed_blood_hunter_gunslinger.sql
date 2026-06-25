-- Blood Hunter (clase completa) + Gunslinger (subclase de Fighter)
-- Autor: Matt Mercer (Critical Role). Fuente: dndbeyond.com
-- No tienen entrada en la D&D 5e API oficial ni en Aurora Legacy Elements.
--
-- Uso:
--   docker exec -i dnd-mysql mysql -u <MYSQL_USER> -p<MYSQL_PASSWORD> dnd_character_manager \
--     < backups/seed_blood_hunter_gunslinger.sql
--
-- Idempotente: usa INSERT IGNORE en la clase y ON DUPLICATE KEY para las features.
-- Ejecutar DESPUÉS de que el schema esté creado (mvn spring-boot:run al menos una vez).

SET NAMES utf8mb4;

-- ─────────────────────────────────────────────────────────────────────────────
-- BLOOD HUNTER — clase completa
-- ─────────────────────────────────────────────────────────────────────────────

INSERT IGNORE INTO classes
    (index_name, name, hit_die, spellcasting_ability, subclass_level,
     description, source, num_skill_choices)
VALUES (
    'blood-hunter',
    'Blood Hunter',
    10,
    NULL,
    3,
    'Blood Hunters are trained in a secret order that unites arcane scholarship with unnatural techniques, called hemocraft, which harnesses and corrupts their own life energy to fuel their abilities. They track and destroy those who stalk the dark, often at great personal cost — and sacrifice.',
    'CR',
    3
);

SET @bh_id = (SELECT id FROM classes WHERE index_name = 'blood-hunter');

-- Proficiencias de armadura y armas
INSERT IGNORE INTO class_proficiencies (class_id, proficiency) VALUES
(@bh_id, 'Light Armor'),
(@bh_id, 'Medium Armor'),
(@bh_id, 'Shields'),
(@bh_id, 'Simple Weapons'),
(@bh_id, 'Martial Weapons');

-- Tiradas de salvación
INSERT IGNORE INTO class_saving_throws (class_id, saving_throw) VALUES
(@bh_id, 'dex'),
(@bh_id, 'int');

-- Opciones de habilidades (elige 3 de estas 8)
INSERT IGNORE INTO class_skill_choices (class_id, skill_index) VALUES
(@bh_id, 'acrobatics'),
(@bh_id, 'arcana'),
(@bh_id, 'athletics'),
(@bh_id, 'history'),
(@bh_id, 'insight'),
(@bh_id, 'investigation'),
(@bh_id, 'religion'),
(@bh_id, 'survival');


-- ─────────────────────────────────────────────────────────────────────────────
-- BLOOD HUNTER — subclases (Órdenes)
-- ─────────────────────────────────────────────────────────────────────────────

INSERT IGNORE INTO subclasses
    (class_id, index_name, name, description, subclass_flavor, source)
VALUES
(@bh_id,
 'order-of-the-ghostslayer',
 'Order of the Ghostslayer',
 'The Order of the Ghostslayer is the oldest and most driven of all the orders, founded shortly after the first great victory against the undead during the Calamity. These blood hunters are possessed by a feverish determination to see the scourge of undeath undone at any cost.',
 'Blood Hunter Order',
 'CR'),

(@bh_id,
 'order-of-the-lycan',
 'Order of the Lycan',
 'Of the many terrible curses that plague the realm, few are as ancient or feared as lycanthropy. The Order of the Lycan is a proud group of blood hunters who have sworn to accept the curse in order to better understand it — and thereby to better combat the evils it creates.',
 'Blood Hunter Order',
 'CR'),

(@bh_id,
 'order-of-the-mutant',
 'Order of the Mutant',
 'Those who follow the Order of the Mutant seek to enhance their capabilities through an alchemically modified bloodstream. Using knowledge of the arcane sciences and mastery of alchemical theory, they push their bodies to extremes that most would consider monstrous.',
 'Blood Hunter Order',
 'CR'),

(@bh_id,
 'order-of-the-profane-soul',
 'Order of the Profane Soul',
 'Those who have taken to the Order of the Profane Soul have seen the limits of hemocraft against the evils that stalk the world. In response, they have turned to one of the greatest powers of the dark — that of the pact with a patron — and bent it to serve the cause of the light.',
 'Blood Hunter Order',
 'CR');


-- ─────────────────────────────────────────────────────────────────────────────
-- BLOOD HUNTER — features de subclase
-- ─────────────────────────────────────────────────────────────────────────────

-- Order of the Ghostslayer
SET @ghost_id = (SELECT id FROM subclasses WHERE index_name = 'order-of-the-ghostslayer');

INSERT IGNORE INTO subclass_features (subclass_id, index_name, name, level, description) VALUES
(@ghost_id,
 'ghostslayer-rite-of-the-dawn', 'Rite of the Dawn', 3,
 'You gain access to the Rite of the Dawn. When you activate your Rite of the Dawn, your weapon glows with a holy light. The strikes deal radiant damage instead of the rite''s normal damage type. When you hit an undead creature with your hemocraft weapon, that creature takes extra radiant damage equal to your proficiency bonus.'),

(@ghost_id,
 'ghostslayer-cursed-specters', 'Cursed Specters', 3,
 'When you slay an undead creature using your Rite of the Dawn, you can bind its spirit. It rises as a specter friendly to you and your companions, and remains under your control until the end of your next long rest. You may have at most one specter bound this way.'),

(@ghost_id,
 'ghostslayer-brand-of-sundering', 'Brand of Sundering', 7,
 'Your Brand of Castigation now expels the remnants of a creature''s spirit. Whenever a branded creature must make a saving throw to maintain concentration, it does so at disadvantage. While branded, aberrations, fiends, and undead have disadvantage on attack rolls against you.'),

(@ghost_id,
 'ghostslayer-blood-curse-of-the-exorcist', 'Blood Curse of the Exorcist', 11,
 'You gain the Blood Curse of the Exorcist for your blood maledict feature. This does not count against your number of blood curses known.'),

(@ghost_id,
 'ghostslayer-rite-of-the-dawn-upgrade', 'Rite of the Dawn (Upgrade)', 15,
 'The extra radiant damage from Rite of the Dawn now scales with twice your proficiency bonus. Undead have disadvantage on saving throws against your Blood Maledict features when your Rite of the Dawn is active.');


-- Order of the Lycan
SET @lycan_id = (SELECT id FROM subclasses WHERE index_name = 'order-of-the-lycan');

INSERT IGNORE INTO subclass_features (subclass_id, index_name, name, level, description) VALUES
(@lycan_id,
 'lycan-heightened-senses', 'Heightened Senses', 3,
 'You gain advantage on Wisdom (Perception) checks that rely on hearing or smell.'),

(@lycan_id,
 'lycan-hybrid-transformation', 'Hybrid Transformation', 3,
 'As a bonus action, you can transform into a hybrid lycanthropic form for up to 1 hour. While transformed you gain: Feral Might (+1 to Strength checks and saves, rising to +2 at 11th and +3 at 18th level), Predatory Strikes (claws that deal 1d6 + Strength modifier slashing damage), Pack Tactics (advantage on attacks if an ally is adjacent to the target), and Bloodlust (at the start of each of your turns while transformed and below half hit points, you must succeed on a DC 8 Wisdom save or move toward the nearest creature and attack it).'),

(@lycan_id,
 'lycan-stalkers-prowl', 'Stalker''s Prowl', 7,
 'While in your hybrid form, your movement speed increases by 10 feet, and you gain advantage on Dexterity (Stealth) checks.'),

(@lycan_id,
 'lycan-blood-curse-of-the-howl', 'Blood Curse of the Howl', 11,
 'You gain the Blood Curse of the Howl for your blood maledict feature. This does not count against your number of blood curses known.'),

(@lycan_id,
 'lycan-advanced-transformation', 'Advanced Transformation', 15,
 'Your hybrid form becomes more powerful. You gain advantage on all Strength-based attack rolls while transformed, and your Predatory Strikes now deal 2d6 slashing damage.');


-- Order of the Mutant
SET @mutant_id = (SELECT id FROM subclasses WHERE index_name = 'order-of-the-mutant');

INSERT IGNORE INTO subclass_features (subclass_id, index_name, name, level, description) VALUES
(@mutant_id,
 'mutant-formulas', 'Mutagen Formulas', 3,
 'You learn a number of mutagen formulas equal to your Intelligence modifier (minimum 1). Available formulas: Aether, Bloodlust, Celerity, Conversance, Cruelty, Deftness, Embers, Gelid, Impetus, Mobility, Psychedelic, Rapidity, Reconstruction, Sagacity, Sheen, Unbreakable. You craft a mutagen as a bonus action. You can have a number of mutagens active simultaneously equal to your proficiency bonus; activating beyond that causes older ones to end.'),

(@mutant_id,
 'mutant-strange-metabolism', 'Strange Metabolism', 7,
 'Your mutagenic experiments have given you resistance to poison. You have advantage on saving throws against poison damage and the poisoned condition.'),

(@mutant_id,
 'mutant-blood-curse-of-the-mutagenic-form', 'Blood Curse of the Mutagenic Form', 11,
 'You gain the Blood Curse of the Mutagenic Form for your blood maledict feature. This does not count against your number of blood curses known.'),

(@mutant_id,
 'mutant-exquisite-hemocraft', 'Exquisite Hemocraft', 15,
 'You can now maintain active mutagens equal to your Intelligence modifier at once. When you apply a mutagen to yourself, you may choose for its side effect not to apply until the next time you apply a new mutagen.');


-- Order of the Profane Soul
SET @profane_id = (SELECT id FROM subclasses WHERE index_name = 'order-of-the-profane-soul');

INSERT IGNORE INTO subclass_features (subclass_id, index_name, name, level, description) VALUES
(@profane_id,
 'profane-soul-otherworldly-patron', 'Otherworldly Patron', 3,
 'You forge a pact with an otherworldly patron. Choose from: Archfey, Fiend, Great Old One, Undying, Celestial, or Hexblade. You gain that patron''s expanded spell list and the feature it grants at Warlock level 1.'),

(@profane_id,
 'profane-soul-pact-magic', 'Pact Magic', 3,
 'You learn two Warlock cantrips of your choice. You gain one Pact Magic spell slot that you recover on a short or long rest, at a spell level equal to: 1st at BH levels 3–4; 2nd at 5–9; 3rd at 10–14; 4th at 15–18; 5th at 19–20. Your spellcasting ability for these spells is Charisma.'),

(@profane_id,
 'profane-soul-rite-focus', 'Rite Focus', 7,
 'Your eldritch power seeps into your hemocraft rites. You can use a weapon with an active crimson rite as a spellcasting focus for your Warlock spells. When you do, attacks with that weapon deal bonus necrotic damage equal to your Charisma modifier (minimum 1).'),

(@profane_id,
 'profane-soul-blood-curse-of-the-souleater', 'Blood Curse of the Souleater', 11,
 'You gain the Blood Curse of the Souleater for your blood maledict feature. This does not count against your number of blood curses known.'),

(@profane_id,
 'profane-soul-corrupted-hemorrhage', 'Corrupted Hemorrhage', 15,
 'When you use Brand of Castigation, you can force the branded creature to roll on the Short-Term Madness table (DMG p. 259) instead of taking psychic damage. The creature may attempt a Wisdom saving throw (DC 8 + proficiency bonus + Charisma modifier) to resist.');


-- ─────────────────────────────────────────────────────────────────────────────
-- GUNSLINGER — subclase del Fighter (Martial Archetype)
-- ─────────────────────────────────────────────────────────────────────────────

SET @fighter_id = (SELECT id FROM classes WHERE index_name = 'fighter');

INSERT IGNORE INTO subclasses
    (class_id, index_name, name, description, subclass_flavor, source)
VALUES (
    @fighter_id,
    'gunslinger',
    'Gunslinger',
    'Most warriors spend their years perfecting classic arts of swordplay or archery. Then the firearm came to be. The Gunslinger martial archetype combines pistol-craft and quick wit to outmaneuver any foe, learning trick shots and managing grit points that fuel daring feats of marksmanship.',
    'Martial Archetype',
    'CR'
);

SET @gunslinger_id = (SELECT id FROM subclasses WHERE index_name = 'gunslinger');

INSERT IGNORE INTO subclass_features (subclass_id, index_name, name, level, description) VALUES
(@gunslinger_id,
 'gunslinger-firearm-proficiency', 'Firearm Proficiency', 3,
 'You gain proficiency with firearms, adding your proficiency bonus to attack rolls. Firearms use special properties: Reload (fire up to the reload score before spending 1 attack or action to reload) and Misfire (rolling at or below the misfire score means the attack misses and the weapon cannot fire until repaired with a DC 8 + misfire score Tinker''s Tools check). Available firearms and their stats: Palm Pistol (1d8 piercing, 40/160 ft, light, reload 1, misfire 1); Pistol (1d10 piercing, 60/240 ft, reload 4, misfire 1); Musket (1d12 piercing, 120/480 ft, two-handed, reload 1, misfire 2); Pepperbox (1d10 piercing, 80/320 ft, reload 6, misfire 2); Blunderbuss (2d8 piercing, 15/60 ft, reload 1, misfire 2); Bad News (2d12 piercing, 200/800 ft, two-handed, reload 1, misfire 3); Hand Mortar (2d8 fire, 30/60 ft, reload 1, misfire 3, explosive — 5-ft radius DEX save DC 8 + prof + DEX or 1d8 fire).'),

(@gunslinger_id,
 'gunslinger-gunsmith', 'Gunsmith', 3,
 'You gain proficiency with Tinker''s Tools. You may use them to craft ammunition at half the standard cost, repair damaged or misfired firearms, or design new ones at the DM''s discretion.'),

(@gunslinger_id,
 'gunslinger-adept-marksman', 'Adept Marksman', 3,
 'You learn trick shots to disable or damage your opponents. Trick Shots Known: 2 at 3rd level, increasing to 3 (7th), 4 (10th), 5 (15th), and 6 (18th). Trick Shot DC = 8 + proficiency bonus + Dexterity modifier. Grit: You have grit points equal to your Wisdom modifier (minimum 1). Regain 1 grit on a natural 20 attack roll or on reducing a creature to 0 HP with a firearm. Regain all grit on a short or long rest. Available trick shots: Bullying Shot, Dazing Shot, Deadeye Shot, Disarming Shot, Forceful Shot, Piercing Shot, Violent Shot, Winging Shot.'),

(@gunslinger_id,
 'gunslinger-quickdraw', 'Quickdraw', 7,
 'You add your proficiency bonus to your initiative rolls. You can also stow a firearm and draw another firearm as a single object interaction on your turn.'),

(@gunslinger_id,
 'gunslinger-rapid-repair', 'Rapid Repair', 10,
 'You can spend 1 grit point to attempt to repair a misfired (but not destroyed) firearm as a bonus action.'),

(@gunslinger_id,
 'gunslinger-lightning-reload', 'Lightning Reload', 15,
 'You can reload any firearm as a bonus action.'),

(@gunslinger_id,
 'gunslinger-vicious-intent', 'Vicious Intent', 18,
 'Your firearm attacks score a critical hit on a roll of 19–20. You regain 1 grit point on a roll of 19–20.'),

(@gunslinger_id,
 'gunslinger-hemorrhaging-critical', 'Hemorrhaging Critical', 18,
 'When you score a critical hit with a firearm, the target additionally suffers half of the total damage dealt at the end of its next turn (no save).');
