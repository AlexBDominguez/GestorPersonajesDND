import 'dart:convert';
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/models/character/racial_trait.dart';
import 'package:gestor_personajes_dnd/models/content_source.dart';
import 'package:gestor_personajes_dnd/models/wizard/feat_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/race_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/background_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/subrace_option.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';


class WizardReferenceService {
  final ApiClient _api;

  WizardReferenceService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  // Appends ?sources=PHB&sources=XGtE to a path when sources are provided.
  String _withSources(String base, List<String>? sources) {
    if (sources == null || sources.isEmpty) return base;
    final query = sources.map((s) => 'sources=$s').join('&');
    return '$base?$query';
  }

  Future<List<ContentSource>> getContentSources() async {
    final res = await _api.get('/api/content-sources');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ContentSource.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load content sources (${res.statusCode})');
  }

  Future<List<RaceOption>> getRaces({List<String>? sources}) async {
    final res = await _api.get(_withSources(ApiConfig.racesPath, sources));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => RaceOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load races (${res.statusCode})');
  }

  Future<List<ClassOption>> getClasses({List<String>? sources}) async {
    final res = await _api.get(_withSources(ApiConfig.classesPath, sources));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ClassOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load classes (${res.statusCode})');
  }

  Future<List<ClassFeature>> getClassFeatures(int classId) async {
    final res = await _api.get('${ApiConfig.classesPath}/$classId/features');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ClassFeature.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load features ($classId): ${res.statusCode}');
  }

  Future<List<SubclassOption>> getSubclasses(int classId, {List<String>? sources}) async {
    final base = '${ApiConfig.classesPath}/$classId/subclasses';
    final res = await _api.get(_withSources(base, sources));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SubclassOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load subclasses ($classId): ${res.statusCode}');
  }

  Future<List<SubraceOption>> getSubRaces(int raceId, {List<String>? sources}) async {
    final base = '/api/subraces/race/$raceId';
    final res = await _api.get(_withSources(base, sources));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SubraceOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (res.statusCode == 404) return [];
    throw Exception('Failed to load subraces ($raceId): ${res.statusCode}');
  }

  Future<List<RacialTrait>> getRacialTraits(int raceId) async {
    final res = await _api.get('/api/races/$raceId/traits');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((j) => RacialTrait.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load racial traits ($raceId): ${res.statusCode}');
  }

  Future<List<RacialTrait>> getSubraceTraits(int subraceId) async {
    final res = await _api.get('/api/races/subraces/$subraceId/traits');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((j) => RacialTrait.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load subrace traits ($subraceId): ${res.statusCode}');
  }

  Future<List<ClassFeature>> getSubclassFeatures(int subclassId) async {
    final res = await _api.get('/api/subclasses/$subclassId/features');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ClassFeature.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load subclass features ($subclassId): ${res.statusCode}');
  }

  Future<List<FeatOption>> getFeats() async {
    final res = await _api.get('/api/feats');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => FeatOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load feats (${res.statusCode})');
  }

  Future<List<BackgroundOption>> getBackgrounds({List<String>? sources}) async {
    final res = await _api.get(_withSources(ApiConfig.backgroundsPath, sources));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => BackgroundOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load backgrounds (${res.statusCode})');
  }

  Future<List<SpellOption>> getAvailableSpells({
    int? classId,
    int? subclassId,
    int? maxLevel,
    List<String>? sources,
  }) async {
    final params = <String, String>{};
    if (classId != null) params['classId'] = '$classId';
    if (subclassId != null) params['subclassId'] = '$subclassId';
    if (maxLevel != null) params['maxLevel'] = '$maxLevel';

    final sourcePart = sources != null && sources.isNotEmpty
        ? sources.map((s) => 'sources=$s').join('&')
        : '';

    final queryParts = [
      ...params.entries.map((e) => '${e.key}=${e.value}'),
      if (sourcePart.isNotEmpty) sourcePart,
    ];
    final query = queryParts.isNotEmpty ? '?${queryParts.join('&')}' : '';
    final res = await _api.get('/api/spells/available$query');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SpellOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load spells (${res.statusCode})');
  }
}
