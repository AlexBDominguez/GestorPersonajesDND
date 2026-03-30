import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';

class CharacterSheetViewModel extends ChangeNotifier {
  final CharacterService _service;
  final int characterId;

  CharacterSheetViewModel({
    required this.characterId,
    CharacterService? service,
  }) : _service = service ?? CharacterService();


  //State
  PlayerCharacter? character;
  bool _isLoading = false;
  String? _errorMessage;
  int _tabIndex = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;
  int get tabIndex => _tabIndex;

  void setTab(int i) {
    _tabIndex = i;
    notifyListeners();
  }

  // Load
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      character = await _service.getCharacterById(characterId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manage HP
  bool isSavingHp = false;
  String? hpError;

  Future<void> applyHpChange({
    required int damage,
    required int heal,
    required int tempHp,
  }) async {
    if (character == null) return;
    isSavingHp = true;
    hpError = null;
    notifyListeners();
    try {
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
      isSavingHp = false;
      notifyListeners();
    }
  }

  // D&D Helpers
  static const List<String> abilityNames = [
    'STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA',
  ];

  static const Map<String, String> abilityFull = {
    'STR': 'Strength', 'DEX': 'Dexterity', 'CON': 'Constitution',
    'INT': 'Intelligence', 'WIS': 'Wisdom', 'CHA': 'Charisma',
  };

  static const List<String> skillNames = [
    'Acrobatics', 'Animal Handling', 'Arcana', 'Athletics', 'Deception',
    'History', 'Insight', 'Intimidation', 'Investigation', 'Medicine',
    'Nature', 'Perception', 'Performance', 'Persuasion', 'Religion',
    'Sleight of Hand', 'Stealth', 'Survival',
  ];

  static const Map<String, String> _skillAbility = {
    'Acrobatics': 'DEX', 'Animal Handling': 'WIS', 'Arcana': 'INT',
    'Athletics': 'STR', 'Deception': 'CHA', 'History': 'INT',
    'Insight': 'WIS', 'Intimidation': 'CHA', 'Investigation': 'INT',
    'Medicine': 'WIS', 'Nature': 'INT', 'Perception': 'WIS',
    'Performance': 'CHA', 'Persuasion': 'CHA', 'Religion': 'INT',
    'Sleight of Hand': 'DEX', 'Stealth': 'DEX', 'Survival': 'WIS',
  };

  String skillAbility(String skill) => _skillAbility[skill] ?? 'STR';

  int skillBonus(String skill) {
    if (character == null) return 0;
    return character!.modifier(skillAbility(skill));
  }

  String signedInt(int v) => v >= 0 ? '+$v' : '$v';
}