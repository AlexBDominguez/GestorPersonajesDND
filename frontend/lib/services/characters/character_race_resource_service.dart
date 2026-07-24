import 'dart:convert';

import 'package:gestor_personajes_dnd/models/character/character_class_resource.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

/// Mirrors CharacterClassResourceService, for the race-resource endpoints (#9 RaceResource).
/// Reuses the CharacterClassResource model -- CharacterRaceResourceDto (backend) serializes
/// to the exact same JSON shape on purpose, see its class comment.
class CharacterRaceResourceService {
  final ApiClient _api;
  CharacterRaceResourceService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<CharacterClassResource>> getResources(int characterId) async {
    final res = await _api.get('/api/characters/$characterId/race-resources');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list
          .map((j) => CharacterClassResource.fromJson(j as Map<String, dynamic>, isRaceResource: true))
          .toList();
    }
    throw Exception('Failed to load character race resources (${res.statusCode})');
  }

  Future<CharacterClassResource> spend(int characterId, String resourceIndexName, int amount) async {
    final res = await _api.post(
      '/api/characters/$characterId/race-resources/spend',
      body: {'resourceIndexName': resourceIndexName, 'amount': amount},
    );
    if (res.statusCode == 200) {
      return CharacterClassResource.fromJson(jsonDecode(res.body) as Map<String, dynamic>, isRaceResource: true);
    }
    throw Exception('Failed to spend race resource (${res.statusCode})');
  }

  Future<CharacterClassResource> recover(int characterId, String resourceIndexName, int amount) async {
    final res = await _api.post(
      '/api/characters/$characterId/race-resources/recover',
      body: {'resourceIndexName': resourceIndexName, 'amount': amount},
    );
    if (res.statusCode == 200) {
      return CharacterClassResource.fromJson(jsonDecode(res.body) as Map<String, dynamic>, isRaceResource: true);
    }
    throw Exception('Failed to recover race resource (${res.statusCode})');
  }
}
