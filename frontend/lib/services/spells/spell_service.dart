import 'dart:convert';

import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class SpellService {
  final ApiClient _api;
  SpellService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  // Spells disponibles para una clase/subclase - reutiliza el mismo endpoint del wizard
  Future<List<SpellOption>> getAvailableSpells({
    int? classId,
    int? subclassId,
    int? maxLevel,    
  }) async {
    final params = <String, String>{};
    if (classId != null) params['classId'] = '$classId';
    if (subclassId != null) params['subclassId'] = '$subclassId';
    if (maxLevel != null) params['maxLevel'] = '$maxLevel';

    final query = params.isNotEmpty
        ? '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&')
        : '';

    final res = await _api.get('/api/spells/available$query');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => SpellOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load spells ($res.statusCode)');
  }

  //POST aprender un spell (añadirlo al personaje)
  Future<void> learnSpell({
    required int characterId,
    required int spellId,
  }) async {
    final res = await _api.post(
      '/api/characters/$characterId/learn-spell/$spellId',
    );
    if (res.statusCode == 200 || res.statusCode == 204) return;
    if (res.statusCode == 401) throw Exception('Unauthorized');
    if (res.statusCode == 403) throw Exception('Access denied');
    if (res.statusCode == 404) throw Exception('Spell not found');
    if (res.statusCode == 409) throw Exception('Spell already learned');
    throw Exception('Failed to learn spell (${res.statusCode})');
  }
}