class FeatOption {
  final int id;
  final String indexName;
  final String name;
  final String? description;
  final List<String> prerequisites;

  const FeatOption({
    required this.id,
    required this.indexName,
    required this.name,
    this.description,
    required this.prerequisites,
  });

  factory FeatOption.fromJson(Map<String, dynamic> j) => FeatOption(
    id:               (j['id'] as num).toInt(),
    indexName:        j['indexName'] as String? ?? '',
    name:             j['name'] as String? ?? '',
    description:      j['description'] as String?,
    prerequisites:    List<String>.from(j['prerequisites'] ?? []),
  );
}

//Para la ficha (CharacterSheet)
class CharacterFeat {
  final int id;
  final int featId;
  final String name;
  final String? description;
  final int levelObtained;
  final String? notes;

  const CharacterFeat({
    required this.id,
    required this.featId,
    required this.name,
    this.description,
    required this.levelObtained,
    this.notes,
  });

  factory CharacterFeat.fromJson(Map<String, dynamic> j) => CharacterFeat(
        id:            (j['id'] as num).toInt(),
        featId:        (j['featId'] as num).toInt(),
        name:          j['featName'] as String? ?? '',
        description:   j['featDescription'] as String?,
        levelObtained: (j['levelObtained'] as num?)?.toInt() ?? 0,
        notes:         j['notes'] as String?,
      );
}
