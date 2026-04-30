///Fuente de verdad para clasificar ClassFeatures en tabs.
///Usa el indexName (estable de la D&D 5e API (minusculas, guiones))
///Para añadir una feature nueva: añade su indexName al set correcto.

// ── ACCIONES (Actions) ──────────────────────────────────────────────────────
const kCombatActionFeatures = <String>{
  // Fighter — variantes de action-surge resueltas por prefijo en classifyFeature
  'action-surge', 'extra-attack', 'indomitable', 'know-your-enemy',
  // Barbarian
  'reckless-attack', 'frenzy', 'retaliation', 'intimidating-presence',
  // Rogue
  'sneak-attack', 'assassinate', 'death-strike', 'use-magic-device',
  // Monk
  'stunning-strike', 'ki-empowered-strikes', 'quivering-palm', 'empty-body', 
  'perfect-self', 'diamond-soul',
  // Druid
  'wild-shape', 'archdruid', 'nature-ward',
  // Cleric
  'channel-divinity', 'divine-intervention', 'turn-undead', 
  'channel-divinity-preserve-life', 'channel-divinity-radiance-of-the-dawn',
  'channel-divinity-invoke-duplicity', 'channel-divinity-guided-strike',
  'channel-divinity-war-gods-blessing',
  // Paladin
  'divine-smite', 'lay-on-hands', 'cleansing-touch', 'channel-divinity-sacred-weapon', 
  'channel-divinity-turn-the-unholy', 'channel-divinity-abjure-enemy', 'channel-divinity-vow-of-enmity',
  // Ranger
  'multiattack', 'whirlwind-attack', 'volley', 'hide-in-plain-sight', 'conjure-barrage',
  // Bard
  'countercharm', 'magical-secrets',
  // Sorcerer
  'wild-magic-surge', 'magical-guidance',
  // Wizard
  'arcane-recovery', 'overchannel', 'illusiory-self', 'focused-conjuration',
  // Universales / Raciales
  'martial-arts', 'breath-weapon', 'sunlight-sensitivity', 'relentless-endurance',
};

// ── ACCIONES DE BONO (Bonus Actions) ────────────────────────────────────────
const kCombatBonusFeatures = <String>{
  // Barbarian
  'rage', 
  // Rogue
  'cunning-action', 'master-of-tactics', 'fast-hands',
  // Bard
  'bardic-inspiration',
  // Monk
  'flurry-of-blows', 'patient-defense', 'step-of-the-wind', 'martial-arts-bonus-attack',
  // Paladin
  'divine-favor', 'vow-of-enmity',
  // Ranger
  'hunters-sense', 'slayers-prey', 'vanish', 'foes-slayer',
  // Sorcerer
  'tides-of-chaos', 'metamagic', 'flexible-casting', 'quickened-spell',
  // Warlock
  'hexblades-curse', 'mystic-arumcanum', 'form-of-dread',
  // Fighter
  'second-wind', 'fighting-style-great-weapon-fighting',
  // Generales
  'two-weapon-fighting', 'bonus-action-attack', 'shield-master-shove',
};

// ── REACCIONES (Reactions) ──────────────────────────────────────────────────
const kCombatReactionFeatures = <String>{
  // Rogue
  'uncanny-dodge', 'misdirection', 'stroke-of-luck', 'spell-thief',
  // Bard
  'cutting-words',
  // Monk
  'deflect-missiles', 'slow-fall',
  // Fighter/Paladin
  'protection', 'interception', 'parry',
  // Wizard
  'projected-ward', 'instinctive-charm',
  // Feats / Universales
  'opportunity-attack', 'sentinel', 'war-caster', 'polearm-master-aoo',
  'shield-master-evasion', 'counterspell', 'hellish-rebuke',
};

// ── ENUMERACIÓN Y LÓGICA ────────────────────────────────────────────────────
enum FeatureCategory {
  combatAction,
  combatBonus,
  combatReaction,
  passive, 
}

/// Devuelve true si [i] coincide exactamente con alguna entrada del set,
/// o si [i] empieza por "<entrada>-" (para manejar variantes del estilo
/// 'action-surge-1-use', 'bardic-inspiration-d6', 'wild-shape-cr-*…', etc.)
bool _matchesCombatSet(String i, Set<String> features) {
  if (features.contains(i)) return true;
  return features.any((k) => i.startsWith('$k-'));
}

FeatureCategory classifyFeature(String indexName) {
  if (indexName.isEmpty) return FeatureCategory.passive;

  final i = indexName.toLowerCase().trim();

  // El orden de búsqueda prioriza el tipo de acción sobre la pasiva
  if (_matchesCombatSet(i, kCombatReactionFeatures)) return FeatureCategory.combatReaction;
  if (_matchesCombatSet(i, kCombatBonusFeatures))    return FeatureCategory.combatBonus;
  if (_matchesCombatSet(i, kCombatActionFeatures))   return FeatureCategory.combatAction;

  return FeatureCategory.passive;
}

bool isCombatRelevant(String indexName) =>
    classifyFeature(indexName) != FeatureCategory.passive;