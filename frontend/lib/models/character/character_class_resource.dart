class CharacterClassResource {
  final int id;
  final int characterId;
  final String characterName;
  final int classResourceId;
  final String resourceName;
  final String resourceIndexName;
  final int maxAmount;
  final int currentAmount;
  final String recoveryType;

  const CharacterClassResource({
    required this.id,
    required this.characterId,
    required this.characterName,
    required this.classResourceId,
    required this.resourceName,
    required this.resourceIndexName,
    required this.maxAmount,
    required this.currentAmount,
    required this.recoveryType,
  });

  factory CharacterClassResource.fromJson(Map<String, dynamic> j) => CharacterClassResource(
    id:                (j['id'] as num).toInt(),
    characterId:       (j['characterId'] as num).toInt(),
    characterName:     j['characterName'] as String? ?? '',
    classResourceId:   (j['classResourceId'] as num).toInt(),
    resourceName:      j['resourceName'] as String? ?? '',
    resourceIndexName: j['resourceIndexName'] as String? ?? '',
    maxAmount:         (j['maxAmount'] as num?)?.toInt() ?? 0,
    currentAmount:     (j['currentAmount'] as num?)?.toInt() ?? 0,
    recoveryType:      j['recoveryType'] as String? ?? '',
  );

  CharacterClassResource copyWith({int? currentAmount, int? maxAmount}) => CharacterClassResource(
    id: id,
    characterId: characterId,
    characterName: characterName,
    classResourceId: classResourceId,
    resourceName: resourceName,
    resourceIndexName: resourceIndexName,
    maxAmount: maxAmount ?? this.maxAmount,
    currentAmount: currentAmount ?? this.currentAmount,
    recoveryType: recoveryType,
  );
}
