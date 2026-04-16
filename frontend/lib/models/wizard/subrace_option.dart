
class SubraceOption {
  final int id;
  final String indexName;
  final String name;
  final int raceId;
  final String? description;
  final Map<String, int> abilityBonuses;
  final List<String> traits;

  const SubraceOption({
    required this.id,
    required this.indexName,
    required this.name,
    required this.raceId,
    this.description,
    required this.abilityBonuses,
    required this.traits,
  });

  factory SubraceOption.fromJson(Map<String, dynamic> j) => SubraceOption(
    id:               (j['id'] as num).toInt(),
    indexName:        (j['indexName'] as String?) ?? '',
    name:             (j['name'] as String?) ?? '',
    raceId:           (j['raceId'] as num).toInt(),
    description:      (j['description'] as String?),
    abilityBonuses:   Map<String, int>.from(j['abilityBonuses'] as Map? ?? {}),
    traits:           List<String>.from(j['traits'] ?? []),

  );
  String get bonusText => abilityBonuses.entries
      .map((e) => '+${e.value} ${e.key.toUpperCase()}')
      .join(', ');
}
