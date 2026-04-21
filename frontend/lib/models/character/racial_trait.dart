class RacialTrait {
  final int id;
  final String indexName;
  final String name;
  final String description;
  final String traitType; // "COMBAT" | "PASSIVE" | "CHOICE_REQUIRED"

  const RacialTrait({
    required this.id,
    required this.indexName,
    required this.name,
    required this.description,
    required this.traitType,
  });

  factory RacialTrait.fromJson(Map<String, dynamic> j) => RacialTrait(
    id:            (j['id'] as num).toInt(),
    indexName:     j['indexName'] as String? ?? '',
    name:          j['name'] as String? ?? '',
    description:   j['description'] as String? ?? '',
    traitType:     j['traitType'] as String? ?? 'PASSIVE',
  );

  bool get isCombatRelevant => traitType == 'COMBAT';
  bool get requiresChoice => traitType == 'CHOICE_REQUIRED';
}