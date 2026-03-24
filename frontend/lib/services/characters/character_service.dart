import 'dart:convert';
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class CharacterService {
  final ApiClient _api;

  CharacterService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  // GET list
  Future<List<PlayerCharacterSummary>> getMyCharacters() async {
    final res = await _api.get(ApiConfig.charactersPath);

    if(res.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(res.body) as List<dynamic>;
      return jsonList
        .map((e) => PlayerCharacterSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    }

    if(res.statusCode == 401) throw Exception ('Unauthorized');
    throw Exception('Failed to load characters (${res.statusCode}): ${res.body}');
  }

  // POST create
  Future<PlayerCharacterSummary> createCharacter({
    required String name,
    required int raceId,
    required int classId,
    required int backgroundId,
    required Map<String, int> abilityScores,
  }) async {
    final body = {
      'name': name,
      'raceId': raceId,
      'dndClassId': classId,
      'backgroundId': backgroundId,
      'abilityScores': abilityScores,
      'level': 1
    };

    final res = await _api.post(ApiConfig.charactersPath, body: body);

    if (res.statusCode == 200 || res.statusCode == 201){
      return PlayerCharacterSummary.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
    }
    if (res.statusCode == 401) throw Exception('Unauthorized');
    throw Exception('Failed to create character (${res.statusCode}): ${res.body}');
  }
}