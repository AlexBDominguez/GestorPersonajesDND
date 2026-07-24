import 'dart:convert';

import 'package:gestor_personajes_dnd/services/http/api_client.dart';

/// Subclase para el selector del formulario de admin (#9) -- incluye el nombre de la clase
/// base para poder mostrar "Champion (Fighter)" en un desplegable plano de todas las subclases.
class SubclassAdminOption {
  final int id;
  final String name;
  final String className;

  const SubclassAdminOption({required this.id, required this.name, required this.className});

  factory SubclassAdminOption.fromJson(Map<String, dynamic> j) => SubclassAdminOption(
        id:        (j['id'] as num).toInt(),
        name:      j['name'] as String? ?? '',
        className: j['className'] as String? ?? '',
      );

  String get label => className.isEmpty ? name : '$name ($className)';
}

class SpellSearchOption {
  final int id;
  final String name;
  final int level;

  const SpellSearchOption({required this.id, required this.name, required this.level});

  factory SpellSearchOption.fromJson(Map<String, dynamic> j) => SpellSearchOption(
        id:    (j['id'] as num).toInt(),
        name:  j['name'] as String? ?? '',
        level: (j['level'] as num?)?.toInt() ?? 0,
      );

  String get label => level == 0 ? '$name (cantrip)' : '$name (level $level)';
}

class ProficiencySearchOption {
  final int id;
  final String name;
  final String? type;

  const ProficiencySearchOption({required this.id, required this.name, this.type});

  factory ProficiencySearchOption.fromJson(Map<String, dynamic> j) => ProficiencySearchOption(
        id:   (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
        type: j['type'] as String?,
      );

  String get label => type == null ? name : '$name ($type)';
}

/// Resultado de crear una SubclassFeature (#9) -- solo lo que la pantalla necesita confirmar.
class SubclassFeatureResult {
  final int id;
  final String name;
  final int level;

  const SubclassFeatureResult({required this.id, required this.name, required this.level});

  factory SubclassFeatureResult.fromJson(Map<String, dynamic> j) => SubclassFeatureResult(
        id:    (j['id'] as num).toInt(),
        name:  j['name'] as String? ?? '',
        level: (j['level'] as num?)?.toInt() ?? 0,
      );
}

/// Servicio del panel de admin (#9) para creación manual de contenido -- por ahora, solo
/// features de subclase con su mecánica de #8.2. Separado de AdminService (gestión de
/// usuarios) porque es un dominio distinto.
class ContentAdminService {
  final ApiClient _api;
  ContentAdminService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<SubclassAdminOption>> getAllSubclasses() async {
    final res = await _api.get('/api/subclasses');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SubclassAdminOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load subclasses (${res.statusCode})');
  }

  Future<List<SpellSearchOption>> searchSpells(String name) async {
    if (name.trim().isEmpty) return [];
    final res = await _api.get('/api/spells/search?name=${Uri.encodeQueryComponent(name)}');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SpellSearchOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to search spells (${res.statusCode})');
  }

  Future<List<ProficiencySearchOption>> searchProficiencies(String name) async {
    if (name.trim().isEmpty) return [];
    final res = await _api.get('/api/proficiencies?name=${Uri.encodeQueryComponent(name)}');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ProficiencySearchOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to search proficiencies (${res.statusCode})');
  }

  Future<SubclassFeatureResult> createSubclassFeature({
    required int subclassId,
    required String indexName,
    required String name,
    required int level,
    required String description,
    required String mechanicType,
    String? resourceMaxFormula,
    String? resourceRecoveryType,
    String? bonusTargetField,
    String? bonusFormula,
    String? bonusCondition,
    int? spellId,
    int? proficiencyId,
  }) async {
    final res = await _api.post(
      '/api/subclasses/$subclassId/features',
      body: {
        'indexName': indexName,
        'name': name,
        'level': level,
        'description': description,
        'mechanicType': mechanicType,
        if (resourceMaxFormula != null) 'resourceMaxFormula': resourceMaxFormula,
        if (resourceRecoveryType != null) 'resourceRecoveryType': resourceRecoveryType,
        if (bonusTargetField != null) 'bonusTargetField': bonusTargetField,
        if (bonusFormula != null) 'bonusFormula': bonusFormula,
        if (bonusCondition != null) 'bonusCondition': bonusCondition,
        if (spellId != null) 'spellId': spellId,
        if (proficiencyId != null) 'proficiencyId': proficiencyId,
      },
    );
    if (res.statusCode == 200) {
      return SubclassFeatureResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    if (res.statusCode == 409) {
      throw Exception('That indexName is already in use. Please choose a different one.');
    }
    final body = res.body;
    String msg = 'Failed to create feature (${res.statusCode})';
    if (body.isNotEmpty) {
      try { final decoded = jsonDecode(body); msg = decoded is String ? decoded : msg; } catch (_) { msg = body; }
    }
    throw Exception(msg);
  }
}
