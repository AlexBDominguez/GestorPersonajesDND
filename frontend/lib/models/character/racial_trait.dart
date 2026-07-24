class RacialTrait {
  final int id;
  final String indexName;
  final String name;
  final String description;
  final String traitType; // "COMBAT" | "PASSIVE" | "CHOICE_REQUIRED"
  // #9: mismo propósito que ClassFeature.consumesResourceIndexName/grantsBonusKey,
  // generalizado a rasgos raciales (#8.2 RESOURCE_POOL/NUMERIC_BONUS).
  final String? consumesResourceIndexName;
  final String? grantsBonusKey;

  const RacialTrait({
    required this.id,
    required this.indexName,
    required this.name,
    required this.description,
    required this.traitType,
    this.consumesResourceIndexName,
    this.grantsBonusKey,
  });

  factory RacialTrait.fromJson(Map<String, dynamic> j) => RacialTrait(
    id:            (j['id'] as num).toInt(),
    indexName:     j['indexName'] as String? ?? '',
    name:          j['name'] as String? ?? '',
    description:   j['description'] as String? ?? '',
    traitType:     j['traitType'] as String? ?? 'PASSIVE',
    consumesResourceIndexName: j['consumesResourceIndexName'] as String?,
    grantsBonusKey:            j['grantsBonusKey'] as String?,
  );

  bool get isCombatRelevant => traitType == 'COMBAT';
  bool get requiresChoice => traitType == 'CHOICE_REQUIRED';
}