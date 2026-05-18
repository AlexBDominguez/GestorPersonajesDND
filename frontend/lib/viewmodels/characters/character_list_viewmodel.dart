import 'package:flutter/foundation.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/storage/local_cache_service.dart';

class CharacterListViewModel extends ChangeNotifier {
  final CharacterService _service;

  CharacterListViewModel({CharacterService? service}): _service = service ?? CharacterService();

  bool _isLoading = false;
  String? _errorMessage;
  List<PlayerCharacterSummary> _characters = [];
  bool _fromCache = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PlayerCharacterSummary> get characters => _characters;
  bool get fromCache => _fromCache;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async{
    if (_disposed) return;
    _isLoading = true;
    _errorMessage = null;

    // ── 1. Mostrar caché local mientras llega la API ──────────────────────
    final cached = await LocalCacheService.loadCharacterList();
    if (cached != null) {
      _characters = cached;
      _fromCache  = true;
      if (!_disposed) notifyListeners();
    } else {
      notifyListeners(); // spinner sin caché
    }

    // ── 2. Fetch desde API ────────────────────────────────────────────────
    try {
      _characters = await _service.getMyCharacters();
      _fromCache  = false;
    } catch (e) {
      if (_characters.isEmpty) {
        _errorMessage = e.toString();
      }
      // Si hay caché, la mantenemos y _fromCache sigue en true
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> deleteCharacter(int id) async {
    try {
      await _service.deleteCharacter(id);
      _characters.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}