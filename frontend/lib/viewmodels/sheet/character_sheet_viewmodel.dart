import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';

class CharacterSheetViewmodel extends ChangeNotifier{
  final CharacterService _service;
  final int characterId;

  CharacterSheetViewmodel({
    required this.characterId,
    CharacterService? service,
  }) : _service = service ?? CharacterService();

  //Estado
  PlayerCharacter? character;
  bool isLoading = false;
  String? error;

  //Carga inicial
  Future<void> load() async{
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      character = await _service.getCharacterById(characterId);
    } catch (e) {
      error = e.toString().replaceFirst('Exception', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Manage HP
  bool isSavingHP = false;
  String? hpError;

  Future<void> applyHpChange({
    required int damage,
    required int heal,
    required int tempHp,
  }) async {
    if (character == null) return;
    isSavingHP = true;
    hpError = null;
    notifyListeners();
    try{
      final updated = await _service.patchHp(
        id: character!.id,
        damage: damage,
        heal: heal,
        tempHp: tempHp,
      );
      character = updated;
    } catch (e) {
      hpError = e.toString().replaceFirst('Exception', '');
    } finally {
      isSavingHP = false;
      notifyListeners();
    }
  }

  //Helpers de D&D
  static const Map<String, String> _skillAbility = {
    'Acrobatics': 'DEX', 'Animal Handling': 'WIS', 'Arcana': 'INT',
    'Athletics': 'STR', 'Deception': 'CHA', 'History': 'INT',
    'Insight': 'WIS', 'Intimidation': 'CHA', 'Investigation': 'INT',
    'Medicine': 'WIS', 'Nature': 'INT', 'Perception': 'WIS',
    'Performance': 'CHA', 'Persuasion': 'CHA', 'Religion': 'INT',
    'Sleight of Hand': 'DEX', 'Stealth': 'DEX', 'Survival': 'WIS',
  };

  static const List<String> skillNames = [
    'Acrobatics', 'Animal Handling', 'Arcana', 'Athletics', 'Deception',
    'History', 'Insight', 'Intimidation', 'Investigation', 'Medicine',
    'Nature', 'Perception', 'Performance', 'Persuasion', 'Religion',
    'Sleight of Hand', 'Stealth', 'Survival',
  ];

  static const Map<String, String> abilityFull = {
    'STR': 'Strength', 'DEX': 'Dexterity', 'CON': 'Constitution',
    'INT': 'Intelligence', 'WIS': 'Wisdom', 'CHA': 'Charisma',
  };

  String skillAbility(String skill) => _skillAbility[skill] ?? 'STR';

  /// Bonus de skill: mod de la ability + proficiency si aplica.
  /// Por ahora usamos el meleeAttackBonus como referencia de proficiency,
  /// pero el backend debería devolver un mapa de skills. Calculamos con mod.
  int skillBonus(String skill){
    if(character == null) return 0;
    return character!.modifier(skillAbility(skill));
  }

  String signedInt(int v) => v >= 0 ? '+$v' : '$v';
}