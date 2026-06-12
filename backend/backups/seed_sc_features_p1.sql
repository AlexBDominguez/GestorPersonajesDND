-- Subclass features part 1: Barbarian, Bard, Cleric, Druid, Fighter
-- Uses subclass id values from DB (13-22 for new ones; existing: Berserker=1,Lore=10,Life=9,Land=8,Champion=2)
SET NAMES utf8mb4;

-- ── Existing subclasses that have 0 features ────────────────────────────────

-- Berserker (id=1)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(1,'berserker-frenzy','Frenzy',3,'When you rage, you can go into a frenzy. While frenzied you can make a single melee weapon attack as a bonus action on each of your turns after this one. When your rage ends, you suffer one level of exhaustion.'),
(1,'berserker-mindless-rage','Mindless Rage',6,'You can''t be charmed or frightened while raging. If you are charmed or frightened when you enter a rage, the effect is suspended for the duration of the rage.'),
(1,'berserker-intimidating-presence','Intimidating Presence',10,'You can use your action to frighten someone with your menacing presence. Choose one creature within 30 feet. It must succeed on a Wisdom save (DC = 8 + proficiency bonus + Charisma modifier) or be frightened until the end of your next turn.'),
(1,'berserker-retaliation','Retaliation',14,'When you take damage from a creature within 5 feet, you can use your reaction to make a melee weapon attack against it.');

-- Champion (id=2)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(2,'champion-improved-critical','Improved Critical',3,'Your weapon attacks score a critical hit on a roll of 19 or 20.'),
(2,'champion-remarkable-athlete','Remarkable Athlete',7,'You can add half your proficiency bonus (rounded up) to any Strength, Dexterity, or Constitution check that doesn''t already use your proficiency bonus. Also, your jump distance increases by a number of feet equal to your Strength modifier.'),
(2,'champion-additional-fighting-style','Additional Fighting Style',10,'You can choose a second option from the Fighting Style class feature.'),
(2,'champion-superior-critical','Superior Critical',15,'Your weapon attacks score a critical hit on a roll of 18–20.'),
(2,'champion-survivor','Survivor',18,'You attain the pinnacle of resilience in battle. At the start of each of your turns, you regain hit points equal to 5 + your Constitution modifier if you have no more than half of your hit points left. You don''t gain this benefit if you have 0 hit points.');

-- Devotion (id=3) -- Paladin: Oath of Devotion
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(3,'devotion-sacred-weapon','Sacred Weapon',3,'As an action, you can imbue one weapon you are holding with positive energy. For 1 minute, add your Charisma modifier to attack rolls with it; it emits bright light (20 ft) and dim light (20 ft more). You can end it early as a bonus action.'),
(3,'devotion-turn-the-unholy','Turn the Unholy',3,'As an action, each fiend or undead within 30 ft must make a Wisdom save or be turned for 1 minute (frightened and must move away, can''t take reactions near you).'),
(3,'devotion-aura-of-devotion','Aura of Devotion',7,'You and friendly creatures within 10 ft (30 ft at level 18) can''t be charmed while you are conscious.'),
(3,'devotion-purity-of-spirit','Purity of Spirit',15,'You are always under the protection of the Protection from Evil and Good spell.'),
(3,'devotion-holy-nimbus','Holy Nimbus',20,'As an action, emanate an aura of sunlight for 1 minute (60-ft radius). Enemies in it take 10 radiant damage at the start of each turn. You have advantage on saves against fiends and undead; they have disadvantage on attacks against you.');

-- Draconic (id=4) -- already has features from API sync, skip

-- Evocation (id=5)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(5,'evocation-evocation-savant','Evocation Savant',2,'The gold and time you must spend to copy an evocation spell into your spellbook is halved.'),
(5,'evocation-sculpt-spells','Sculpt Spells',2,'When you cast an evocation spell that affects other creatures you can see, you can choose a number of them equal to 1 + the spell''s level to succeed automatically on their saving throw. They take no damage if they would normally take half damage on a success.'),
(5,'evocation-potent-cantrip','Potent Cantrip',6,'Your damaging cantrips affect even creatures that avoid the brunt of the effect. When a creature succeeds on a saving throw against your cantrip, it takes half damage (if the cantrip normally deals no damage on a success).'),
(5,'evocation-empowered-evocation','Empowered Evocation',10,'You can add your Intelligence modifier to one damage roll of any wizard evocation spell you cast.'),
(5,'evocation-overchannel','Overchannel',14,'When you cast a wizard spell of 5th level or lower that deals damage, you can deal maximum damage with that spell. The first time you do so, you suffer no ill effect. If you do so again before finishing a long rest, you take 2d12 necrotic damage per spell level above 1st (no save).');

-- Fiend (id=6) -- already has features from API sync, skip

-- Hunter (id=7) -- has no features from API, but VM hardcodes choices; add informational features
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(7,'hunter-hunters-prey','Hunter''s Prey',3,'Choose one: Colossus Slayer (extra 1d8 once/turn vs. damaged foe), Giant Killer (reaction attack when Large+ creature misses you), or Horde Breaker (extra attack against creature adjacent to first target).'),
(7,'hunter-defensive-tactics','Defensive Tactics',7,'Choose one: Escape the Horde (opportunity attacks against you have disadvantage), Multiattack Defense (+4 AC against subsequent attacks after being hit), or Steel Will (advantage on saves vs. frightened).'),
(7,'hunter-multiattack','Multiattack',11,'Choose one: Volley (ranged attack against all creatures within 10 ft of a point) or Whirlwind Attack (melee attack against all creatures within 5 ft of you).'),
(7,'hunter-superior-hunters-defense','Superior Hunter''s Defense',15,'Choose one: Evasion (no damage on successful Dex save), Stand Against the Tide (redirect enemy''s missed attack to another creature), or Uncanny Dodge (use reaction to halve attack damage).');

-- Land (id=8) -- Circle of the Land
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(8,'land-bonus-cantrip','Bonus Cantrip',2,'You learn one additional druid cantrip of your choice.'),
(8,'land-natural-recovery','Natural Recovery',2,'Once per day during a short rest, you can recover expended spell slots with a total level no higher than half your druid level (rounded up), and none of the slots can be 6th level or higher.'),
(8,'land-circle-spells','Circle Spells',3,'Your mystical connection to the land infuses you with the ability to cast certain spells. At 3rd, 5th, 7th, and 9th level you gain access to circle spells determined by your chosen land type (Arctic, Coast, Desert, Forest, Grassland, Mountain, Swamp, or Underdark).'),
(8,'land-lands-stride','Land''s Stride',6,'Moving through nonmagical difficult terrain costs you no extra movement. You can also pass through nonmagical plants without being slowed by them. You have advantage on saves against plants magically created or manipulated.'),
(8,'land-natures-ward','Nature''s Ward',10,'You can''t be charmed or frightened by elementals or fey, and you are immune to poison and disease.'),
(8,'land-natures-sanctuary','Nature''s Sanctuary',14,'Creatures of the natural world (beasts and plants) sense your connection to nature. A beast or plant creature that attacks you must make a Wisdom saving throw (DC = 8 + proficiency bonus + Wisdom modifier). On a failed save, it must choose a different target.');

-- Life (id=9) -- has some features from API, add the rest
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(9,'life-blessed-healer','Blessed Healer',6,'The healing spells you cast on others heal you as well. When you cast a spell of 1st level or higher that restores hit points to another creature, you regain hit points equal to 2 + the spell''s level.'),
(9,'life-divine-strike','Divine Strike',8,'Once per turn, when you hit a creature with a weapon attack, you can cause the attack to deal an extra 1d8 radiant damage (2d8 at level 14).'),
(9,'life-supreme-healing','Supreme Healing',17,'When you would normally roll one or more dice to restore hit points with a spell, you instead use the highest number possible for each die.');

-- Lore (id=10)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(10,'lore-bonus-proficiencies','Bonus Proficiencies',3,'You gain proficiency with three skills of your choice.'),
(10,'lore-cutting-words','Cutting Words',3,'When a creature you can see within 60 ft makes an attack roll, ability check, or damage roll, you can use your reaction and expend a Bardic Inspiration die to subtract the roll from its total.'),
(10,'lore-additional-magical-secrets','Additional Magical Secrets',6,'You learn two spells of your choice from any class. These count as bard spells but don''t count against your spells known.'),
(10,'lore-peerless-skill','Peerless Skill',14,'When you make an ability check, you can expend one use of Bardic Inspiration to add the die roll to your check. You can do so after rolling the check but before learning if it succeeds or fails.');

-- Open Hand (id=11)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(11,'openhand-open-hand-technique','Open Hand Technique',3,'Whenever you hit a creature with one of the attacks granted by Flurry of Blows, you can impose one of three effects: knock prone (Dex save), push back 15 ft (Str save), or deny reactions until end of your next turn.'),
(11,'openhand-wholeness-of-body','Wholeness of Body',6,'You gain the ability to heal yourself. As an action, you regain hit points equal to three times your monk level. You must finish a long rest before you can use this feature again.'),
(11,'openhand-tranquility','Tranquility',11,'You can enter a special meditation at the end of a long rest that grants you the benefit of a Sanctuary spell until the start of your next rest (Wis save DC = 8 + proficiency bonus + Wisdom modifier).'),
(11,'openhand-quivering-palm','Quivering Palm',17,'You gain the ability to set up lethal vibrations in someone''s body. When you hit a creature with an unarmed strike, you can spend 3 ki points to start imperceptible vibrations. These last for a number of days equal to your monk level. As an action, you can end the vibrations, forcing a Con save (DC = ki save DC) or drop to 0 hp, or half the creature''s HP on success.');

-- Thief (id=12)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(12,'thief-fast-hands','Fast Hands',3,'You can use the bonus action granted by your Cunning Action to make a Dexterity (Sleight of Hand) check, use your thieves'' tools to disarm a trap or open a lock, or take the Use an Object action.'),
(12,'thief-second-story-work','Second-Story Work',3,'You gain the ability to climb faster than normal; climbing no longer costs you extra movement. Also, when you make a running jump, the distance you cover increases by a number of feet equal to your Dexterity modifier.'),
(12,'thief-supreme-sneak','Supreme Sneak',9,'You have advantage on a Dexterity (Stealth) check if you move no more than half your speed on the same turn.'),
(12,'thief-use-magic-device','Use Magic Device',13,'You have learned enough about the workings of magic that you can improvise the use of items even when they are not intended for you. You ignore all class, race, and level requirements on the use of magic items.'),
(12,'thief-thiefs-reflexes','Thief''s Reflexes',17,'You have become adept at laying ambushes and quickly escaping danger. You can take two turns during the first round of any combat. You take your first turn at your normal initiative and your second turn at your initiative minus 10.');

-- ── New subclasses ───────────────────────────────────────────────────────────

-- Path of the Totem Warrior (id=13)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(13,'totem-spirit-seeker','Spirit Seeker',3,'Yours is a path that seeks attunement with the natural world, giving you a kinship with beasts. You gain the ability to cast Beast Sense and Speak with Animals as rituals.'),
(13,'totem-warrior-totem-spirit','Totem Spirit',3,'Choose a totem spirit: Bear (resistance to all damage except psychic while raging), Eagle (Dash as bonus action while raging, opportunity attacks against you have disadvantage except from creatures you attack), or Wolf (your allies have advantage on melee attacks against enemies adjacent to you).'),
(13,'totem-warrior-aspect-of-the-beast','Aspect of the Beast',6,'Choose a totem: Bear (carry twice the normal amount, and weight you can push/drag/lift is doubled), Eagle (see up to 1 mile sharply, dim light doesn''t impose disadvantage on Perception), or Wolf (track by scent, know which creatures have been in an area within the past day).'),
(13,'totem-warrior-spirit-walker','Spirit Walker',10,'You can cast the Commune with Nature spell as a ritual.'),
(13,'totem-warrior-totemic-attunement','Totemic Attunement',14,'Choose a totem: Bear (frightened enemies within 5 ft have disadvantage on attacks not against you), Eagle (fly speed equal to your walking speed while raging), or Wolf (knock a Large or smaller enemy prone when you hit with a melee attack while raging).');

-- College of Valor (id=14)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(14,'valor-bonus-proficiencies','Bonus Proficiencies',3,'You gain proficiency with medium armor, shields, and martial weapons.'),
(14,'valor-combat-inspiration','Combat Inspiration',3,'A creature that has a Bardic Inspiration die from you can roll it and add it to a weapon damage roll, or roll it as a reaction when attacked to add it to their AC for that attack.'),
(14,'valor-extra-attack','Extra Attack',6,'You can attack twice, instead of once, whenever you take the Attack action on your turn.'),
(14,'valor-battle-magic','Battle Magic',14,'When you use your action to cast a bard spell, you can make one weapon attack as a bonus action.');

-- Knowledge Domain (id=15)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(15,'knowledge-blessings-of-knowledge','Blessings of Knowledge',1,'You learn two languages of your choice. You also become proficient in your choice of two of the following skills: Arcana, History, Nature, or Religion. Your proficiency bonus is doubled for those skills.'),
(15,'knowledge-channel-divinity-knowledge-of-the-ages','Channel Divinity: Knowledge of the Ages',2,'As an action, you choose one skill or tool. For 10 minutes, you have proficiency with the chosen skill or tool.'),
(15,'knowledge-channel-divinity-read-thoughts','Channel Divinity: Read Thoughts',2,'As an action, choose one creature within 60 ft. The creature must make a Wisdom save. On failure, you read its surface thoughts for 1 minute. You can use your action to end this effect and cast Suggestion on the creature (no save).'),
(15,'knowledge-potent-spellcasting','Potent Spellcasting',8,'You add your Wisdom modifier to the damage you deal with any cleric cantrip.'),
(15,'knowledge-visions-of-the-past','Visions of the Past',17,'You can call up visions of the recent past related to an object you hold or your immediate surroundings by spending 1 minute in meditation. The DM chooses the details revealed.');

-- Light Domain (id=16)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(16,'light-warding-flare','Warding Flare',1,'When a creature attacks you or a creature within 30 ft that you can see, you can impose disadvantage on the attack by interposing divine light. You can use this feature a number of times equal to your Wisdom modifier per long rest.'),
(16,'light-channel-divinity-radiance-of-the-dawn','Channel Divinity: Radiance of the Dawn',2,'As an action, present your holy symbol, dispelling magical darkness within 30 ft. Each hostile creature within 30 ft must make a Constitution save or take 2d10 + cleric level radiant damage (half on success).'),
(16,'light-improved-flare','Improved Flare',6,'You can use your Warding Flare to protect any creature you can see within 30 ft, not just yourself.'),
(16,'light-potent-spellcasting','Potent Spellcasting',8,'You add your Wisdom modifier to the damage you deal with any cleric cantrip.'),
(16,'light-corona-of-light','Corona of Light',17,'As an action, activate an aura of sunlight for 1 minute (60-ft radius bright light, 30-ft dim). Enemies in the bright light have disadvantage on saves against spells that deal fire or radiant damage.');

-- Nature Domain (id=17)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(17,'nature-acolyte-of-nature','Acolyte of Nature',1,'You learn one druid cantrip of your choice. You also gain proficiency in one of: Animal Handling, Nature, or Survival.'),
(17,'nature-bonus-proficiency','Bonus Proficiency',1,'You gain proficiency with heavy armor.'),
(17,'nature-channel-divinity-charm-animals-and-plants','Channel Divinity: Charm Animals and Plants',2,'As an action, present your holy symbol and invoke the name of your deity. Each beast or plant creature within 30 ft must make a Wisdom save or be charmed for 1 minute or until it takes damage.'),
(17,'nature-dampen-elements','Dampen Elements',6,'When you or an ally within 30 ft takes acid, cold, fire, lightning, or thunder damage, you can use your reaction to grant resistance to that instance.'),
(17,'nature-divine-strike','Divine Strike',8,'Once per turn on a hit, deal an extra 1d8 cold, fire, or lightning damage (your choice when you gain this feature). 2d8 at level 14.'),
(17,'nature-master-of-nature','Master of Nature',17,'You gain the ability to command animals and plant creatures. While they are charmed by your Charm Animals and Plants feature, you can take a bonus action to verbally direct them.');

-- Tempest Domain (id=18)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(18,'tempest-bonus-proficiencies','Bonus Proficiencies',1,'You gain proficiency with martial weapons and heavy armor.'),
(18,'tempest-wrath-of-the-storm','Wrath of the Storm',1,'When a creature within 5 ft of you hits you with an attack, you can use your reaction to cause it to make a Dex save (DC = 8 + proficiency + Wis mod) or take 2d8 lightning/thunder damage (half on success). Uses = Wisdom modifier per long rest.'),
(18,'tempest-channel-divinity-destructive-wrath','Channel Divinity: Destructive Wrath',2,'When you roll lightning or thunder damage, you can use Channel Divinity to deal maximum damage instead of rolling.'),
(18,'tempest-thunderbolt-strike','Thunderbolt Strike',6,'When you deal lightning damage to a Large or smaller creature, you can push it up to 10 feet away.'),
(18,'tempest-divine-strike','Divine Strike',8,'Once per turn on a hit, deal an extra 1d8 thunder damage (2d8 at level 14).'),
(18,'tempest-stormborn','Stormborn',17,'You have a flying speed equal to your current walking speed whenever you are not underground or indoors.');

-- Trickery Domain (id=19)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(19,'trickery-blessing-of-the-trickster','Blessing of the Trickster',1,'You can use your action to touch a willing creature (not yourself) to give it advantage on Dexterity (Stealth) checks. This lasts 1 hour or until you use the feature again.'),
(19,'trickery-channel-divinity-invoke-duplicity','Channel Divinity: Invoke Duplicity',2,'As an action, create a perfect illusion of yourself for 1 minute. You can move it up to 30 ft as a bonus action. While within 5 ft of the illusion, you have advantage on attacks against creatures within 5 ft of it; spells you cast can originate from either location.'),
(19,'trickery-channel-divinity-cloak-of-shadows','Channel Divinity: Cloak of Shadows',6,'As an action, become invisible until the end of your next turn. You become visible if you attack or cast a spell.'),
(19,'trickery-divine-strike','Divine Strike',8,'Once per turn on a hit, deal an extra 1d8 poison damage (2d8 at level 14).'),
(19,'trickery-improved-duplicity','Improved Duplicity',17,'You can create up to four duplicates of yourself instead of one with Invoke Duplicity. As a bonus action on your turn, you can move any number of them up to 30 feet total.');

-- War Domain (id=20)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(20,'war-bonus-proficiencies','Bonus Proficiencies',1,'You gain proficiency with martial weapons and heavy armor.'),
(20,'war-war-priest','War Priest',1,'Your god delivers bolts of inspiration to you while you are engaged in battle. When you use the Attack action, you can make one weapon attack as a bonus action. Uses = Wisdom modifier per long rest.'),
(20,'war-channel-divinity-guided-strike','Channel Divinity: Guided Strike',2,'When you make an attack roll, you can use your Channel Divinity to gain a +10 bonus to the roll. You make this choice after you see the roll, but before the DM says whether the attack hits or misses.'),
(20,'war-channel-divinity-war-gods-blessing','Channel Divinity: War God''s Blessing',6,'When another creature within 30 ft of you makes an attack roll, you can use your reaction to grant that creature a +10 bonus to the roll using Channel Divinity.'),
(20,'war-divine-strike','Divine Strike',8,'Once per turn on a hit, deal an extra 1d8 damage of the same type as the weapon (2d8 at level 14).'),
(20,'war-avatar-of-battle','Avatar of Battle',17,'You gain resistance to bludgeoning, piercing, and slashing damage from nonmagical weapons.');

-- Circle of the Moon (id=21)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(21,'moon-combat-wild-shape','Combat Wild Shape',2,'You gain the ability to use Wild Shape as a bonus action. Also, while in a beast form you can use a bonus action to expend one spell slot and regain 1d8 hp per level of the slot expended.'),
(21,'moon-circle-forms','Circle Forms',2,'The rites of your circle grant you the ability to transform into more dangerous animal forms. You can use Wild Shape to transform into a beast with a challenge rating as high as 1 (goes up as you level: CR 1/3 becomes CR equal to floor(druid level/3)).'),
(21,'moon-primal-strike','Primal Strike',6,'Your attacks in beast form count as magical for the purpose of overcoming resistance and immunity to nonmagical attacks and damage.'),
(21,'moon-elemental-wild-shape','Elemental Wild Shape',10,'You can expend two uses of Wild Shape at the same time to transform into an air elemental, an earth elemental, a fire elemental, or a water elemental.'),
(21,'moon-thousand-forms','Thousand Forms',14,'You have learned to use magic to alter your physical form in more subtle ways. You can cast the Alter Self spell at will.');

-- Battle Master (id=22)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(22,'battlemaster-combat-superiority','Combat Superiority',3,'You learn three maneuvers of your choice from among those available to the Battle Master archetype. Many maneuvers enhance an attack in some way. You can use only one maneuver per attack. You gain four superiority dice (d8), regained on a short or long rest. Save DC = 8 + proficiency + Str or Dex mod.'),
(22,'battlemaster-student-of-war','Student of War',3,'You gain proficiency with one type of artisan''s tools of your choice.'),
(22,'battlemaster-know-your-enemy','Know Your Enemy',7,'If you spend at least 1 minute observing or interacting with another creature outside combat, you can learn certain information: whether it is your equal, superior, or inferior in Strength, Dexterity, Constitution, AC, current HP, total class levels, and Fighter levels.'),
(22,'battlemaster-improved-combat-superiority','Improved Combat Superiority',10,'Your superiority dice turn into d10s at 10th level and d12s at 18th level.'),
(22,'battlemaster-relentless','Relentless',15,'When you roll initiative and have no superiority dice remaining, you regain 1 superiority die.');

-- Eldritch Knight (id=23)
INSERT INTO subclass_features (subclass_id,index_name,name,level,description) VALUES
(23,'ek-spellcasting','Spellcasting',3,'You augment your martial prowess with the ability to cast spells. You learn spells from the wizard list, primarily abjuration and evocation. Intelligence is your spellcasting ability.'),
(23,'ek-weapon-bond','Weapon Bond',3,'You learn a ritual to create a bond with up to two weapons. You can''t be disarmed of bonded weapons, and you can summon a bonded weapon to your hand as a bonus action.'),
(23,'ek-war-magic','War Magic',7,'When you use your action to cast a cantrip, you can make one weapon attack as a bonus action.'),
(23,'ek-eldritch-strike','Eldritch Strike',10,'When you hit a creature with a weapon attack, you can expend one spell slot to deal an extra 1d6 force damage per spell level and potentially impose disadvantage on its next saving throw against a spell.'),
(23,'ek-arcane-charge','Arcane Charge',15,'When you use Action Surge, you can teleport up to 30 feet to an unoccupied space you can see, either before or after the additional action.'),
(23,'ek-improved-war-magic','Improved War Magic',18,'When you use your action to cast a spell, you can make one weapon attack as a bonus action.');
