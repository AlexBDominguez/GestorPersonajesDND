import 'dart:convert';
import 'package:gestor_personajes_dnd/models/wizard/feat_option.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class FeatService {
  final ApiClient _api;
  FeatService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  Future<List<CharacterFeat>> getCharacterFeats(int characterId) async {
    final res = await _api.get('/api/characters/$characterId/feats');
    if (res.statusCode == 200){
      return (jsonDecode(res.body) as List)
          .map((e) => CharacterFeat.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load character feats (${res.statusCode})');
  }

  Future<void> assignFeat(int characterId, int featId,
      {String? notes}) async {
    final body = notes != null ? {'notes': notes} : <String, dynamic>{};
    final res = await _api.post(
        '/api/characters/$characterId/feats/$featId',
        body: body);
    if (res.statusCode == 200 || res.statusCode == 201) return;
    throw Exception('Failed to assign feat (${res.statusCode})');
  }

  Future<void> removeFeat(int characterId, int featId) async {
    final res = await _api.delete('/api/characters/$characterId/feats/$featId');
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('Failed to remove feat (${res.statusCode})');
  }
}