import 'package:gestor_personajes_dnd/models/character/character_class_entry.dart';

class PlayerCharacterSummary {
  final int id;
  final String name;
  final int level;
  final String? raceName;
  final int? dndClassId;
  final String? dndClassName;
  final String? subclassName;
  final int currentHp;
  final int maxHp;
  final int armorClass;
  final String? alignment;
  final int experiencePoints;
  final bool hasInspiration;
  // Multiclase (Aurora_Fixes.md #17, fase 3): ya venía en el JSON de /api/characters desde
  // la fase 1 (PlayerCharacterService.convertToDto ya llama a setClasses) -- solo faltaba
  // leerlo aquí.
  final List<CharacterClassEntry> classes;

  PlayerCharacterSummary({
    required this.id,
    required this.name,
    required this.level,
    this.raceName,
    this.dndClassId,
    this.dndClassName,
    this.subclassName,
    this.currentHp = 0,
    this.maxHp = 0,
    this.armorClass = 0,
    this.alignment,
    this.experiencePoints = 0,
    this.hasInspiration = false,
    this.classes = const [],
  });

  factory PlayerCharacterSummary.fromJson(Map<String, dynamic> json) {
    return PlayerCharacterSummary(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      level: (json['level'] as num?)?.toInt() ?? 1,
      raceName: json['raceName'] as String?,
      dndClassId: (json['dndClassId'] as num?)?.toInt(),
      dndClassName: json['dndClassName'] as String?,
      subclassName: json['subclassName'] as String?,
      currentHp: (json['currentHp'] as num?)?.toInt() ?? 0,
      maxHp: (json['maxHp'] as num?)?.toInt() ?? 0,
      armorClass: (json['armorClass'] as num?)?.toInt() ?? 0,
      alignment: json['alignment'] as String?,
      experiencePoints: (json['experiencePoints'] as num?)?.toInt() ?? 0,
      hasInspiration: json['hasInspiration'] as bool? ?? false,
      classes: (json['classes'] as List<dynamic>? ?? [])
          .map((e) => CharacterClassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
