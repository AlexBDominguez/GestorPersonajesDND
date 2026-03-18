import 'dart:convert';
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class CharacterService {
  final ApiClient _api;

  CharacterService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  Future<List<PlayerCharacterSummary>> getMyCharacters() async {
    final res = await _api.get(ApiConfig.charactersPath);

    if(res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body) as List<dynamic>;
      return jsonList
          .map((e) => PlayerCharacterSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (res.statusCode == 401) {
      throw Exception('Unauthorized');
    }
    throw Exception('Failed to load characters (${res.statusCode}): ${res.body}');
  }
}