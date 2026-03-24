class PlayerCharacterSummary {
  final int id;
  final String name;
  final int level;
  final String? raceName;
  final String? dndClassName;
  final int currentHp;
  final int maxHp;
  final int armorClass;
  final String? alignment;
  final int experiencePoints;
  final bool hasInspiration;

  PlayerCharacterSummary({
    required this.id,
    required this.name,
    required this.level,
    this.raceName,
    this.dndClassName,
    this.currentHp = 0,
    this.maxHp = 0,
    this.armorClass = 0,
    this.alignment,
    this.experiencePoints = 0,
    this.hasInspiration = false,   

  });

  factory PlayerCharacterSummary.fromJson(Map<String, dynamic> json) {
    return PlayerCharacterSummary(
      id:               (json['id'] as num).toInt(),
      name:             (json['name'] ?? '') as String,
      level:            (json['level'] as num?)?.toInt() ?? 1,
      raceName:         json['raceName'] as String?,
      dndClassName:     json['dndClassName'] as String?,
      currentHp:        (json['currentHp'] as num?)?.toInt() ?? 0,
      maxHp:            (json['maxHp'] as num?)?.toInt() ?? 0,
      armorClass:       (json['armorClass'] as num?)?.toInt() ?? 0,
      alignment:        json['alignment'] as String?,
      experiencePoints: (json['experiencePoints'] as num?)?.toInt() ?? 0,
      hasInspiration:   json['hasInspiration'] as bool? ?? false,
    );
  }
}