class CharacterSpell {
  final int id; //ID del CharacterSpell (la relación)
  final int spellId;
  final String name;
  final int level; //0 = Cantrip, 1st, 2nd, etc
  final String? school;
  final String? castingTime;
  final String? range;
  final String? duration;
  final String? components;
  final String? description;
  final bool prepared;
  final bool learned;
  final String? spellSource; // "CLASS", "SUBCLASS", "RACE", "FEAT"
  final String? attackType;  // "ranged", "melee", or null (save)
  final String? dcType;      // "DEX", "CON", etc. or null (attack)
  final String? damageType;  // "Fire", "Cold", etc.
  final String? damageBase;  // "8d6", "1d10", etc.


  const CharacterSpell({
    required this.id,
    required this.spellId,
    required this.name,
    required this.level,
    this.school,
    this.castingTime,
    this.range,
    this.duration,
    this.components,
    this.description,
    required this.prepared,
    required this.learned,
    this.spellSource,
    this.attackType,
    this.dcType,
    this.damageType,
    this.damageBase,
  });

  bool get isCantrip => level == 0;

  String get levelLabel => isCantrip ? 'Cantrip' : 'Level $level';

  String get sourceLabel{
    switch (spellSource?.toUpperCase()){
      case 'RACE': return 'Racial';
      case 'FEAT': return 'Feat';
      case 'SUBCLASS': return 'Subclass';
      default: return 'Class';
    }
  }

  factory CharacterSpell.fromJson(Map<String, dynamic> j) => CharacterSpell(
    id: (j['id'] as num).toInt(),
    spellId: (j['spellId'] as num?)?.toInt() ?? (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    level: (j['level'] as num?)?.toInt() ?? 0,
    school: j['school'] as String?,
    castingTime: j['castingTime'] as String?,
    range: j['range'] as String?,
    duration: j['duration'] as String?,
    components: j['components'] as String?,
    description: j['description'] as String?,
    prepared: j['prepared'] as bool? ?? false,
    learned: j['learned'] as bool? ?? false,
    spellSource: j['spellSource'] as String?,
    attackType: j['attackType'] as String?,
    dcType: j['dcType'] as String?,
    damageType: j['damageType'] as String?,
    damageBase: j['damageBase'] as String?,
  );
}