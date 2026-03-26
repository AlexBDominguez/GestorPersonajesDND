class RaceOption {
  final int id;
  final String indexName;
  final String name;
  final int speed;
  final String size;
  final Map<String, int> abilityBonuses;
  final String description;

  const RaceOption({
    required this.id,
    required this.indexName,
    required this.name,
    required this.speed,
    required this.size,
    required this.abilityBonuses,
    required this.description
  });

  factory RaceOption.fromJson(Map<String, dynamic> j) => RaceOption(
    id: j['id'] as int,
    indexName: j['indexName'] as String,
    name: j['name'] as String,
    speed: j['speed'] as int? ?? 30,
    size: j['size'] as String? ?? 'Medium',
    abilityBonuses: Map<String, int>.from(j['abilityBonuses'] as Map? ?? {}),
    description: j['description'] as String? ?? '',
  );

  /// Texto de bonos formateado: "+2 STR, +1 DEX"
  String get bonusText => abilityBonuses.entries
      .map((e) => '+${e.value} ${e.key.toUpperCase()}')
      .join(', ');
}