class PlayerCharacterSummary {
  final int id;
  final String name;
  final int level;

  PlayerCharacterSummary({
    required this.id,
    required this.name,
    required this.level,
  });

  factory PlayerCharacterSummary.fromJson(Map<String, dynamic> json) {
    return PlayerCharacterSummary(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      level: (json['level'] as num?)?.toInt() ?? 1,
    );
  }
}