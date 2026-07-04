import 'dart:convert';

import 'package:gestor_personajes_dnd/models/character/character_class_resource.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class CharacterClassResourceService {
  final ApiClient _api;
  CharacterClassResourceService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<CharacterClassResource>> getResources(int characterId) async {
    final res = await _api.get('/api/characters/$characterId/resources');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list
          .map((j) => CharacterClassResource.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load character resources (${res.statusCode})');
  }

  Future<CharacterClassResource> spend(int characterId, String resourceIndexName, int amount) async {
    final res = await _api.post(
      '/api/characters/$characterId/resources/spend',
      body: {'resourceIndexName': resourceIndexName, 'amount': amount},
    );
    if (res.statusCode == 200) {
      return CharacterClassResource.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to spend resource (${res.statusCode})');
  }

  Future<CharacterClassResource> recover(int characterId, String resourceIndexName, int amount) async {
    final res = await _api.post(
      '/api/characters/$characterId/resources/recover',
      body: {'resourceIndexName': resourceIndexName, 'amount': amount},
    );
    if (res.statusCode == 200) {
      return CharacterClassResource.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to recover resource (${res.statusCode})');
  }

  Future<void> initialize(int characterId) async {
    final res = await _api.post('/api/characters/$characterId/resources/initialize');
    if (res.statusCode != 200) {
      throw Exception('Failed to initialize resources (${res.statusCode})');
    }
  }

  Future<void> updateMaximums(int characterId) async {
    final res = await _api.post('/api/characters/$characterId/resources/update-maximums');
    if (res.statusCode != 200) {
      throw Exception('Failed to update resource maximums (${res.statusCode})');
    }
  }
}
