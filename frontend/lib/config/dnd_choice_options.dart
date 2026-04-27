/// Shared option lists for D&D 5e choices.
/// Used both by the character creation wizard and the pending tasks screen.

class DndChoiceOption {
  final String name;
  final String description;
  const DndChoiceOption(this.name, this.description);
}

const kFightingStyles = [
  DndChoiceOption('Archery',               '+2 bonus to attack rolls with ranged weapons.'),
  DndChoiceOption('Defense',               '+1 to AC while wearing armor.'),
  DndChoiceOption('Dueling',               '+2 to damage rolls when wielding a melee weapon in one hand and no other weapons.'),
  DndChoiceOption('Great Weapon Fighting', 'Reroll 1s and 2s on damage dice when using two-handed melee weapons.'),
  DndChoiceOption('Protection',            'Impose disadvantage on attacks against allies within 5 ft (requires shield).'),
  DndChoiceOption('Two-Weapon Fighting',   'Add ability modifier to the damage of your off-hand attack.'),
  DndChoiceOption('Blind Fighting',        'You have blindsight with a range of 10 ft.'),
  DndChoiceOption('Interception',          'Reduce damage to a creature within 5 ft by 1d10 + proficiency bonus (reaction).'),
  DndChoiceOption('Superior Technique',    'Learn one maneuver and gain one superiority die (d6).'),
  DndChoiceOption('Thrown Weapon Fighting','+2 to damage with thrown weapons; draw them as part of the attack.'),
  DndChoiceOption('Unarmed Fighting',      'Unarmed strikes deal 1d6 (1d8 if hands free). Grappled creatures take 1d4 bludgeoning at start of your turn.'),
];

const kFavoredEnemies = [
  DndChoiceOption('Aberrations',        'Aberrations: mind flayers, beholders, and other alien horrors.'),
  DndChoiceOption('Beasts',             'Beasts: animals and other natural creatures.'),
  DndChoiceOption('Celestials',         'Celestials: angels, unicorns, and other divine creatures.'),
  DndChoiceOption('Constructs',         'Constructs: golems, animated objects, and similar.'),
  DndChoiceOption('Dragons',            'Dragons: true dragons and related creatures.'),
  DndChoiceOption('Elementals',         'Elementals: creatures of elemental planes.'),
  DndChoiceOption('Fey',                'Fey: sprites, dryads, and other fey creatures.'),
  DndChoiceOption('Fiends',             'Fiends: demons, devils, and similar.'),
  DndChoiceOption('Giants',             'Giants: hill giants, storm giants, and their kin.'),
  DndChoiceOption('Monstrosities',      'Monstrosities: monsters of unknown origin.'),
  DndChoiceOption('Oozes',              'Oozes: gelatinous cubes, black puddings, etc.'),
  DndChoiceOption('Plants',             'Plants: shambling mounds, treants, and similar.'),
  DndChoiceOption('Undead',             'Undead: zombies, vampires, ghosts, and the like.'),
  DndChoiceOption('Two humanoid types', 'Choose two humanoid races (e.g. orcs and gnolls).'),
];

const kFavoredTerrains = [
  DndChoiceOption('Arctic',    'Tundra and frozen wastes.'),
  DndChoiceOption('Coast',     'Shores, beaches, and tidal areas.'),
  DndChoiceOption('Desert',    'Hot or cold desert environments.'),
  DndChoiceOption('Forest',    'Dense woodlands and jungles.'),
  DndChoiceOption('Grassland', 'Prairies, savannas, and plains.'),
  DndChoiceOption('Mountain',  'High altitude rocky terrain.'),
  DndChoiceOption('Swamp',     'Wetlands, marshes, and bogs.'),
  DndChoiceOption('Underdark', 'Subterranean tunnels and caverns.'),
];

const kDraconicAncestries = [
  DndChoiceOption('Black',  'Acid — Line 5×30 ft, DC Con'),
  DndChoiceOption('Blue',   'Lightning — Line 5×30 ft, DC Dex'),
  DndChoiceOption('Brass',  'Fire — Line 5×30 ft, DC Dex'),
  DndChoiceOption('Bronze', 'Lightning — Line 5×30 ft, DC Dex'),
  DndChoiceOption('Copper', 'Acid — Line 5×30 ft, DC Dex'),
  DndChoiceOption('Gold',   'Fire — Cone 15 ft, DC Dex'),
  DndChoiceOption('Green',  'Poison — Cone 15 ft, DC Con'),
  DndChoiceOption('Red',    'Fire — Cone 15 ft, DC Dex'),
  DndChoiceOption('Silver', 'Cold — Cone 15 ft, DC Con'),
  DndChoiceOption('White',  'Cold — Cone 15 ft, DC Con'),
];

/// Standard languages of the D&D 5e Player's Handbook.
const kLanguages = [
  DndChoiceOption('Abyssal',     'Spoken by demons; script: Infernal.'),
  DndChoiceOption('Celestial',   'Spoken by celestials; script: Celestial.'),
  DndChoiceOption('Deep Speech', 'Spoken by aboleths; no standard script.'),
  DndChoiceOption('Draconic',    'Spoken by dragons and dragonborn; script: Draconic.'),
  DndChoiceOption('Dwarvish',    'Spoken by dwarves; script: Dwarvish.'),
  DndChoiceOption('Elvish',      'Spoken by elves; script: Elvish.'),
  DndChoiceOption('Giant',       'Spoken by ogres and giants; script: Dwarvish.'),
  DndChoiceOption('Gnomish',     'Spoken by gnomes; script: Dwarvish.'),
  DndChoiceOption('Goblin',      'Spoken by goblins; script: Dwarvish.'),
  DndChoiceOption('Halfling',    'Spoken by halflings; script: Common.'),
  DndChoiceOption('Infernal',    'Spoken by devils; script: Infernal.'),
  DndChoiceOption('Orc',         'Spoken by orcs; script: Dwarvish.'),
  DndChoiceOption('Primordial',  'Spoken by elementals; script: Dwarvish.'),
  DndChoiceOption('Sylvan',      'Spoken by fey creatures; script: Elvish.'),
  DndChoiceOption('Undercommon', 'Trade language of the Underdark; script: Elvish.'),
];

/// Wizard cantrips from the SRD/Player's Handbook.
const kWizardCantrips = [
  DndChoiceOption('Acid Splash',       'Orb of acid splashes up to two creatures within 5 ft of each other.'),
  DndChoiceOption('Chill Touch',       'Ghostly skeletal hand — necrotic damage, prevents HP recovery.'),
  DndChoiceOption('Dancing Lights',    'Creates up to four floating lights.'),
  DndChoiceOption('Fire Bolt',         '+ranged spell attack, 1d10 fire damage.'),
  DndChoiceOption('Friends',           'Advantage on Charisma checks against one non-hostile creature.'),
  DndChoiceOption('Light',             'Object glows 20-ft bright + 20-ft dim light.'),
  DndChoiceOption('Mage Hand',         'Spectral hand manipulates objects up to 30 ft away.'),
  DndChoiceOption('Mending',           'Repairs minor breaks or tears in an object.'),
  DndChoiceOption('Message',           'Whisper a message to a creature up to 120 ft away.'),
  DndChoiceOption('Minor Illusion',    'Creates a sound or image within 30 ft.'),
  DndChoiceOption('Poison Spray',      'Puff of noxious gas — Con save or take 1d12 poison damage.'),
  DndChoiceOption('Prestidigitation',  'Minor magical tricks — light candles, clean objects, etc.'),
  DndChoiceOption('Ray of Frost',      '+ranged spell attack, 1d8 cold damage, speed –10 ft.'),
  DndChoiceOption('Shocking Grasp',    '+melee spell attack, 1d8 lightning, target can\'t take reactions.'),
  DndChoiceOption('True Strike',       'Advantage on next attack roll against one creature.'),
];

/// All 18 D&D 5e skills, for races that grant a free skill choice.
const kSkills = [
  DndChoiceOption('Acrobatics',      'DEX — tumbling, balancing.'),
  DndChoiceOption('Animal Handling', 'WIS — soothing, controlling animals.'),
  DndChoiceOption('Arcana',          'INT — magical lore, spells, planes.'),
  DndChoiceOption('Athletics',       'STR — climbing, jumping, swimming.'),
  DndChoiceOption('Deception',       'CHA — lying, disguising, misdirection.'),
  DndChoiceOption('History',         'INT — events, people, legends.'),
  DndChoiceOption('Insight',         'WIS — reading people, detecting lies.'),
  DndChoiceOption('Intimidation',    'CHA — threats, coercing.'),
  DndChoiceOption('Investigation',   'INT — searching, deducing clues.'),
  DndChoiceOption('Medicine',        'WIS — stabilising, diagnosing.'),
  DndChoiceOption('Nature',          'INT — terrain, plants, weather, creatures.'),
  DndChoiceOption('Perception',      'WIS — noticing things with senses.'),
  DndChoiceOption('Performance',     'CHA — acting, singing, playing instruments.'),
  DndChoiceOption('Persuasion',      'CHA — diplomacy, negotiating.'),
  DndChoiceOption('Religion',        'INT — deities, cults, rituals.'),
  DndChoiceOption('Sleight of Hand', 'DEX — pickpocketing, concealing.'),
  DndChoiceOption('Stealth',         'DEX — hiding, moving silently.'),
  DndChoiceOption('Survival',        'WIS — tracking, foraging, navigation.'),
];

/// Tool options available to Dwarves via "Tool Proficiency" racial trait.
const kDwarfTools = [
  DndChoiceOption('Smith\'s Tools',     'Forge and repair metal items.'),
  DndChoiceOption('Brewer\'s Supplies', 'Brew ales, meads, and other beverages.'),
  DndChoiceOption('Mason\'s Tools',     'Work with stone — cutting, shaping, construction.'),
];

/// Rangers only have access to 4 of the 11 Fighting Styles.
const kRangerFightingStyles = [
  DndChoiceOption('Archery',             '+2 bonus to attack rolls with ranged weapons.'),
  DndChoiceOption('Defense',             '+1 to AC while wearing armor.'),
  DndChoiceOption('Dueling',             '+2 to damage rolls when wielding a melee weapon in one hand and no other weapons.'),
  DndChoiceOption('Two-Weapon Fighting', 'Add ability modifier to the damage of your off-hand attack.'),
];

// ── Hunter Ranger subclass choices ────────────────────────────────────────────

const kHuntersPrey = [
  DndChoiceOption('Colossus Slayer',  'Once per turn, deal an extra 1d8 damage to a creature below its hit point maximum.'),
  DndChoiceOption('Giant Killer',     'Reaction: make one attack against a Large or larger creature that misses you within reach.'),
  DndChoiceOption('Horde Breaker',    'Once per turn, attack a second creature adjacent to the first target (same action).'),
];

const kDefensiveTactics = [
  DndChoiceOption('Escape the Horde',        'Opportunity attacks against you are made with disadvantage.'),
  DndChoiceOption('Multiattack Defense',     'After being hit by a creature, gain +4 AC against further attacks from it this turn.'),
  DndChoiceOption('Steel Will',              'Advantage on saving throws against being frightened.'),
];

const kHunterMultiattack = [
  DndChoiceOption('Volley',           'Use your action to make a ranged attack against every creature within 10 ft of a chosen point.'),
  DndChoiceOption('Whirlwind Attack', 'Use your action to make a melee attack against every creature within 5 ft of you.'),
];

const kSuperiorHuntersDefense = [
  DndChoiceOption('Evasion',                   'Half damage on failed DEX saves; no damage on success.'),
  DndChoiceOption('Stand Against the Tide',    'Reaction when a creature misses you: force it to reroll against a creature of your choice.'),
  DndChoiceOption('Uncanny Dodge',             'Reaction: halve the damage from an attack you can see from an attacker you can see.'),
];

// ── Totem Warrior ─────────────────────────────────────────────────────────────

const kTotemSpirit = [
  DndChoiceOption('Bear',   'Resistance to all damage except psychic while raging.'),
  DndChoiceOption('Eagle',  'Dash as bonus action while raging; OA against you have disadvantage (except from creatures you attack).'),
  DndChoiceOption('Wolf',   'Allies have advantage on melee attacks vs. creatures adjacent to you while you rage.'),
];

const kTotemAspect = [
  DndChoiceOption('Bear',   'Carry twice normal amount; push/drag/lift weight is doubled.'),
  DndChoiceOption('Eagle',  'See up to 1 mile clearly; dim light doesn\'t impose Perception disadvantage.'),
  DndChoiceOption('Wolf',   'Track by scent; know which creatures have been in an area within the past day.'),
];

const kTotemicAttunement = [
  DndChoiceOption('Bear',   'Frightened enemies within 5 ft have disadvantage on attacks not directed at you.'),
  DndChoiceOption('Eagle',  'Flying speed equal to walking speed while raging.'),
  DndChoiceOption('Wolf',   'Knock a Large or smaller enemy prone when you hit it with a melee attack while raging.'),
];

// ── Battle Master Maneuvers ───────────────────────────────────────────────────

const kBattleMasterManeuvers = [
  DndChoiceOption('Commander\'s Strike',    'Forgo one attack to direct an ally; they add your superiority die to the attack.'),
  DndChoiceOption('Disarming Attack',       'Add superiority die to damage; target drops an item (STR save).'),
  DndChoiceOption('Distracting Strike',     'Add superiority die to damage; next attack against target has advantage until your next turn.'),
  DndChoiceOption('Evasive Footwork',       'Add superiority die to AC while moving until you stop.'),
  DndChoiceOption('Feinting Attack',        'Bonus action feint vs. adjacent creature; advantage on next attack + superiority die damage.'),
  DndChoiceOption('Goading Attack',         'Add superiority die to damage; target has disadvantage on attacks not against you (WIS save).'),
  DndChoiceOption('Lunging Attack',         'Add 5 ft to your melee reach for one attack; add superiority die to damage.'),
  DndChoiceOption('Maneuvering Attack',     'Add superiority die to damage; ally can move half speed without OA from target.'),
  DndChoiceOption('Menacing Attack',        'Add superiority die to damage; target is frightened until end of your next turn (WIS save).'),
  DndChoiceOption('Parry',                  'Reaction when hit by melee attack: reduce damage by superiority die + DEX modifier.'),
  DndChoiceOption('Precision Attack',       'Add superiority die to an attack roll before knowing if it hits.'),
  DndChoiceOption('Pushing Attack',         'Add superiority die to damage; push target up to 15 ft (STR save).'),
  DndChoiceOption('Rally',                  'Boost ally\'s morale: they gain temp HP equal to superiority die + CHA modifier.'),
  DndChoiceOption('Riposte',                'Reaction when missed by melee attacker: one melee attack + superiority die damage.'),
  DndChoiceOption('Sweeping Attack',        'Add superiority die damage to a second creature adjacent to the first if first attack hits.'),
  DndChoiceOption('Trip Attack',            'Add superiority die to damage; knock prone (STR save) if target is Large or smaller.'),
];

// ── Four Elements Disciplines ─────────────────────────────────────────────────

const kFourElementsDisciplines = [
  DndChoiceOption('Elemental Attunement',       'Free. Minor elemental effects: create sensory phenomena, move tiny objects, light/snuff flames.'),
  DndChoiceOption('Breath of Winter',           '6 ki. Cast Cone of Cold.'),
  DndChoiceOption('Clench of the North Wind',   '3 ki. Cast Hold Person.'),
  DndChoiceOption('Eternal Mountain Defense',   '5 ki. Cast Stoneskin (self only).'),
  DndChoiceOption('Fangs of the Fire Snake',    '1 ki. Your unarmed strike can reach 10 ft and deals fire damage; extra ki for more damage.'),
  DndChoiceOption('Fist of Four Thunders',      '2 ki. Cast Thunderwave.'),
  DndChoiceOption('Fist of Unbroken Air',       '2 ki. Ranged attack: 3d10 bludgeoning + push 20 ft + knock prone (STR save).'),
  DndChoiceOption('Flames of the Phoenix',      '4 ki. Cast Fireball.'),
  DndChoiceOption('Gong of the Summit',         '3 ki. Cast Shatter.'),
  DndChoiceOption('Mist Stance',                '4 ki. Cast Gaseous Form (self).'),
  DndChoiceOption('Ride the Wind',              '4 ki. Cast Fly (self).'),
  DndChoiceOption('River of Hungry Flame',      '5 ki. Cast Wall of Fire.'),
  DndChoiceOption('Rush of the Gale Spirits',   '2 ki. Cast Gust of Wind.'),
  DndChoiceOption('Shape the Flowing River',    '1 ki. As action, shape ice/water in a 30-ft cube.'),
  DndChoiceOption('Sweeping Cinder Strike',     '2 ki. Cast Burning Hands.'),
  DndChoiceOption('Water Whip',                 '2 ki. Magic whip: 3d10 bludgeoning + pull 25 ft or knock prone (STR save).'),
  DndChoiceOption('Wave of Rolling Earth',      '6 ki. Cast Wall of Stone.'),
];

// ── Ability Score Improvement ─────────────────────────────────────────────────

/// Six ability score names used in ASI two-pick UI.
const kAbilityScoreNames = [
  DndChoiceOption('Strength',      'STR'),
  DndChoiceOption('Dexterity',     'DEX'),
  DndChoiceOption('Constitution',  'CON'),
  DndChoiceOption('Intelligence',  'INT'),
  DndChoiceOption('Wisdom',        'WIS'),
  DndChoiceOption('Charisma',      'CHA'),
];

/// Common SRD feats for the Feat picker.
const kFeats = [
  DndChoiceOption('Alert',                 '+5 initiative, can\'t be surprised while conscious, hidden attackers gain no advantage.'),
  DndChoiceOption('Athlete',               '+1 STR or DEX; improved climbing, jumping and stand-up mechanics.'),
  DndChoiceOption('Actor',                 '+1 CHA; advantage on Deception/Performance when impersonating; mimic voices/sounds.'),
  DndChoiceOption('Charger',               'After Dash as action, bonus attack (+5 dmg) or shove 10 ft.'),
  DndChoiceOption('Crossbow Expert',       'Ignore loading; no disadvantage in melee; bonus hand-crossbow attack.'),
  DndChoiceOption('Defensive Duelist',     'Reaction: +proficiency bonus to AC against one melee hit (requires finesse weapon).'),
  DndChoiceOption('Dual Wielder',          '+1 AC while dual-wielding; wield non-light melee weapons in each hand; draw/stow two.'),
  DndChoiceOption('Dungeon Delver',        'Advantage to detect secret doors and avoid traps; resistance to trap damage.'),
  DndChoiceOption('Durable',               '+1 CON; minimum roll of 2 × CON modifier on Hit Dice.'),
  DndChoiceOption('Grappler',              '+1 STR; advantage on attacks vs. grappled creatures; pin a creature you are grappling.'),
  DndChoiceOption('Great Weapon Master',   'Bonus attack on crit or reduce-to-0; take −5 to attack for +10 damage.'),
  DndChoiceOption('Healer',                'Use healer\'s kit to stabilise (1 HP) or restore 1d6+4+level HP once per creature per rest.'),
  DndChoiceOption('Heavily Armored',       '+1 STR; gain proficiency with heavy armor.'),
  DndChoiceOption('Heavy Armor Master',    '+1 STR; reduce non-magical B/P/S damage by 3 while wearing heavy armor.'),
  DndChoiceOption('Inspiring Leader',      'After 10 min speech, grant up to 6 creatures temp HP = level + CHA modifier.'),
  DndChoiceOption('Keen Mind',             '+1 INT; know direction/time elapsed; perfect recall of last month\'s events.'),
  DndChoiceOption('Linguist',              '+1 INT; learn 3 languages; create and decode ciphers.'),
  DndChoiceOption('Lucky',                 '3 luck points/long rest: add extra d20 to any attack, check, save, or enemy attack roll (choose which).'),
  DndChoiceOption('Mage Slayer',           'Reaction attack when adjacent creature casts; advantage on saves vs adjacent spellcasters.'),
  DndChoiceOption('Magic Initiate',        'Learn 2 cantrips + 1 1st-level spell from a chosen class list (cast once per long rest).'),
  DndChoiceOption('Martial Adept',         'Learn 2 Battle Master maneuvers; gain 1 superiority die (d6).'),
  DndChoiceOption('Medium Armor Master',   'No Stealth disadvantage in medium armor; max DEX bonus +3.'),
  DndChoiceOption('Mobile',                '+10 ft speed; Dash doesn\'t provoke OA; no OA from targets you attack.'),
  DndChoiceOption('Moderately Armored',    '+1 STR or DEX; proficiency with medium armor and shields.'),
  DndChoiceOption('Mounted Combatant',     'Advantage on melee attacks vs unmounted smaller creatures; redirect enemy attacks to mount.'),
  DndChoiceOption('Observant',             '+1 INT or WIS; can lip-read; +5 passive Perception and Investigation.'),
  DndChoiceOption('Polearm Master',        'Bonus attack with butt end (d4); opportunity attack when creature enters reach.'),
  DndChoiceOption('Resilient',             '+1 to chosen ability score; gain proficiency in that ability\'s saving throw.'),
  DndChoiceOption('Ritual Caster',         'Learn ritual spells from a class list; cast them as rituals without expending a spell slot.'),
  DndChoiceOption('Savage Attacker',       'Once per turn, reroll all weapon damage dice and use either result.'),
  DndChoiceOption('Sentinel',              'OA stops movement; attack creature that uses Disengage; react to ally attack.'),
  DndChoiceOption('Sharpshooter',          'No disadvantage at long range; ignore half/three-quarters cover; −5 attack for +10 damage.'),
  DndChoiceOption('Shield Master',         'Shove as bonus action after Attack; add shield bonus to DEX saves; negate damage on success.'),
  DndChoiceOption('Skilled',               'Gain proficiency in any 3 skills or tools of your choice.'),
  DndChoiceOption('Skulker',               'Hide when lightly obscured; ranged miss doesn\'t reveal you; no Perception penalty in dim light.'),
  DndChoiceOption('Spell Sniper',          'Double range of spell attacks; ignore cover; learn one attack cantrip.'),
  DndChoiceOption('Tavern Brawler',        '+1 STR or CON; proficient with improvised weapons; d4 unarmed; grapple as bonus action.'),
  DndChoiceOption('Tough',                 '+2 HP per level (including retroactively).'),
  DndChoiceOption('War Caster',            'Advantage on concentration saves; somatic with hands full; cast spell as opportunity attack.'),
  DndChoiceOption('Weapon Master',         '+1 STR or DEX; proficiency with 4 weapons of your choice.'),
];
