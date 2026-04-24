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
