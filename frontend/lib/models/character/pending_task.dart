import 'dart:convert';

class PendingTask{
  final int id;
  final String taskType;
  final int relatedLevel;
  final String description;
  final bool completed;
  final String? metadata;

  const PendingTask({
    required this.id,
    required this.taskType,
    required this.relatedLevel,
    required this.description,
    required this.completed,
    this.metadata
  });

  factory PendingTask.fromJson(Map<String, dynamic> j) => PendingTask(
    id:           (j['id'] as num).toInt(),
    taskType:     j['taskType'] as String? ?? '',
    relatedLevel: (j['relatedLevel'] as num?)?.toInt() ?? 1,
    description:  j['description'] as String? ?? '',
    completed:    j['completed'] as bool? ?? false,
    metadata:     j['metadata'] as String?,
  );

  ///Si la tarea ya tiene una elección resuelta, la extrae del metadata.
  
  String? get resolvedChoice {
    if (metadata == null || metadata!.isEmpty) return null;
    try {
      final m = jsonDecode(metadata!) as Map<String, dynamic>;
      return m['choice'] as String?;
    } catch (_) {
      return null;
    }
  }

  ///Icono representativo por tipo de tarea
  String get icon {
    switch (taskType) {
      case 'FIGHTING_STYLE':    return '⚔️';
      case 'FAVORED_ENEMY':     return '🎯';
      case 'FAVORED_TERRAIN':   return '🌲';
      case 'DRACONIC_ANCESTRY': return '🐉';
      case 'EXPERTISE':         return '📚';
      case 'ASI_OR_FEAT':       return '⬆️';
      case 'CHOOSE_SUBCLASS':   return '🏛️';
      case 'LEARN_SPELLS':      return '✨';
      case 'METAMAGIC':         return '🌀';
      case 'INVOCATION':        return '👁️';
      default:                  return '📋';
    }
  }

  String get displayName {
    switch (taskType) {
      case 'FIGHTING_STYLE':    return 'Fighting Style';
      case 'FAVORED_ENEMY':     return 'Favored Enemy';
      case 'FAVORED_TERRAIN':   return 'Favored Terrain';
      case 'DRACONIC_ANCESTRY': return 'Draconic Ancestry';
      case 'EXPERTISE':         return 'Expertise';
      case 'ASI_OR_FEAT':       return 'Ability Score Improvement';
      case 'CHOOSE_SUBCLASS':   return 'Choose Subclass';
      case 'LEARN_SPELLS':      return 'Learn Spells';
      case 'METAMAGIC':         return 'Metamagic';
      case 'INVOCATION':        return 'Eldritch Invocation';
      default:                  return taskType;
    }
  }
}