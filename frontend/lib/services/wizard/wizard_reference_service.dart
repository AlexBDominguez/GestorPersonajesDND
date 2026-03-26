
import 'dart:convert';
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/models/wizard/race_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/background_option.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';


class WizardReferenceService {
  final ApiClient _api;

  WizardReferenceService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();


  Future<List<RaceOption>> getRaces() async {
    final res = await _api.get(ApiConfig.racesPath);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => RaceOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load races (${res.statusCode})');
  }

  Future<List<ClassOption>>getClasses() async{
    final res = await _api.get(ApiConfig.classesPath);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ClassOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load classes (${res.statusCode})');    
  }

  Future<List<ClassFeature>> getClassFeatures(int classId) async{
    final res = await _api.get('${ApiConfig.classesPath}/$classId/features');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => ClassFeature.fromJson(e as Map<String, dynamic>))
          .toList();
    }
      throw Exception('Failed to load features ($classId): ${res.statusCode}');
  }

  Future<List<SubclassOption>> getSubclasses(int classId) async {
    final res = await _api.get('${ApiConfig.classesPath}/$classId/subclasses');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SubclassOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load subclasses ($classId): ${res.statusCode}');
  }

  Future<List<BackgroundOption>> getBackgrounds() async{
    final res = await _api.get(ApiConfig.backgroundsPath);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => BackgroundOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load backgrounds (${res.statusCode})');
  }
}