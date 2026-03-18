import 'package:flutter/foundation.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';

class CharacterListViewModel extends ChangeNotifier {
  final CharacterService _service;

  CharacterListViewModel({CharacterService? service}): _service = service ?? CharacterService();

  bool _isLoading = false;
  String? _errorMessage;
  List<PlayerCharacterSummary> _characters = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PlayerCharacterSummary> get characters => _characters;

  Future<void> load() async{
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _characters = await _service.getMyCharacters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}