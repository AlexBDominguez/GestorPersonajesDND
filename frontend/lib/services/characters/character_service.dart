import 'dart:convert';
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class CharacterService {
  final ApiClient _api;

  CharacterService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  // GET list
  Future<List<PlayerCharacterSummary>> getMyCharacters() async {
    final res = await _api.get(ApiConfig.charactersPath);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => PlayerCharacterSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if(res.statusCode == 401) throw Exception ('Unauthorized');
    throw Exception('Failed to load characters (${res.statusCode})');
  }

  // GET single
  Future<PlayerCharacter>getCharacterById(int id) async {
    final res = await _api.get('${ApiConfig.charactersPath}/$id');
    if (res.statusCode == 200) {
      return PlayerCharacter.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    if(res.statusCode == 401) throw Exception ('Unauthorized');
    if(res.statusCode == 403) throw Exception ('Access denied');
    if(res.statusCode == 404) throw Exception ('Character not found');
    throw Exception('Failed to load character (${res.statusCode})');
  }

  // POST create
  Future<PlayerCharacterSummary> createCharacter({
    required String name,
    required int raceId,
    required int classId,
    required int backgroundId,
    required Map<String, int> abilityScores,
    int level = 1,
    int? subclassId,
    String? personalityTrait,
    String? ideal,
    String? bond,
    String? flaw,
    String? alignment,
    String? hair,
    String? eyes,
    String? skin,
    String? age,
    String? height,
    String? weight,
    List<int>? spellIds,
    List<int>? magicalSecretSpellIds,
    List<String>? classSkillIndices,
    bool useEncumbrance = false,
  }) async {
    final body = {
      'name': name,
      'raceId': raceId,
      'dndClassId': classId,
      'backgroundId': backgroundId,
      'abilityScores': abilityScores,
      'level': level,
      'useEncumbrance': useEncumbrance,
      if (subclassId != null) 'subclassId': subclassId,
      if (personalityTrait != null && personalityTrait.isNotEmpty) 'personalityTrait': personalityTrait,
      if (ideal != null && ideal.isNotEmpty) 'ideal': ideal,
      if (bond != null && bond.isNotEmpty) 'bond': bond,
      if (flaw != null && flaw.isNotEmpty) 'flaw': flaw,
      if (alignment != null) 'alignment': alignment,
      if (hair != null && hair.isNotEmpty) 'hair': hair,
      if (eyes != null && eyes.isNotEmpty) 'eyes': eyes,
      if (skin != null && skin.isNotEmpty) 'skin': skin,
      if (age != null && age.isNotEmpty) 'age': age,
      if (height != null && height.isNotEmpty) 'height': height,
      if (weight != null && weight.isNotEmpty) 'weight': weight,
      if (spellIds != null && spellIds.isNotEmpty) 'spellIds': spellIds,
      if (magicalSecretSpellIds != null && magicalSecretSpellIds.isNotEmpty) 'magicalSecretSpellIds': magicalSecretSpellIds,
      if (classSkillIndices != null && classSkillIndices.isNotEmpty) 'classSkillIndices': classSkillIndices,
    };
    final res = await _api.post(ApiConfig.charactersPath, body: body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return PlayerCharacterSummary.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    if (res.statusCode == 401) throw Exception('Unauthorized');
    if (res.statusCode == 403) throw Exception('Access denied');
    throw Exception('Failed to create character (${res.statusCode})');
  }

    //PATCH HP (damage, heal, tempHp)
    Future<PlayerCharacter> patchHp({
      required int id,
      required int damage, 
      required int heal,
      required int tempHp
    }) async {
      final body ={
        'damage': damage,
        'heal': heal,
        'temporaryHp': tempHp,
      };
      final res = await _api.patch('${ApiConfig.charactersPath}/$id/hp', body: body);
      if (res.statusCode == 200){
        return PlayerCharacter.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);        
      }
      if(res.statusCode == 401) throw Exception('Unauthorized');
      if(res.statusCode == 403) throw Exception('Access denied');
      throw Exception('Failed to update HP (${res.statusCode})');
    }

    Future<void> deleteCharacter(int id) async {
      final res = await _api.delete('${ApiConfig.charactersPath}/$id');
      if (res.statusCode == 200 || res.statusCode == 204) {
        return;
      }
      if(res.statusCode == 401) throw Exception('Unauthorized');
      if(res.statusCode == 403) throw Exception('Access denied');
      if(res.statusCode == 404) throw Exception('Character not found');
      throw Exception('Failed to delete character (${res.statusCode})');
    }


    // POST toggle prepare/unprepare spell
    Future<void> togglePrepareSpell({
      required int characterId,
      required int spellId,
    }) async {
      final res = await _api.post(
        '${ApiConfig.charactersPath}/$characterId/spells/$spellId/prepare',
      );
      if (res.statusCode == 204) return;
      if (res.statusCode == 400 || res.statusCode == 422) {
        String msg = res.body.isNotEmpty ? res.body : 'Cannot prepare spell';
        throw Exception(msg);
      }
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      if (res.statusCode == 404) throw Exception('Spell not found on character');
      throw Exception('Failed to toggle prepare (${res.statusCode})');
    }

    // DELETE spell del personaje
    Future<void>removeSpell({
      required int characterId,
      required int spellId,
    }) async {
      final res = await _api.delete(
        '${ApiConfig.charactersPath}/$characterId/spells/$spellId',
      );
      if (res.statusCode == 204) return;
      if (res.statusCode == 400) throw Exception('res.body');
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      if (res.statusCode == 404) throw Exception('Spell not found on character');
      
      throw Exception('Failed to remove spell (${res.statusCode})');
    }

    //POST usar un slot por nivel (botón CAST sin spellId)
    Future<void> useSpellSlot({
      required int characterId,
      required int level,
    }) async {
      if (level == 0) return; //cantrips no usan slots
      final res = await _api.post(
        '${ApiConfig.charactersPath}/$characterId/spell-slots/$level/use',
      );
      if (res.statusCode == 204) return;
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      if (res.statusCode == 404) throw Exception('No slots for level $level');
      if (res.statusCode == 409) throw Exception('No slots available for level $level');
      throw Exception('Failed to use spell slot (${res.statusCode})');
    }

    //POST restaurar (deshacer) un slot usado por nivel
    Future<void> restoreSpellSlot({
      required int characterId,
      required int level,
    }) async {
      if (level == 0) return;
      final res = await _api.post(
        '${ApiConfig.charactersPath}/$characterId/spell-slots/$level/restore',
      );
      if (res.statusCode == 204) return;
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      if (res.statusCode == 404) throw Exception('No slots for level $level');
      throw Exception('Failed to restore spell slot (${res.statusCode})');
    }
}

