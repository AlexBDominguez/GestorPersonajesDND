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
      //inicializar el estado local de spell slots desde el modelo
      _initSpellSlots();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Spell Slots (estado local mutable)
  //Mapa nivel -> slots usados (copia mutable del backend para UI reactiva)
  final Map<int, int> _usedSlots = {};

  void _initSpellSlots() {
    _usedSlots.clear();
    for (final slot in character?.spellSlots ?? []) {
      _usedSlots[slot.spellLevel] = slot.usedSlots;
    }
  }

  int usedSlots(int level) => _usedSlots[level] ?? 0;

  int maxSlots(int level) {
    return character?.spellSlots
        .where((s) => s.spellLevel == level)
        .firstOrNull
        ?.maxSlots ?? 0;
  }

  int availableSlots(int level) => (maxSlots(level) -
      usedSlots(level)).clamp(0,99);

  // Consume un slot del nivel dado y lo persiste en el backend
  // Devuelve false si no hay slots disponibles.
  Future<bool> castSpell(int level) async {
    if (level == 0) return true; //cantrips: siempre disponibles, sin llamada
    if (availableSlots(level) <= 0) return false;

    //Optimistic update = es decir:
    //actualizar el estado local antes de la respuesta del backend para una UI más fluida
    _usedSlots[level] = usedSlots(level) + 1;
    notifyListeners();
    try{
      await _service.useSpellSlot(
        characterId: characterId, 
        level: level);
    } catch (_) {
      //Rollback si el backend falla
      _usedSlots[level] = usedSlots(level) - 1;
      notifyListeners();
      return false;
    }
    return true;
  }

    //Toggle prepare y recarga la ficha para reflejar el cambio
    Future<void> togglePrepareSpell(int spellId) async{
      try {
        await _service.togglePrepareSpell(
          characterId: characterId, 
          spellId: spellId,
          );
          await load(); //recargar para sincronizar
      } catch (e) {
        _errorMessage = e.toString().replaceFirst('Exception', '');
        notifyListeners();
      }
    }

    // Eliminar spell y recargar
    Future<void> removeSpell(int spellId) async {
      try {
        await _service.removeSpell(
          characterId: characterId, 
          spellId: spellId,
          );
          await load();
      } catch (e) {
        _errorMessage = e.toString().replaceFirst('Exception', '');
        notifyListeners();
      }      
    }

  //Restaura todos los slots (Short/Long Rest)
  void restoreAllSlots(){
    for (final slot in character?.spellSlots ?? []) {
      _usedSlots[slot.spellLevel] = 0;
    }
    notifyListeners();
  }

  //Spellcasting ability del personaje (para el header de la tab)
  String get spellcastingAbility {
    //Lee desde el dndClassName del personaje
    final cls = character?.dndClassName?.toLowerCase() ?? '';
    if (cls.contains('wizard') || cls.contains('eldritch knight')) return 'INT';
    if (cls.contains('cleric') || cls.contains('druid') ||
        cls.contains('ranger') || cls.contains('monk')) return 'WIS';
    if (cls.contains('bard') || cls.contains('paladin') ||
        cls.contains('sorcerer') || cls.contains('warlock')) return 'CHA';
    return 'INT'; // fallback
  }

  //Clases de "siempre preparados" (no necesitan switch)
  bool get alwaysPreparedClass {
    final cls = character?.dndClassName?.toLowerCase() ?? '';
    return cls.contains('bard') || cls.contains('sorcerer') ||
        cls.contains('warlock') || cls.contains('ranger');
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
    final skillData = character!.skills.where((s) => s.skillName == skill).firstOrNull;
    if (skillData != null) return skillData.bonus;
    // Fallback: ability modifier only (no proficiency info available)
    return character!.modifier(skillAbility(skill));
  }

  bool skillProficient(String skill) {
    if (character == null) return false;
    return character!.skills.where((s) => s.skillName == skill).firstOrNull?.proficient ?? false;
  }

  bool skillExpertise(String skill) {
    if (character == null) return false;
    return character!.skills.where((s) => s.skillName == skill).firstOrNull?.expertise ?? false;
  }

  String signedInt(int v) => v >= 0 ? '+$v' : '$v';
}