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
