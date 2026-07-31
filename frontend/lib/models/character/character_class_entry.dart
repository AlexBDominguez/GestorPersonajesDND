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

/// Multiclase (Aurora_Fixes.md #17, fase 3): resumen de clase(s) para mostrar en la UI --
/// "Barbarian · Lvl 5" para mono-clase (idéntico al formato de siempre), "Barbarian 3 /
/// Druid 2" para multiclase. `fallback*` cubre el caso defensivo de `classes` vacío (no
/// debería pasar tras el backfill de la fase 1, pero evita un string vacío si pasara).
String formatClassSummary(
  List<CharacterClassEntry> classes, {
  String? fallbackClassName,
  int? fallbackLevel,
}) {
  if (classes.isEmpty) {
    if (fallbackClassName == null) {
      return fallbackLevel != null ? 'Lvl $fallbackLevel' : '';
    }
    return fallbackLevel != null
        ? '$fallbackClassName · Lvl $fallbackLevel'
        : fallbackClassName;
  }
  if (classes.length == 1) {
    return '${classes.first.dndClassName} · Lvl ${classes.first.level}';
  }
  final sorted = [...classes]..sort((a, b) => a.classOrder.compareTo(b.classOrder));
  return sorted.map((c) => '${c.dndClassName} ${c.level}').join(' / ');
}
