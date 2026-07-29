// Multiclase (Aurora_Fixes.md #17): una de las clases de un personaje, con su propio
// nivel. classOrder 0 = clase original (la que dndClassId/level de PlayerCharacter reflejan).
class CharacterClassEntry {
  final int id;
  final int dndClassId;
  final String dndClassName;
  final int? subclassId;
  final String? subclassName;
  final int level;
  final int classOrder;

  const CharacterClassEntry({
    required this.id,
    required this.dndClassId,
    required this.dndClassName,
    this.subclassId,
    this.subclassName,
    required this.level,
    required this.classOrder,
  });

  factory CharacterClassEntry.fromJson(Map<String, dynamic> j) => CharacterClassEntry(
    id:           (j['id'] as num).toInt(),
    dndClassId:   (j['dndClassId'] as num).toInt(),
    dndClassName: j['dndClassName'] as String? ?? '',
    subclassId:   (j['subclassId'] as num?)?.toInt(),
    subclassName: j['subclassName'] as String?,
    level:        (j['level'] as num?)?.toInt() ?? 1,
    classOrder:   (j['classOrder'] as num?)?.toInt() ?? 0,
  );
}
