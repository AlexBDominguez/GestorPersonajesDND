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
  // #9: true si viene de /race-resources en vez de /resources -- decide qué servicio hay que
  // llamar al gastar/recuperar (ver CharacterSheetViewModel._resourceServiceFor).
  final bool isRaceResource;

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
    this.isRaceResource = false,
  });

  factory CharacterClassResource.fromJson(Map<String, dynamic> j, {bool isRaceResource = false}) =>
      CharacterClassResource(
    id:                (j['id'] as num).toInt(),
    characterId:       (j['characterId'] as num).toInt(),
    characterName:     j['characterName'] as String? ?? '',
    classResourceId:   (j['classResourceId'] as num).toInt(),
    resourceName:      j['resourceName'] as String? ?? '',
    resourceIndexName: j['resourceIndexName'] as String? ?? '',
    maxAmount:         (j['maxAmount'] as num?)?.toInt() ?? 0,
    currentAmount:     (j['currentAmount'] as num?)?.toInt() ?? 0,
    recoveryType:      j['recoveryType'] as String? ?? '',
    isRaceResource:    isRaceResource,
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
    isRaceResource: isRaceResource,
  );
}
