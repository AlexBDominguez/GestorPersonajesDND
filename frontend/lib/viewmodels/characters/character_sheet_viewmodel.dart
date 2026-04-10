import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/spells/spell_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';

// Known consumable features: name pattern -> max uses at minimum level
// Key = lowercase substring to match in feature name
const _kConsumableFeatures = <String, int>{
  'channel divinity': 1,
  'wild shape': 2,
  'action surge': 1,
  'second wind': 1,
  'bardic inspiration': -1, // -1 = use CHA mod
  'lay on hands': -2,       // -2 = use level * 5
  'ki point': -3,           // -3 = use level
  'rage': -4,               // -4 = rages per day table
  'divine smite': 0,        // 0 = slot-based, skip
  'sneak attack': 0,
};


class CharacterSheetViewModel extends ChangeNotifier {
  final CharacterService _service;
  final int characterId;
  final SpellService _spellService;
  final WizardReferenceService _refService;


  CharacterSheetViewModel({
    required this.characterId,
    CharacterService? service,
    SpellService? spellService,
    WizardReferenceService? refService,
  }) : _service = service ?? CharacterService(),
       _spellService = spellService ?? SpellService(),
       _refService = refService ?? WizardReferenceService();


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
      // Cargar features de clase si tenemos el ID
      if (character?.dndClassId != null && _classFeatures.isEmpty) {
        _loadClassFeaturesIfNeeded();
      }
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
    if (level == 0) return true;
    if (availableSlots(level) <= 0) return false;
    _usedSlots[level] = usedSlots(level) + 1;
    notifyListeners();
    try {
      await _service.useSpellSlot(characterId: characterId, level: level);
    } catch (_) {
      _usedSlots[level] = usedSlots(level) - 1;
      notifyListeners();
      return false;
    }
    return true;
  }

  // Restaura (deshace) un slot del nivel dado
  Future<bool> restoreSpellSlot(int level) async {
    if (level == 0) return true;
    if (usedSlots(level) <= 0) return false;
    _usedSlots[level] = usedSlots(level) - 1;
    notifyListeners();
    try {
      await _service.restoreSpellSlot(characterId: characterId, level: level);
    } catch (_) {
      _usedSlots[level] = usedSlots(level) + 1;
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

    //Nivel máximo de spell que puede aprender según el nivel del personaje
    int get _maxLearnableSpellLevel =>
      ((character?.level ?? 1) /2).ceil().clamp(1, 9);

    Future<void> learnSpell(int spellId) async {
      try {
        await _spellService.learnSpell(
          characterId: characterId, 
          spellId: spellId,
          );
          await load(); //recarga la ficha          
      } catch (e) {
        _errorMessage = e.toString().replaceFirst('Exception', '');
        notifyListeners();
      }
    }

  // Available spells (para la tab "Learn New")
  List<SpellOption> _availableSpells = [];
  List<SpellOption> get availableSpells => _availableSpells;

  bool _isLoadingSpells = false;
  bool get isLoadingSpells => _isLoadingSpells;

  String? _spellsError;
  String? get spellsError => _spellsError;

  // IDs de los spells que el personaje ya conoce (para marcarlos como Known)
  Set<int> get knownSpellIds =>
      character?.characterSpells.map((s) => s.spellId).toSet() ?? {};

  Future<void> loadAvailableSpells() async {
    _isLoadingSpells = true;
    _spellsError = null;
    notifyListeners();
    try {
      _availableSpells = await _spellService.getAvailableSpells(
        classId: character?.dndClassId,
        maxLevel: _maxLearnableSpellLevel,
      );
    } catch (e) {
      _spellsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingSpells = false;
      notifyListeners();
    }
  }

  // Class features (para tab_combat)
  List<ClassFeature> _classFeatures = [];
  List<ClassFeature> get classFeatures => _classFeatures;

  bool _isLoadingFeatures = false;
  bool get isLoadingFeatures => _isLoadingFeatures;

  Future<void> _loadClassFeaturesIfNeeded() async {
    final id = character?.dndClassId;
    if (id == null) return;
    _isLoadingFeatures = true;
    notifyListeners();
    try {
      final all = await _refService.getClassFeatures(id);
      final charLevel = character?.level ?? 1;
      _classFeatures = all.where((f) => f.level <= charLevel).toList()
        ..sort((a, b) => a.level.compareTo(b.level));
    } catch (_) {
      // silently ignore: fallback to empty list
    } finally {
      _isLoadingFeatures = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // Consumable feature tracking (in-memory, restored on long rest)
  // Key = feature name (lowercase), value = uses remaining
  // ------------------------------------------------------------------
  final Map<String, int> _featureUsesRemaining = {};

  int featureMaxUses(ClassFeature f) {
    final key = _consumableKey(f.name);
    if (key == null) return 0;
    final raw = _kConsumableFeatures[key]!;
    final lvl = character?.level ?? 1;
    if (raw == -1) return (character?.abilityScores['CHA'] ?? 10) ~/ 2 - 5 + 1; // CHA mod
    if (raw == -2) return lvl * 5; // Lay on Hands pool
    if (raw == -3) return lvl;     // Ki points
    if (raw == -4) {               // Barbarian rages
      if (lvl >= 17) return 6;
      if (lvl >= 12) return 5;
      if (lvl >= 8)  return 4;
      if (lvl >= 6)  return 3;
      return 2;
    }
    return raw;
  }

  int featureUsesRemaining(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return 0;
    return _featureUsesRemaining[f.name.toLowerCase()] ?? max;
  }

  bool isConsumableFeature(ClassFeature f) => featureMaxUses(f) > 0;

  void useFeature(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return;
    final current = featureUsesRemaining(f);
    if (current <= 0) return;
    _featureUsesRemaining[f.name.toLowerCase()] = current - 1;
    notifyListeners();
  }

  void restoreFeature(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return;
    final current = featureUsesRemaining(f);
    if (current >= max) return;
    _featureUsesRemaining[f.name.toLowerCase()] = current + 1;
    notifyListeners();
  }

  String? _consumableKey(String featureName) {
    final lower = featureName.toLowerCase();
    for (final k in _kConsumableFeatures.keys) {
      if (_kConsumableFeatures[k] == 0) continue; // slot-based, skip
      if (lower.contains(k)) return k;
    }
    return null;
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
