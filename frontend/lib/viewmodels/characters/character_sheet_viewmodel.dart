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
  int get tabIndex => _tabIndex;

  void setTab(int i) {
    _tabIndex = i;
    notifyListeners();
  }

  // Load
  Future<void> load() async{
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

}