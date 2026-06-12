-- Subclass features part 2: Monk, Paladin, Ranger, Rogue, Sorcerer, Warlock, Wizard
SET NAMES utf8mb4;

-- Way of Shadow (id=24)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(24,'shadow-shadow-arts','Shadow Arts',3,'You can spend 2 ki points to cast Darkness, Darkvision, Pass without Trace, or Silence, without providing material components.'),
(24,'shadow-shadow-step','Shadow Step',6,'When you are in dim light or darkness, as a bonus action you can teleport up to 60 ft to an unoccupied space you can see that is also in dim light or darkness. You then have advantage on the first melee attack you make before end of this turn.'),
(24,'shadow-cloak-of-shadows','Cloak of Shadows',11,'When you are in an area of dim light or darkness, you can use your action to become invisible. You remain invisible until you make an attack, cast a spell, or are in bright light.'),
(24,'shadow-opportunist','Opportunist',17,'When a creature within 5 ft of you is hit by an attack made by a creature other than you, you can use your reaction to make a melee attack against it.');

-- Way of the Four Elements (id=25)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(25,'4e-disciple-of-the-elements','Disciple of the Elements',3,'You learn magical disciplines that harness the power of the four elements. A discipline requires ki to use. You know the Elemental Attunement discipline plus two others of your choice (you learn more at levels 6, 11, 17). Disciplines include: Breath of Winter, Clench of the North Wind, Eternal Mountain Defense, Fangs of the Fire Snake, Fist of Four Thunders, Fist of Unbroken Air, Flames of the Phoenix, Gong of the Summit, Mist Stance, Ride the Wind, River of Hungry Flame, Rush of the Gale Spirits, Shape the Flowing River, Sweeping Cinder Strike, Water Whip, Wave of Rolling Earth.');

-- Oath of the Ancients (id=26)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(26,'ancients-channel-divinity-natures-wrath','Channel Divinity: Nature''s Wrath',3,'As an action, cause spectral vines to spring up around a creature within 10 ft. It must succeed on a Strength or Dexterity save (your choice) or be restrained until released or it succeeds on a save at end of its turn.'),
(26,'ancients-channel-divinity-turn-the-faithless','Channel Divinity: Turn the Faithless',3,'As an action, each fey or fiend within 30 ft must make a Wisdom save or be turned for 1 minute. A turned creature is exposed for what it is; a disguised creature''s disguise is dispelled.'),
(26,'ancients-aura-of-warding','Aura of Warding',7,'Ancient magic lies so heavily upon you that it forms an eldritch ward. You and friendly creatures within 10 ft (30 ft at level 18) have resistance to damage from spells.'),
(26,'ancients-undying-sentinel','Undying Sentinel',15,'When you are reduced to 0 hit points and not killed outright, you can choose to drop to 1 hit point instead. You can''t use this feature again until you finish a long rest. Also, you can''t be aged magically, though you can still die of old age.'),
(26,'ancients-elder-champion','Elder Champion',20,'As an action, you assume the form of an ancient force of nature for 1 minute. You regain 10 hp at the start of each turn, you can cast paladin spells as a bonus action, and enemies within 10 ft have disadvantage on saves against your paladin spells and Channel Divinity.');

-- Oath of Vengeance (id=27)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(27,'vengeance-channel-divinity-abjure-enemy','Channel Divinity: Abjure Enemy',3,'As an action, choose one creature within 60 ft. It makes a Wisdom save (fiends/undead have disadvantage). On fail: frightened and speed 0 for 1 minute or until it takes damage. On success: speed halved for the turn.'),
(27,'vengeance-channel-divinity-vow-of-enmity','Channel Divinity: Vow of Enmity',3,'As a bonus action, utter a vow of enmity against a creature within 10 ft. You gain advantage on attack rolls against it for 1 minute or until it drops to 0 hp or falls unconscious.'),
(27,'vengeance-relentless-avenger','Relentless Avenger',7,'Your supernatural focus helps you close off escapes. When you hit a creature with an opportunity attack, you can move up to half your speed immediately after the attack as part of the same reaction. This movement doesn''t provoke opportunity attacks.'),
(27,'vengeance-soul-of-vengeance','Soul of Vengeance',15,'The authority with which you speak your Vow of Enmity gives you greater power over your foe. When a creature under your Vow of Enmity makes an attack, you can use your reaction to make a melee weapon attack against it if it''s within range.'),
(27,'vengeance-avenging-angel','Avenging Angel',20,'You can assume the form of an angelic avenger for 1 hour. You sprout wings (flying speed 60 ft), and enemies within 30 ft who see you must make a Wisdom save (DC = paladin spell save DC) or be frightened for 1 minute.');

-- Beast Master (id=28)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(28,'beastmaster-ranger-s-companion','Ranger''s Companion',3,'You gain a beast companion that accompanies you on your adventures. Choose a beast with CR 1/4 or lower. It adds your proficiency bonus to its AC, attacks, and damage. It has hit points equal to its normal maximum or four times your ranger level, whichever is higher. It obeys your commands.'),
(28,'beastmaster-exceptional-training','Exceptional Training',7,'On any of your turns when your companion doesn''t attack, you can use a bonus action to command it to take the Dash, Disengage, Dodge, or Help action. The companion''s attacks count as magical.'),
(28,'beastmaster-bestial-fury','Bestial Fury',11,'Your companion can make two attacks when you command it to use the Attack action.'),
(28,'beastmaster-share-spells','Share Spells',15,'When you cast a spell targeting yourself, you can also affect your companion if the companion is within 30 ft.');

-- Assassin (id=29)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(29,'assassin-bonus-proficiencies','Bonus Proficiencies',3,'You gain proficiency with the disguise kit and the poisoner''s kit.'),
(29,'assassin-assassinate','Assassinate',3,'You are at your deadliest when you get the drop on your enemies. You have advantage on attack rolls against creatures that haven''t taken a turn in the combat yet. Any hit you score against a surprised creature is a critical hit.'),
(29,'assassin-infiltration-expertise','Infiltration Expertise',9,'You can unfailingly create false identities for yourself. You must spend 7 days and 25 gp to establish a false identity. You look, sound, and behave as a different person as long as you maintain the disguise.'),
(29,'assassin-impostor','Impostor',13,'You gain the ability to unerringly mimic another person''s speech, writing, and behavior. You must spend three hours studying the target, then perfectly imitate their speech, mannerisms, and writing.'),
(29,'assassin-death-strike','Death Strike',17,'When you attack and hit a creature that is surprised, it must make a Constitution save (DC = 8 + Dex mod + proficiency). On a failure, double the damage of your attack against the creature.');

-- Arcane Trickster (id=30)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(30,'at-spellcasting','Spellcasting',3,'You augment your roguish abilities with spells. Intelligence is your spellcasting ability. You learn spells from the wizard list, primarily enchantment and illusion.'),
(30,'at-mage-hand-legerdemain','Mage Hand Legerdemain',3,'When you cast Mage Hand, you can make the spectral hand invisible, and you can use it to stow or retrieve items from a container, use thieves'' tools, or pocket items — all without being noticed if you succeed on a Sleight of Hand check.'),
(30,'at-magical-ambush','Magical Ambush',9,'If you are hidden from a creature when you cast a spell on it, the creature has disadvantage on any saving throw it makes against the spell this turn.'),
(30,'at-versatile-trickster','Versatile Trickster',13,'You gain the ability to distract targets with your Mage Hand. As a bonus action, you can designate a creature within 5 ft of the spectral hand to be the target of your Mage Hand Legerdemain. Doing so gives you advantage on attack rolls against that creature until the end of the turn.'),
(30,'at-spell-thief','Spell Thief',17,'You gain the ability to magically steal the knowledge of how to cast a spell. Immediately after a creature casts a spell that targets you or includes you in its area, you can use your reaction to force the creature to make a saving throw using its spellcasting ability. On fail, you negate the spell''s effect on you and steal it, preventing the creature from casting it for 8 hours.');

-- Wild Magic (id=31)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(31,'wildmagic-wild-magic-surge','Wild Magic Surge',1,'Starting when you choose this origin at 1st level, your spellcasting can unleash surges of untamed magic. Immediately after you cast a sorcerer spell of 1st level or higher, the DM can have you roll a d20. On a 1, roll on the Wild Magic Surge table.'),
(31,'wildmagic-tides-of-chaos','Tides of Chaos',1,'You can manipulate the forces of chance and chaos to gain advantage on one attack roll, ability check, or saving throw. Once you do so, you must finish a long rest before you can use the feature again. The DM can also have you roll on the Wild Magic Surge table each time you cast a sorcerer spell until you lose this feature.'),
(31,'wildmagic-bend-luck','Bend Luck',6,'You have the ability to twist fate using your wild magic. When another creature you can see makes an attack roll, an ability check, or a saving throw, you can use your reaction and spend 2 sorcery points to roll 1d4 and apply the number rolled as a bonus or penalty to the creature''s roll.'),
(31,'wildmagic-controlled-chaos','Controlled Chaos',14,'You gain a modicum of control over the surges of your wild magic. Whenever you roll on the Wild Magic Surge table, you can roll twice and use either number.'),
(31,'wildmagic-spell-bombardment','Spell Bombardment',18,'The harmful energy of your spells intensifies. When you roll damage for a spell and roll the highest number possible on any of the dice, choose one of those dice, roll it again, and add that roll to the damage total.');

-- The Archfey (id=32)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(32,'archfey-fey-presence','Fey Presence',1,'Your patron bestows upon you the ability to project the fearsome presence of the fey. As an action, force each creature in a 10-ft cube originating from you to make a Wisdom save. On fail, it is charmed or frightened (your choice) until the end of your next turn. Once you use this feature, you can''t use it again until you finish a short or long rest.'),
(32,'archfey-misty-escape','Misty Escape',6,'When you take damage, you can use your reaction to turn invisible and teleport up to 60 ft to an unoccupied space you can see. You remain invisible until the start of your next turn or until you attack or cast a spell. Once you use this feature, you can''t use it again until you finish a short or long rest.'),
(32,'archfey-beguiling-defenses','Beguiling Defenses',10,'Your patron teaches you the art of subterfuge. You are immune to being charmed. When another creature attempts to charm you, you can use your reaction to attempt to turn the charm back on it.'),
(32,'archfey-dark-delirium','Dark Delirium',14,'You can plunge a creature into an illusory realm. As an action, choose a creature within 60 ft. It must make a Wisdom save or be charmed or frightened (your choice) for 1 minute or until it takes damage. While affected, it is incapacitated and its speed is 0. Once per short or long rest.');

-- The Great Old One (id=33)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(33,'goo-awakened-mind','Awakened Mind',1,'Your alien knowledge gives you the ability to touch the minds of other creatures. You can communicate telepathically with any creature you can see within 30 ft. The creature doesn''t need to share a language with you, but it must be able to understand at least one language.'),
(33,'goo-entropic-ward','Entropic Ward',6,'You learn to magically ward yourself against attack and to turn an enemy''s failed strike into good luck for yourself. When a creature makes an attack roll against you, you can use your reaction to impose disadvantage on that roll. If the attack misses you, your next attack roll against the creature has advantage. Once per short or long rest.'),
(33,'goo-thought-shield','Thought Shield',10,'Your thoughts can''t be read by telepathy or other means unless you allow it. Also, whenever a creature deals psychic damage to you, that creature takes the same amount of damage that you do.'),
(33,'goo-create-thrall','Create Thrall',14,'You gain the ability to infect a humanoid''s mind with the alien magic of your patron. You can use your action to touch an incapacitated humanoid. That creature is then charmed by you until a Remove Curse spell is cast on it, the charmed condition is removed in some other way, or you use this feature again.');

-- Wizard schools (ids 34-40)
-- School of Abjuration (id=34)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(34,'abj-abjuration-savant','Abjuration Savant',2,'The gold and time you must spend to copy an abjuration spell into your spellbook is halved.'),
(34,'abj-arcane-ward','Arcane Ward',2,'When you cast an abjuration spell of 1st level or higher, you can simultaneously use a strand of the spell''s magic to create a magical ward on yourself. The ward has hit points equal to twice your wizard level + Intelligence modifier. When you take damage, the ward takes the damage first; if reduced to 0 it disappears. You can replenish it by casting abjuration spells.'),
(34,'abj-projected-ward','Projected Ward',6,'When a creature you can see within 30 ft takes damage, you can use your reaction to cause your Arcane Ward to absorb that damage. If this damage reduces it to 0 hp, the warded creature takes any remaining damage.'),
(34,'abj-improved-abjuration','Improved Abjuration',10,'When you cast an abjuration spell that requires you to make an ability check as part of casting the spell, you add your proficiency bonus to that ability check.'),
(34,'abj-spell-resistance','Spell Resistance',14,'You have advantage on saving throws against spells. Furthermore, you have resistance against the damage of spells.');

-- School of Conjuration (id=35)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(35,'conj-conjuration-savant','Conjuration Savant',2,'The gold and time you must spend to copy a conjuration spell into your spellbook is halved.'),
(35,'conj-minor-conjuration','Minor Conjuration',2,'You can use your action to conjure up an inanimate object in your hand or on the ground within 10 ft. It can be no larger than 3 feet on a side and can weigh no more than 10 pounds. The object disappears after 1 hour, or sooner.'),
(35,'conj-benign-transposition','Benign Transposition',6,'You can use your action to teleport up to 30 ft to an unoccupied space you can see, or swap places with a willing Small or Medium creature within 30 ft. Once used, regain on a long rest or on casting a conjuration spell of 1st level or higher.'),
(35,'conj-focused-conjuration','Focused Conjuration',10,'While you are concentrating on a conjuration spell, your concentration can''t be broken as a result of taking damage.'),
(35,'conj-durable-summons','Durable Summons',14,'Whenever you summon or create a creature with a conjuration spell, it has 30 temporary hit points.');

-- School of Divination (id=36)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(36,'div-divination-savant','Divination Savant',2,'The gold and time you must spend to copy a divination spell into your spellbook is halved.'),
(36,'div-portent','Portent',2,'When you finish a long rest, roll two d20s and record the numbers. You can replace any attack roll, saving throw, or ability check made by you or a creature you can see with one of these foretelling rolls. You must choose before the roll, and each roll can be used once. You lose unused portent dice when you finish a long rest.'),
(36,'div-expert-divination','Expert Divination',6,'Casting divination spells comes so easily to you that it expends only a fraction of your spellcasting efforts. When you cast a divination spell of 2nd level or higher using a spell slot, you regain one expended spell slot; the slot must be of a level lower than the spell you cast and no higher than 5th level.'),
(36,'div-third-eye','The Third Eye',10,'You can use your action to increase your powers of perception as long as you are not incapacitated. Choose darkvision (60 ft), ethereal sight (see into the Ethereal Plane 60 ft), greater comprehension (read any language), or see invisibility (as per spell). Once a short or long rest.'),
(36,'div-greater-portent','Greater Portent',14,'The visions in your dreams intensify and paint a more accurate picture in your mind of what is to come. You roll three d20s for your Portent feature rather than two.');

-- School of Enchantment (id=37)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(37,'enc-enchantment-savant','Enchantment Savant',2,'The gold and time you must spend to copy an enchantment spell into your spellbook is halved.'),
(37,'enc-hypnotic-gaze','Hypnotic Gaze',2,'As an action, choose a creature within 5 ft. It must succeed on a Wisdom save or be charmed until the end of your next turn. Each turn you can use a bonus action to extend this for another round. If a target succeeds on its save, it is immune for 24 hours. Once per target per 24 hours (unlimited times per day).'),
(37,'enc-instinctive-charm','Instinctive Charm',6,'When a creature you can see within 30 ft makes an attack roll against you, you can react to divert the attack. The attacker must make a Wis save or redirect the attack to the nearest other creature. Once immune to being affected by it for 24 hours.'),
(37,'enc-split-enchantment','Split Enchantment',10,'When you cast an enchantment spell of 1st level or higher that targets only one creature, you can have it target a second creature.'),
(37,'enc-alter-memories','Alter Memories',14,'You gain the ability to make a creature unaware of your magical influence on it. When you cast an enchantment spell to charm one or more creatures, you can alter one target''s memory to remove its awareness that you cast a spell; it thinks the spell was a coincidence or benign interaction.');

-- School of Illusion (id=38)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(38,'ill-illusion-savant','Illusion Savant',2,'The gold and time you must spend to copy an illusion spell into your spellbook is halved.'),
(38,'ill-improved-minor-illusion','Improved Minor Illusion',2,'You learn the Minor Illusion cantrip. When you cast it, you can create both a sound and an image with a single casting.'),
(38,'ill-malleable-illusions','Malleable Illusions',6,'When you cast an illusion spell that has a duration of 1 minute or longer, you can use your action to change the nature of that illusion (using the spell''s normal parameters for the illusion), provided that you can see the illusion.'),
(38,'ill-illusory-self','Illusory Self',10,'You can create an illusory duplicate of yourself as an instant reaction to danger. When a creature makes an attack roll against you, you can use your reaction to interpose the illusory duplicate between the attacker and yourself. The attack automatically misses you, then the illusion dissipates. Once per short or long rest.'),
(38,'ill-illusory-reality','Illusory Reality',14,'You have learned the secret of weaving shadow magic into your illusions to give them a semi-reality. When you cast an illusion spell of 1st level or higher, you can choose one inanimate, nonmagical object that is part of the illusion and make that object real. The object can''t deal damage or otherwise harm anyone, and it disappears after 1 minute.');

-- School of Necromancy (id=39)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(39,'nec-necromancy-savant','Necromancy Savant',2,'The gold and time you must spend to copy a necromancy spell into your spellbook is halved.'),
(39,'nec-grim-harvest','Grim Harvest',2,'Once per turn when you kill one or more creatures with a spell, you regain hit points equal to twice the spell''s level (or three times if it is a necromancy spell). This does not apply if you kill a construct or undead.'),
(39,'nec-undead-thralls','Undead Thralls',6,'You add the Animate Dead spell to your spellbook. When you cast Animate Dead, you can target one additional corpse or pile of bones. Undead you create have their maximum HP increased by your wizard level, and add your proficiency bonus to weapon damage rolls.'),
(39,'nec-inured-to-undeath','Inured to Undeath',10,'You have resistance to necrotic damage, and your hit point maximum can''t be reduced. You have spent so much time dealing with undead that you have become inured to some of their worst effects.'),
(39,'nec-command-undead','Command Undead',14,'You can use magic to bring undead under your control. As an action, choose an undead you can see within 60 ft. It makes a Charisma save (DC = spell save DC). If it fails, it must obey your commands for 24 hours or until you use this feature again. An undead with Intelligence 8+ repeats the save every hour.');

-- School of Transmutation (id=40)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(40,'trans-transmutation-savant','Transmutation Savant',2,'The gold and time you must spend to copy a transmutation spell into your spellbook is halved.'),
(40,'trans-minor-alchemy','Minor Alchemy',2,'You can temporarily alter the physical properties of one nonmagical object, changing it from one substance into another. You perform a special alchemical procedure for 1 hour; the object must be Small or smaller. Each additional hour you spend extends the duration by 1 hour. Substances: wood, stone, iron, copper, silver.'),
(40,'trans-transmuters-stone','Transmuter''s Stone',6,'You can spend 8 hours creating a transmuter''s stone that stores transmutation magic. You can benefit from it yourself or give it to another creature. The bearer gains one of: darkvision 60 ft, extra 10 ft of speed, proficiency in Constitution saves, resistance to acid/cold/fire/lightning/thunder (choose when creating).'),
(40,'trans-shapechanger','Shapechanger',10,'You add the Polymorph spell to your spellbook. You can cast it targeting yourself without expending a spell slot. When you do so, you can transform only into a beast whose CR is 1 or lower.'),
(40,'trans-master-transmuter','Master Transmuter',14,'You can use your action to consume the reserve of transmutation magic in your Transmuter''s Stone to produce one of four effects: Major Transformation, Panacea (remove all curses, diseases, and poisons; restore HP to max for one creature), Restore Life (cast Raise Dead with no material cost), or Restore Youth (reduce one creature''s apparent age by 3d10 years).');
