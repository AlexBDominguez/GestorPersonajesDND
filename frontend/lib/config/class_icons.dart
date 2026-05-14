import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

final Map<String, IconData> kClassIcons = {
  'barbarian': MdiIcons.axeBattle,
  'bard': MdiIcons.musicClefTreble,
  'cleric': MdiIcons.cross,
  'druid': MdiIcons.leaf,
  'fighter': MdiIcons.sword,
  'monk': MdiIcons.yinYang,
  'paladin': MdiIcons.shieldSword,
  'ranger': MdiIcons.bowArrow,
  'rogue': MdiIcons.knifeMilitary,
  'sorcerer': MdiIcons.fire,
  'warlock': MdiIcons.skull,
  'wizard': MdiIcons.autoFix,
};

final Map<int, String> _classKeyById = {
  1: 'barbarian',
  2: 'bard',
  3: 'cleric',
  4: 'druid',
  5: 'fighter',
  6: 'monk',
  7: 'paladin',
  8: 'ranger',
  9: 'rogue',
  10: 'sorcerer',
  11: 'warlock',
  12: 'wizard',
};

final Map<String, String> _classAliases = {
  'barbaro': 'barbarian',
  'bardo': 'bard',
  'clerigo': 'cleric',
  'druida': 'druid',
  'guerrero': 'fighter',
  'monje': 'monk',
  'paladin': 'paladin',
  'paladino': 'paladin',
  'explorador': 'ranger',
  'picaro': 'rogue',
  'hechicero': 'sorcerer',
  'brujo': 'warlock',
  'mago': 'wizard',
};

String _normalizeClassKey(String raw) {
  final lower = raw.trim().toLowerCase();
  if (lower.isEmpty) return '';

  final deaccented = lower
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');

  final compact = deaccented
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return _classAliases[compact] ?? compact;
}

IconData classIcon(String classNameOrIndex, {int? classId}) {
  if (classId != null) {
    final keyFromId = _classKeyById[classId];
    if (keyFromId != null) {
      return kClassIcons[keyFromId] ?? MdiIcons.diceD6;
    }
  }

  final key = _normalizeClassKey(classNameOrIndex);
  return kClassIcons[key] ?? MdiIcons.diceD6;
}
