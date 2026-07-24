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

/// Clase base, para el desplegable del formulario "Create Subclass" (#9).
class ClassAdminOption {
  final int id;
  final String name;

  const ClassAdminOption({required this.id, required this.name});

  factory ClassAdminOption.fromJson(Map<String, dynamic> j) => ClassAdminOption(
        id:   (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
      );
}

/// Raza base, para el desplegable del formulario "Create Subrace" (#9).
class RaceAdminOption {
  final int id;
  final String name;

  const RaceAdminOption({required this.id, required this.name});

  factory RaceAdminOption.fromJson(Map<String, dynamic> j) => RaceAdminOption(
        id:   (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
      );
}

/// Subraza, para el desplegable en cascada Race -> Subrace del formulario de features (#9).
class SubraceAdminOption {
  final int id;
  final String name;

  const SubraceAdminOption({required this.id, required this.name});

  factory SubraceAdminOption.fromJson(Map<String, dynamic> j) => SubraceAdminOption(
        id:   (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
      );
}

/// Resultado genérico de crear cualquier tipo de contenido (#9) -- solo lo que la pantalla
/// necesita confirmar (nombre, para el snackbar de éxito).
class ContentCreateResult {
  final int id;
  final String name;

  const ContentCreateResult({required this.id, required this.name});

  factory ContentCreateResult.fromJson(Map<String, dynamic> j) => ContentCreateResult(
        id:   (j['id'] as num).toInt(),
        name: j['name'] as String? ?? '',
      );
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

  // #9: crea una ClassFeature (clase base) -- no admite GRANT_PROFICIENCY (sin tabla de
  // "class proficiency grant" en el esquema, ver AdminClassFeatureService).
  Future<SubclassFeatureResult> createClassFeature({
    required int classId,
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
  }) async {
    final res = await _api.post(
      '/api/classes/$classId/features',
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

  // #9: crea un RacialTrait con su mecánica (#8.2 generalizado a razas), atado a una Race o
  // Subrace. GRANT_SPELL usa RacialTraitSpell (con su propio requiredLevel, ver
  // AdminRacialTraitService) -- funciona igual para Race y Subrace.
  Future<ContentCreateResult> createRacialTrait({
    required String targetType, // "RACE" | "SUBRACE"
    required int targetId,
    required String indexName,
    required String name,
    required String description,
    required String traitType,
    required String mechanicType,
    String? resourceMaxFormula,
    String? resourceRecoveryType,
    String? bonusTargetField,
    String? bonusFormula,
    String? bonusCondition,
    int? spellId,
    int spellRequiredLevel = 1,
    int? proficiencyId,
  }) async {
    final res = await _api.post(
      '/api/races/traits',
      body: {
        'targetType': targetType,
        'targetId': targetId,
        'indexName': indexName,
        'name': name,
        'description': description,
        'traitType': traitType,
        'mechanicType': mechanicType,
        if (resourceMaxFormula != null) 'resourceMaxFormula': resourceMaxFormula,
        if (resourceRecoveryType != null) 'resourceRecoveryType': resourceRecoveryType,
        if (bonusTargetField != null) 'bonusTargetField': bonusTargetField,
        if (bonusFormula != null) 'bonusFormula': bonusFormula,
        if (bonusCondition != null) 'bonusCondition': bonusCondition,
        if (spellId != null) 'spellId': spellId,
        'spellRequiredLevel': spellRequiredLevel,
        if (proficiencyId != null) 'proficiencyId': proficiencyId,
      },
    );
    if (res.statusCode == 200) {
      return ContentCreateResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    if (res.statusCode == 409) {
      throw Exception('That indexName is already in use. Please choose a different one.');
    }
    final body = res.body;
    String msg = 'Failed to create trait (${res.statusCode})';
    if (body.isNotEmpty) {
      try { final decoded = jsonDecode(body); msg = decoded is String ? decoded : msg; } catch (_) { msg = body; }
    }
    throw Exception(msg);
  }

  // ── Listas para desplegables ────────────────────────────────────────────

  Future<List<ClassAdminOption>> getAllClasses() async {
    final res = await _api.get('/api/classes');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ClassAdminOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load classes (${res.statusCode})');
  }

  Future<List<RaceAdminOption>> getAllRacesForAdmin() async {
    final res = await _api.get('/api/races');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => RaceAdminOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load races (${res.statusCode})');
  }

  Future<List<SubraceAdminOption>> getSubracesForRace(int raceId) async {
    final res = await _api.get('/api/subraces/race/$raceId');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SubraceAdminOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load subraces (${res.statusCode})');
  }

  // ── Creación de contenido ────────────────────────────────────────────────

  Future<ContentCreateResult> _post(String path, Map<String, dynamic> body) async {
    final res = await _api.post(path, body: body);
    if (res.statusCode == 200) {
      return ContentCreateResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    if (res.statusCode == 409) {
      throw Exception('That indexName is already in use. Please choose a different one.');
    }
    final resBody = res.body;
    String msg = 'Failed to create (${res.statusCode})';
    if (resBody.isNotEmpty) {
      try { final decoded = jsonDecode(resBody); msg = decoded is String ? decoded : msg; } catch (_) { msg = resBody; }
    }
    throw Exception(msg);
  }

  Future<ContentCreateResult> createClass({
    required String indexName,
    required String name,
    required int hitDie,
    required List<String> proficiencies,
    required String description,
  }) =>
      _post('/api/classes', {
        'indexName': indexName,
        'name': name,
        'hitDie': hitDie,
        'proficiencies': proficiencies,
        'description': description,
      });

  Future<ContentCreateResult> createSubclass({
    required int classId,
    required String indexName,
    required String name,
    required String subclassFlavor,
    required String description,
    String? spellcastingAbility,
  }) =>
      _post('/api/subclasses', {
        'classId': classId,
        'indexName': indexName,
        'name': name,
        'subclassFlavor': subclassFlavor,
        'description': description,
        if (spellcastingAbility != null && spellcastingAbility.isNotEmpty)
          'spellcastingAbility': spellcastingAbility,
      });

  Future<ContentCreateResult> createRace({
    required String indexName,
    required String name,
    required String size,
    required int speed,
    required Map<String, int> abilityBonuses,
    required String description,
  }) =>
      _post('/api/races', {
        'indexName': indexName,
        'name': name,
        'size': size,
        'speed': speed,
        'abilityBonuses': abilityBonuses,
        'description': description,
      });

  Future<ContentCreateResult> createSubrace({
    required int raceId,
    required String indexName,
    required String name,
    required Map<String, int> abilityBonuses,
    required String description,
  }) =>
      _post('/api/subraces', {
        'raceId': raceId,
        'indexName': indexName,
        'name': name,
        'abilityBonuses': abilityBonuses,
        'description': description,
      });

  Future<ContentCreateResult> createItem({
    required String indexName,
    required String name,
    required String itemType,
    required String category,
    required double weight,
    required int costInCopper,
    required String description,
    String? damageDice,
    String? damageType,
    String? weaponRange,
    List<String>? weaponProperties,
    int? armorClass,
    String? armorType,
    String? rarity,
    bool requiresAttunement = false,
    int bonusAc = 0,
    int bonusToHit = 0,
    int bonusDamage = 0,
    int bonusSavingThrows = 0,
    int? setStrTo,
    int? setDexTo,
    int? setConTo,
    int? setIntTo,
    int? setWisTo,
    int? setChaTo,
  }) =>
      _post('/api/items', {
        'indexName': indexName,
        'name': name,
        'itemType': itemType,
        'category': category,
        'weight': weight,
        'costInCopper': costInCopper,
        'description': description,
        if (damageDice != null) 'damageDice': damageDice,
        if (damageType != null) 'damageType': damageType,
        if (weaponRange != null) 'weaponRange': weaponRange,
        if (weaponProperties != null) 'weaponProperties': weaponProperties,
        if (armorClass != null) 'armorClass': armorClass,
        if (armorType != null) 'armorType': armorType,
        if (rarity != null) 'rarity': rarity,
        'requiresAttunement': requiresAttunement,
        'bonusAc': bonusAc,
        'bonusToHit': bonusToHit,
        'bonusDamage': bonusDamage,
        'bonusSavingThrows': bonusSavingThrows,
        if (setStrTo != null) 'setStrTo': setStrTo,
        if (setDexTo != null) 'setDexTo': setDexTo,
        if (setConTo != null) 'setConTo': setConTo,
        if (setIntTo != null) 'setIntTo': setIntTo,
        if (setWisTo != null) 'setWisTo': setWisTo,
        if (setChaTo != null) 'setChaTo': setChaTo,
      });

  Future<ContentCreateResult> createBackground({
    required String indexName,
    required String name,
    required String description,
    List<String>? skillProficiencies,
    List<String>? toolProficiencies,
    List<String>? languages,
    int languageOptions = 0,
    String? feature,
    String? featureDescription,
    List<String>? personalityTraits,
    List<String>? ideals,
    List<String>? bonds,
    List<String>? flaws,
  }) =>
      _post('/api/backgrounds', {
        'indexName': indexName,
        'name': name,
        'description': description,
        if (skillProficiencies != null) 'skillProficiencies': skillProficiencies,
        if (toolProficiencies != null) 'toolProficiencies': toolProficiencies,
        if (languages != null) 'languages': languages,
        'languageOptions': languageOptions,
        if (feature != null) 'feature': feature,
        if (featureDescription != null) 'featureDescription': featureDescription,
        if (personalityTraits != null) 'personalityTraits': personalityTraits,
        if (ideals != null) 'ideals': ideals,
        if (bonds != null) 'bonds': bonds,
        if (flaws != null) 'flaws': flaws,
      });

  // #9: creación manual de feats homebrew. effectModifierType/Value son el bono numérico
  // genérico de fallback que ya lee PendingTaskService.applyFeatEffects (ver Feat.java) --
  // feats con lógica más compleja seguirán necesitando código dedicado, igual que hoy.
  Future<ContentCreateResult> createFeat({
    required String indexName,
    required String name,
    required String description,
    List<String>? prerequisites,
    String? effectModifierType,
    String? effectModifierValue,
    int? choiceProficiencyCount,
    List<int>? grantedSpellIds,
  }) =>
      _post('/api/feats', {
        'indexName': indexName,
        'name': name,
        'description': description,
        if (prerequisites != null) 'prerequisites': prerequisites,
        if (effectModifierType != null) 'effectModifierType': effectModifierType,
        if (effectModifierValue != null) 'effectModifierValue': effectModifierValue,
        if (choiceProficiencyCount != null) 'choiceProficiencyCount': choiceProficiencyCount,
        if (grantedSpellIds != null) 'grantedSpellIds': grantedSpellIds,
      });
}
