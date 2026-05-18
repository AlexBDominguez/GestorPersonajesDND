import 'dart:async';
import 'dart:convert';
import 'package:gestor_personajes_dnd/config/api_config.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';
import 'package:gestor_personajes_dnd/services/storage/local_cache_service.dart';

class CharacterService {
  final ApiClient _api;

  CharacterService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  // GET list
  Future<List<PlayerCharacterSummary>> getMyCharacters() async {
    final res = await _api.get(ApiConfig.charactersPath);
    if (res.statusCode == 200) {
      unawaited(LocalCacheService.saveCharacterList(res.body));
      return (jsonDecode(res.body) as List)
          .map((e) => PlayerCharacterSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if(res.statusCode == 401) throw Exception ('Unauthorized');
    throw Exception('Failed to load characters (${res.statusCode})');
  }

  // GET single
  Future<PlayerCharacter> getCharacterById(int id) async {
    final res = await _api.get('${ApiConfig.charactersPath}/$id');
    if (res.statusCode == 200) {
      unawaited(LocalCacheService.saveCharacter(id, res.body));
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
    String abilityDisplayMode = 'SCORES_TOP',
  }) async {
    final body = {
      'name': name,
      'raceId': raceId,
      'dndClassId': classId,
      'backgroundId': backgroundId,
      'abilityScores': abilityScores,
      'level': level,
      'useEncumbrance': useEncumbrance,
      'abilityDisplayMode': abilityDisplayMode,
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
    Future<void> addSpellToCharacter({
      required int characterId,
      required int spellId,
    }) async {
      final res = await _api.post(
        '${ApiConfig.charactersPath}/$characterId/spells/$spellId',
      );

      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        return;
      }
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      if (res.statusCode == 404) throw Exception('Character or spell not found');
      throw Exception('Failed to add spell (${res.statusCode})');
    }

    Future<void> addSpellsToCharacter({
      required int id,
      required List<int> spellIds,
    }) async {
      for (final spellId in spellIds) {
        await addSpellToCharacter(characterId: id, spellId: spellId);
      }
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

    // POST death save (success or failure)
    Future<PlayerCharacter> recordDeathSave(int id, {required bool success}) async {
      final res = await _api.post(
        '${ApiConfig.charactersPath}/$id/death-save',
        body: {'success': success},
      );
      if (res.statusCode == 200) {
        return PlayerCharacter.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      throw Exception('Failed to record death save (${res.statusCode})');
    }

    // POST reset death saves
    Future<PlayerCharacter> resetDeathSaves(int id) async {
      final res = await _api.post('${ApiConfig.charactersPath}/$id/reset-death-saves');
      if (res.statusCode == 200) {
        return PlayerCharacter.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      throw Exception('Failed to reset death saves (${res.statusCode})');
    }

    // POST long rest
    Future<PlayerCharacter> longRest(int characterId) async {
      final res = await _api.post('${ApiConfig.charactersPath}/$characterId/long-rest');
      if (res.statusCode == 200) {
        return PlayerCharacter.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      throw Exception('Long rest failed (${res.statusCode})');
    }

    // POST short rest
    Future<PlayerCharacter> shortRest(int characterId, {required int hitDiceToSpend, required int hitDiceRoll}) async {
      final res = await _api.post(
        '${ApiConfig.charactersPath}/$characterId/short-rest',
        body: {'hitDiceToSpend': hitDiceToSpend, 'hitDiceRoll': hitDiceRoll},
      );
      if (res.statusCode == 200) {
        return PlayerCharacter.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      throw Exception('Short rest failed (${res.statusCode})');
    }

    // POST level-up
    Future<void> levelUp(int characterId) async {
      final res = await _api.post('${ApiConfig.charactersPath}/$characterId/level-up');
      if (res.statusCode == 200) return;
      if (res.statusCode == 400) {
        final msg = res.body.isNotEmpty ? res.body : 'Character is already at max level';
        throw Exception(msg);
      }
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      throw Exception('Failed to level up (${res.statusCode})');
    }

    // PATCH profile (edit character metadata)
    Future<PlayerCharacter> updateProfile({
      required int id,
      String? name,
      String? alignment,
      String? personalityTrait,
      String? ideal,
      String? bond,
      String? flaw,
      int? age,
      String? height,
      String? weight,
      String? eyes,
      String? skin,
      String? hair,
      String? abilityDisplayMode,
      bool? useEncumbrance,
      int? subclassId,
      int? backgroundId,
      int? raceId,
      int? subraceId,
      Map<String, int>? abilityScores,
    }) async {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (alignment != null) 'alignment': alignment,
        if (personalityTrait != null) 'personalityTrait': personalityTrait,
        if (ideal != null) 'ideal': ideal,
        if (bond != null) 'bond': bond,
        if (flaw != null) 'flaw': flaw,
        if (age != null) 'age': age,
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (eyes != null) 'eyes': eyes,
        if (skin != null) 'skin': skin,
        if (hair != null) 'hair': hair,
        if (abilityDisplayMode != null) 'abilityDisplayMode': abilityDisplayMode,
        if (useEncumbrance != null) 'useEncumbrance': useEncumbrance,
        if (subclassId != null) 'subclassId': subclassId,
        if (backgroundId != null) 'backgroundId': backgroundId,
        if (raceId != null) 'raceId': raceId,
        if (subraceId != null) 'subraceId': subraceId,
        if (abilityScores != null) 'abilityScores': abilityScores,
      };
      final res = await _api.patch('${ApiConfig.charactersPath}/$id/profile', body: body);
      if (res.statusCode == 200) {
        return PlayerCharacter.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      if (res.statusCode == 401) throw Exception('Unauthorized');
      if (res.statusCode == 403) throw Exception('Access denied');
      if (res.statusCode == 404) throw Exception('Character not found');
      throw Exception('Failed to update profile (${res.statusCode})');
    }
}

