import 'dart:convert';

class PendingTask{
  final int id;
  final String taskType;
  final int relatedLevel;
  final String description;
  final bool completed;
  final String? metadata;
  // Multiclase (Aurora_Fixes.md #17, fase 2a): clase que originó esta tarea. Null para
  // personajes mono-clase y tareas creadas antes de esta fase.
  final int? dndClassId;
  final String? dndClassName;

  const PendingTask({
    required this.id,
    required this.taskType,
    required this.relatedLevel,
    required this.description,
    required this.completed,
    this.metadata,
    this.dndClassId,
    this.dndClassName,
  });

  factory PendingTask.fromJson(Map<String, dynamic> j) => PendingTask(
    id:           (j['id'] as num).toInt(),
    taskType:     j['taskType'] as String? ?? '',
    relatedLevel: (j['relatedLevel'] as num?)?.toInt() ?? 1,
    description:  j['description'] as String? ?? '',
    completed:    j['completed'] as bool? ?? false,
    metadata:     j['metadata'] as String?,
    dndClassId:   (j['dndClassId'] as num?)?.toInt(),
    dndClassName: j['dndClassName'] as String?,
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
      case 'EXTRA_LANGUAGE':    return '🗣️';
      case 'HIGH_ELF_CANTRIP':      return '✦';
      case 'SKILL_VERSATILITY_1': return '🎯';
      case 'SKILL_VERSATILITY_2': return '🎯';
      case 'TOOL_PROFICIENCY':    return '🔨';
      case 'EXPERTISE':         return '📚';
      case 'ASI_OR_FEAT':       return '⬆️';
      case 'CHOOSE_SUBCLASS':   return '🏛️';
      case 'LEARN_SPELLS':      return '✨';
      case 'METAMAGIC':         return '🌀';
      case 'INVOCATION':        return '👁️';
      case 'MANEUVER_CHOICE':   return '⚔️';
      case 'RUNE_CHOICE':       return '🪨';
      case 'TOTEM_SPIRIT':      return '🐻';
      case 'TOTEM_ASPECT':      return '🦅';
      case 'TOTEM_ATTUNEMENT':  return '🐺';
      case 'HUNTERS_PREY':      return '🎯';
      case 'DEFENSIVE_TACTICS': return '🛡️';
      case 'HUNTER_MULTIATTACK': return '🏹';
      case 'SUPERIOR_HUNTERS_DEFENSE': return '🌿';
      case 'ELEMENTAL_DISCIPLINE': return '🌊';
      case 'RACIAL_ASI_CHOICE':         return '⬆️';
      case 'LAND_TYPE_CHOICE':         return '🌍';
      case 'KNOWLEDGE_DOMAIN_SKILLS':  return '📚';
      case 'NATURE_DOMAIN_CANTRIP':    return '🌿';
      case 'LORE_BARD_SKILLS':         return '🎶';
      case 'BATTLE_MASTER_TOOL':       return '🔨';
      case 'LYCAN_TYPE':               return '🐺';
      case 'PROFANE_SOUL_PATRON':      return '👁️';
      case 'INFUSION_CHOICE':          return '🔧';
      case 'ADDITIONAL_MAGICAL_SECRETS': return '📖';
      default:                         return '📋';
    }
  }

  String get displayName {
    switch (taskType) {
      case 'FIGHTING_STYLE':    return 'Fighting Style';
      case 'FAVORED_ENEMY':     return 'Favored Enemy';
      case 'FAVORED_TERRAIN':   return 'Favored Terrain';
      case 'DRACONIC_ANCESTRY': return 'Draconic Ancestry';
      case 'EXTRA_LANGUAGE':    return 'Extra Language';
      case 'HIGH_ELF_CANTRIP':      return 'High Elf Cantrip';
      case 'SKILL_VERSATILITY_1': return 'Skill Versatility (1st Skill)';
      case 'SKILL_VERSATILITY_2': return 'Skill Versatility (2nd Skill)';
      case 'TOOL_PROFICIENCY':    return 'Tool Proficiency';
      case 'EXPERTISE':         return 'Expertise';
      case 'ASI_OR_FEAT':       return 'Ability Score Improvement';
      case 'CHOOSE_SUBCLASS':   return 'Choose Subclass';
      case 'LEARN_SPELLS':      return 'Learn Spells';
      case 'METAMAGIC':         return 'Metamagic';
      case 'INVOCATION':        return 'Eldritch Invocation';
      case 'MANEUVER_CHOICE':   return 'Battle Master Maneuvers';
      case 'RUNE_CHOICE':       return 'Rune Knight Runes';
      case 'TOTEM_SPIRIT':      return 'Totem Spirit';
      case 'TOTEM_ASPECT':      return 'Aspect of the Beast';
      case 'TOTEM_ATTUNEMENT':  return 'Totemic Attunement';
      case 'HUNTERS_PREY':      return "Hunter's Prey";
      case 'DEFENSIVE_TACTICS': return 'Defensive Tactics';
      case 'HUNTER_MULTIATTACK': return 'Multiattack (Hunter)';
      case 'SUPERIOR_HUNTERS_DEFENSE': return "Superior Hunter's Defense";
      case 'ELEMENTAL_DISCIPLINE': return 'Elemental Discipline';
      case 'RACIAL_ASI_CHOICE':         return 'Racial Ability Score Increase';
      case 'LAND_TYPE_CHOICE':         return 'Circle of the Land';
      case 'KNOWLEDGE_DOMAIN_SKILLS':  return 'Knowledge Domain Skills';
      case 'NATURE_DOMAIN_CANTRIP':    return 'Nature Domain Cantrip';
      case 'LORE_BARD_SKILLS':         return 'College of Lore Skills';
      case 'BATTLE_MASTER_TOOL':       return 'Battle Master Proficiency';
      case 'LYCAN_TYPE':               return 'Lycanthrope Type';
      case 'PROFANE_SOUL_PATRON':      return 'Otherworldly Patron';
      case 'INFUSION_CHOICE':          return 'Artificer Infusions';
      case 'ADDITIONAL_MAGICAL_SECRETS': return 'Additional Magical Secrets';
      default:                         return taskType;
    }
  }
}