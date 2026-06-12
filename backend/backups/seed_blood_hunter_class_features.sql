-- Blood Hunter class features (Matt Mercer / Critical Role)
-- Ejecutar DESPUÉS de seed_blood_hunter_gunslinger.sql
-- Idempotente: cada INSERT comprueba que el index_name no existe ya para esa clase.
SET NAMES utf8mb4;

SET @bh_id = (SELECT id FROM classes WHERE index_name = 'blood-hunter');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-hunters-bane', 'Hunter''s Bane', 1,
 'Beginning at 1st level, you have survived the Hunter''s Bane — a dangerous, long-guarded ritual that alters your life''s blood, forever binding you to the darkness. You have advantage on Wisdom (Survival) checks to track fey, fiends, and undead, as well as on Intelligence checks to recall information about them.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-hunters-bane');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-blood-maledict', 'Blood Maledict', 1,
 'At 1st level, you gain the ability to channel, and curse, the blood of your enemies. You know one Blood Curse of your choice. You learn one additional Blood Curse at 6th, 10th, 14th, and 18th level.\nAs a bonus action, you can expend one use of your Blood Maledict to activate a Blood Curse (target within 30 feet). You have a number of uses equal to your proficiency bonus, and regain all uses on a long rest. Amplifying a curse costs an additional use.\nBlood Curses available: Blood Curse of Binding, Bloated Agony, Corrosion, Exposure, the Eyeless, Purgation, the Fallen Puppet, and the Marked.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-blood-maledict');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-fighting-style', 'Fighting Style', 2,
 'At 2nd level, you adopt a style of fighting as your specialty. Choose one of the following:\n\nArchery: +2 bonus to attack rolls with ranged weapons.\nDefense: +1 bonus to AC while wearing armor.\nDueling: +2 bonus to damage rolls when wielding a melee weapon in one hand and no other weapons.\nTwo-Weapon Fighting: You can add your ability modifier to the damage of the off-hand attack.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-fighting-style');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-crimson-rite', 'Crimson Rite', 2,
 'At 2nd level, you learn to invoke a rite of hemocraft that infuses your weapon strikes with elemental energy. You can activate a Crimson Rite on one held weapon as part of your Attack action (no extra action required).\nChoose a rite: Rite of the Flame (fire), Rite of the Frozen (cold), or Rite of the Storm (lightning). At 14th level you also unlock: Rite of the Dead (necrotic), Rite of the Oracle (psychic), Rite of the Roar (thunder).\nWhile a rite is active, your weapon deals bonus damage equal to 1d4 of the rite''s type (1d6 at 11th level). Activating the rite deals psychic damage to you equal to one roll of the rite die; this damage cannot be reduced or ignored.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-crimson-rite');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-extra-attack', 'Extra Attack', 5,
 'Beginning at 5th level, you can attack twice, instead of once, whenever you take the Attack action on your turn.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-extra-attack');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-brand-of-castigation', 'Brand of Castigation', 6,
 'At 6th level, when you damage a creature with your Crimson Rite, you can brand it. The brand lasts until you dismiss it, the creature dies, you die, or you use this feature again. While branded: you and the creature cannot surprise each other, and you always know its location if you''re on the same plane.\nWhen the branded creature makes an attack roll, ability check, or saving throw, you can use your reaction to impose disadvantage on that roll. Once you use this reaction, you must finish a short or long rest before using it again.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-brand-of-castigation');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-grim-psychometry', 'Grim Psychometry', 9,
 'At 9th level, your connection to dark knowledge deepens. When you make an Intelligence (History) check related to the origin of a magical item, you have advantage. If you have handled the item, the DM may reveal additional details such as impressions, short visions, or surface emotions left by previous users.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-grim-psychometry');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-dark-augmentation', 'Dark Augmentation', 10,
 'At 10th level, the corruption within your blood transforms you. Your speed increases by 5 feet. You gain darkvision out to 60 feet; if you already have darkvision its range increases by 30 feet. You also have advantage on saving throws against being frightened.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-dark-augmentation');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-brand-of-tethering', 'Brand of Tethering', 13,
 'At 13th level, the power of your Brand of Castigation deepens. When a branded creature attempts to teleport or move to a different plane, it takes 4d6 psychic damage and must succeed on a Wisdom saving throw (DC 8 + your proficiency bonus + your Intelligence modifier) or the attempt fails.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-brand-of-tethering');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-hardened-soul', 'Hardened Soul', 14,
 'At 14th level, you become resilient against the effects of your own hemocraft. You have resistance to necrotic damage and immunity to the frightened condition.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-hardened-soul');

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-sanguine-mastery', 'Sanguine Mastery', 20,
 'At 20th level, you become the ultimate master of hemocraft. When you amplify a Blood Curse, you don''t pay the extra use. Additionally, when you score a critical hit with a Crimson Rite weapon, the target must succeed on a Constitution saving throw (DC 8 + your proficiency bonus + your Intelligence modifier) or become stunned until the end of your next turn.'
WHERE NOT EXISTS (SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-sanguine-mastery');
