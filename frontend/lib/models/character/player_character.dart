import 'package:gestor_personajes_dnd/models/character/spell_slot.dart';

class PlayerCharacter{
  final int id;
  final String name;
  final int level;
  final int? raceId;
  final String? raceName;
  final int? dndClassId;
  final String? dndClassName;
  final Map<String, int> abilityScores;
  final int maxHp;
  final int currentHp;
  final int temporaryHp;
  final int proficiencyBonus;
  final int armorClass;
  final int initiativeModifier;
  final int currentSpeed;
  final int deathSaveSuccesses;
  final int deathSaveFailures;
  final bool hasInspiration;
  final bool isDying;
  final bool isStable;
  final bool isDead;
  final bool isConscious;
  final int experiencePoints;
  final int experienceToNextLevel;
  final int availableHitDice;
  final int passivePerception;
  final int passiveInvestigation;
  final int passiveInsight;
  final int meleeAttackBonus;
  final int rangedAttackBonus;
  final int finesseAttackBonus;
  final int spellSaveDC;
  final int spellAttackBonus;
  final int maxPreparedSpells;
  final String? alignment;
  final String? subclassName;
  final String? backgroundName;
  final String? personalityTrait1;
  final String? personalityTrait2;
  final String? ideal;
  final String? bond;
  final String? flaw;
  final String? backstory;
  final String? characterHistory;
  final String? appearance;
  final String? alliesAndOrganizations;
  final String? additionalTreasure;
  final int? age;
  final String? height;
  final String? weight;
  final String? eyes;
  final String? skin;
  final String? hair;
  final List<SpellSlot> spellSlots;


  const PlayerCharacter({
    required this.id,
    required this.name,
    required this.level,
    this.raceId,
    this.raceName,
    this.dndClassId,
    this.dndClassName,
    required this.abilityScores,
    required this.maxHp,
    required this.currentHp,
    required this.temporaryHp,
    required this.proficiencyBonus,
    required this.armorClass,
    required this.initiativeModifier,
    required this.currentSpeed,
    required this.deathSaveSuccesses,
    required this.deathSaveFailures,
    required this.hasInspiration,
    required this.isDying,
    required this.isStable,
    required this.isDead,
    required this.isConscious,
    required this.experiencePoints,
    required this.experienceToNextLevel,
    required this.availableHitDice,
    required this.passivePerception,
    required this.passiveInvestigation,
    required this.passiveInsight,
    required this.meleeAttackBonus,
    required this.rangedAttackBonus,
    required this.finesseAttackBonus,
    required this.spellSaveDC,
    required this.spellAttackBonus,
    required this.maxPreparedSpells,
    this.alignment,
    this.subclassName,
    this.backgroundName,
    this.personalityTrait1,
    this.personalityTrait2,
    this.ideal,
    this.bond,
    this.flaw,
    this.backstory,
    this.characterHistory,
    this.appearance,
    this.alliesAndOrganizations,
    this.additionalTreasure,
    this.age,
    this.height,
    this.weight,
    this.eyes,
    this.skin,
    this.hair,
    this.spellSlots = const [],
  });

  factory PlayerCharacter.fromJson(Map<String, dynamic> j) {
    // abilityScores comes as Map<String,dynamic> → cast values to int
    final rawScores = j['abilityScores'] as Map<String, dynamic>? ?? {};
    final scores = rawScores.map(
        (k, v) => MapEntry(k, (v as num).toInt()));

    return PlayerCharacter(
      id:                  (j['id'] as num).toInt(),
      name:                j['name'] as String? ?? '',
      level:               (j['level'] as num?)?.toInt() ?? 1,
      raceId:              (j['raceId'] as num?)?.toInt(),
      raceName:            j['raceName'] as String?,
      dndClassId:          (j['dndClassId'] as num?)?.toInt(),
      dndClassName:        j['dndClassName'] as String?,
      abilityScores:       scores,
      maxHp:               (j['maxHp'] as num?)?.toInt() ?? 0,
      currentHp:           (j['currentHp'] as num?)?.toInt() ?? 0,
      temporaryHp:         (j['temporaryHp'] as num?)?.toInt() ?? 0,
      proficiencyBonus:    (j['proficiencyBonus'] as num?)?.toInt() ?? 2,
      armorClass:          (j['armorClass'] as num?)?.toInt() ?? 10,
      initiativeModifier:  (j['initiativeModifier'] as num?)?.toInt() ?? 0,
      currentSpeed:        (j['currentSpeed'] as num?)?.toInt() ?? 30,
      deathSaveSuccesses:  (j['deathSaveSuccesses'] as num?)?.toInt() ?? 0,
      deathSaveFailures:   (j['deathSaveFailures'] as num?)?.toInt() ?? 0,
      hasInspiration:      (j['hasInspiration'] as bool?) ?? false,
      isDying:             (j['dying'] as bool?) ?? false,
      isStable:            (j['stable'] as bool?) ?? false,
      isDead:              (j['dead'] as bool?) ?? false,
      isConscious:         (j['conscious'] as bool?) ?? true,
      experiencePoints:    (j['experiencePoints'] as num?)?.toInt() ?? 0,
      experienceToNextLevel: (j['experienceToNextLevel'] as num?)?.toInt() ?? 300,
      availableHitDice:    (j['availableHitDice'] as num?)?.toInt() ?? 0,
      passivePerception:   (j['passivePerception'] as num?)?.toInt() ?? 10,
      passiveInvestigation:(j['passiveInvestigation'] as num?)?.toInt() ?? 10,
      passiveInsight:      (j['passiveInsight'] as num?)?.toInt() ?? 10,
      meleeAttackBonus:    (j['meleeAttackBonus'] as num?)?.toInt() ?? 0,
      rangedAttackBonus:   (j['rangedAttackBonus'] as num?)?.toInt() ?? 0,
      finesseAttackBonus:  (j['finesseAttackBonus'] as num?)?.toInt() ?? 0,
      spellSaveDC:         (j['spellSaveDC'] as num?)?.toInt() ?? 8,
      spellAttackBonus:    (j['spellAttackBonus'] as num?)?.toInt() ?? 0,
      maxPreparedSpells:   (j['maxPreparedSpells'] as num?)?.toInt() ?? 0,
      alignment:           j['alignment'] as String?,
      subclassName:        j['subclassName'] as String?,
      backgroundName:      j['backgroundName'] as String?,
      personalityTrait1:   j['personalityTrait1'] as String?,
      personalityTrait2:   j['personalityTrait2'] as String?,
      ideal:               j['ideal'] as String?,
      bond:                j['bond'] as String?,
      flaw:                j['flaw'] as String?,
      backstory:           j['backstory'] as String?,
      characterHistory:    j['characterHistory'] as String?,
      appearance:          j['appearance'] as String?,
      alliesAndOrganizations: j['alliesAndOrganizations'] as String?,
      additionalTreasure:  j['additionalTreasure'] as String?,
      age:                 (j['age'] as num?)?.toInt(),
      height:              j['height'] as String?,
      weight:              j['weight'] as String?,
      eyes:                j['eyes'] as String?,
      skin:                j['skin'] as String?,
      hair:                j['hair'] as String?,
      spellSlots:          (j['spellSlots'] as List<dynamic>? ?? [])
                               .map((e) => SpellSlot.fromJson(e as Map<String, dynamic>))
                               .toList(),
    );
  }

  //Helpers
  int modifier(String ability) {
    final score = abilityScores[ability] ?? 10;
    return ((score - 10) / 2).floor();
  }

  String modLabel(String ability) {
    final m = modifier(ability);
    return m >= 0 ? '+$m' : '$m';
  }

  double get hpPercent => maxHp == 0 ? 0 : (currentHp / maxHp).clamp(0.0, 1.0);

  double get xpPercent => experienceToNextLevel == 0 ? 0 : (experiencePoints / experienceToNextLevel).clamp(0.0, 1.0);

}