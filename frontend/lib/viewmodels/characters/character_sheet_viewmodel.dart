import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/combat_features.dart';
import 'package:gestor_personajes_dnd/models/character/pending_task.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/racial_trait.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/characters/pending_task_service.dart';
import 'package:gestor_personajes_dnd/services/spells/spell_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';

// Consumable features: indexName -> max uses (o código especial negativo)
const _kConsumableFeatures = <String, int>{
  'channel-divinity':   1,
  'wild-shape':         2,
  'action-surge':       1,
  'second-wind':        1,
  'bardic-inspiration': -1, // -1 = CHA mod
  'lay-on-hands':       -2, // -2 = nivel * 5
  'ki-points':          -3, // -3 = nivel
  'rage':               -4, // -4 = tabla de barbarian
};

class CharacterSheetViewModel extends ChangeNotifier {
  final CharacterService _service;
  final int characterId;
  final SpellService _spellService;
  final WizardReferenceService _refService;
  final PendingTaskService _taskService = PendingTaskService();
  List<PendingTask> _pendingTasks = [];
  List<PendingTask> get pendingTasks => _pendingTasks;
  bool get hasPendingTasks => _pendingTasks.isNotEmpty;

  CharacterSheetViewModel({
    required this.characterId,
    CharacterService? service,
    SpellService? spellService,
    WizardReferenceService? refService,
  })  : _service = service ?? CharacterService(),
        _spellService = spellService ?? SpellService(),
        _refService = refService ?? WizardReferenceService();

  // ── State 
  PlayerCharacter? character;
  bool _isLoading = false;
  String? _errorMessage;
  int _tabIndex = 0;
  List<RacialTrait> _racialTraits = [];
  List<RacialTrait> get racialTraits => _racialTraits;

  bool get isLoading    => _isLoading;
  String? get error     => _errorMessage;
  String? get errorMessage => _errorMessage;
  int get tabIndex      => _tabIndex;

  bool _isLoadingTraits = false;
  bool get isLoadingTraits => _isLoadingTraits;

  void setTab(int i) { _tabIndex = i; notifyListeners(); }

  // ── Load 
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      character = await _service.getCharacterById(characterId);
      await _loadPendingTasks();
      _initSpellSlots();
      if (character?.dndClassId != null && _classFeatures.isEmpty) {
        _loadClassFeaturesIfNeeded();
      }
      if (character?.subclassId != null && _subclassFeatures.isEmpty) {
        _loadSubclassFeaturesIfNeeded();
      }
      if (character?.raceId != null && _racialTraits.isEmpty){
        _loadRacialTraits();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Spell Slots 
  final Map<int, int> _usedSlots = {};

  void _initSpellSlots() {
    _usedSlots.clear();
    for (final slot in character?.spellSlots ?? []) {
      _usedSlots[slot.spellLevel] = slot.usedSlots;
    }
  }

  int usedSlots(int level)      => _usedSlots[level] ?? 0;
  int maxSlots(int level)       => character?.spellSlots
      .where((s) => s.spellLevel == level)
      .firstOrNull?.maxSlots ?? 0;
  int availableSlots(int level) => (maxSlots(level) - usedSlots(level)).clamp(0, 99);

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

  void restoreAllSlots() {
    for (final slot in character?.spellSlots ?? []) {
      _usedSlots[slot.spellLevel] = 0;
    }
    notifyListeners();
  }

  Future<void> togglePrepareSpell(int spellId) async {
    try {
      await _service.togglePrepareSpell(characterId: characterId, spellId: spellId);
      await load();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
      notifyListeners();
    }
  }

  Future<void> removeSpell(int spellId) async {
    try {
      await _service.removeSpell(characterId: characterId, spellId: spellId);
      await load();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
      notifyListeners();
    }
  }

  // ── Available spells 
  List<SpellOption> _availableSpells = [];
  List<SpellOption> get availableSpells => _availableSpells;
  bool _isLoadingSpells = false;
  bool get isLoadingSpells => _isLoadingSpells;
  String? _spellsError;
  String? get spellsError => _spellsError;

  int get _maxLearnableSpellLevel =>
      ((character?.level ?? 1) / 2).ceil().clamp(1, 9);

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

  Future<void> learnSpell(int spellId) async {
    try {
      await _spellService.learnSpell(characterId: characterId, spellId: spellId);
      await load();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
      notifyListeners();
    }
  }

  // ── Class Features 
  List<ClassFeature> _classFeatures = [];
  List<ClassFeature> get classFeatures => _classFeatures;
  bool _isLoadingFeatures = false;
  bool get isLoadingFeatures => _isLoadingFeatures;

  /// Features de clase filtradas solo para Combat (activables)
  List<ClassFeature> get combatClassFeatures => _classFeatures
      .where((f) => isCombatRelevant(f.indexName))
      .toList();

  /// Features de clase filtradas por categoría para Combat
  List<ClassFeature> combatFeaturesByCategory(FeatureCategory cat) =>
      _classFeatures
          .where((f) => classifyFeature(f.indexName) == cat)
          .toList();

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
      // silencioso
    } finally {
      _isLoadingFeatures = false;
      notifyListeners();
    }
  }

  // ── Subclass Features 
  List<ClassFeature> _subclassFeatures = [];
  List<ClassFeature> get subclassFeatures => _subclassFeatures;
  bool _isLoadingSubclassFeatures = false;
  bool get isLoadingSubclassFeatures => _isLoadingSubclassFeatures;

  List<ClassFeature> get combatSubclassFeatures => _subclassFeatures
      .where((f) => isCombatRelevant(f.indexName))
      .toList();

  Future<void> _loadSubclassFeaturesIfNeeded() async {
    final id = character?.subclassId;
    if (id == null) return;
    _isLoadingSubclassFeatures = true;
    notifyListeners();
    try {
      final all = await _refService.getSubclassFeatures(id);
      final charLevel = character?.level ?? 1;
      _subclassFeatures = all.where((f) => f.level <= charLevel).toList()
        ..sort((a, b) => a.level.compareTo(b.level));
    } catch (_) {
      // silencioso
    } finally {
      _isLoadingSubclassFeatures = false;
      notifyListeners();
    }
  }

  Future<void> _loadRacialTraits() async {
    final raceId = character?.raceId;
    final subraceId = character?.subraceId;
    if (raceId == null) return;

    _isLoadingTraits = true;
    notifyListeners();
    try {
      final raceTraits = await _refService.getRacialTraits(raceId);
      final subraceTraits = subraceId != null
          ? await _refService.getSubraceTraits(subraceId)
          : <RacialTrait>[];
      // Evitar duplicados: un trait de subraza puede solapar con uno de raza
      final seen = <String>{};
      _racialTraits = [
        ...raceTraits,
        ...subraceTraits,
      ].where((t) => seen.add(t.indexName)).toList();
    } catch (_) {
      //silencioso igual que los otros loaders
    } finally {
      _isLoadingTraits = false;
      notifyListeners();
    }
  }

  // ── Consumable feature tracking 
  final Map<String, int> _featureUsesRemaining = {};

  int featureMaxUses(ClassFeature f) {
    final raw = _kConsumableFeatures[f.indexName.toLowerCase()];
    if (raw == null) return 0;
    final lvl = character?.level ?? 1;
    if (raw == -1) return ((character?.abilityScores['cha'] ?? character?.abilityScores['CHA'] ?? 10) - 10) ~/ 2;
    if (raw == -2) return lvl * 5;
    if (raw == -3) return lvl;
    if (raw == -4) {
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
    return _featureUsesRemaining[f.indexName] ?? max;
  }

  bool isConsumableFeature(ClassFeature f) => featureMaxUses(f) > 0;

  void useFeature(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return;
    final current = featureUsesRemaining(f);
    if (current <= 0) return;
    _featureUsesRemaining[f.indexName] = current - 1;
    notifyListeners();
  }

  void restoreFeature(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return;
    final current = featureUsesRemaining(f);
    if (current >= max) return;
    _featureUsesRemaining[f.indexName] = current + 1;
    notifyListeners();
  }

  // ── HP management 
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

  // ── Pending Tasks
  Future<void> _loadPendingTasks() async {
    try {
      _pendingTasks = await _taskService.getPendingTasks(characterId);
    } catch (_) {
      _pendingTasks = [];
    }
    notifyListeners();
  }

  Future<bool> resolveTask(int taskId, String choice, {String? extraData}) async{
    try{
      await _taskService.resolveTask(
        characterId: characterId, 
        taskId: taskId, 
        choice: choice,
        extraData: extraData,
        );
      
      await _loadPendingTasks();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
      notifyListeners();
      return false;
    }
  }

  // ── Helpers 
  static const List<String> abilityNames = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];

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
    return character!.modifier(skillAbility(skill));
  }

  bool skillProficient(String skill) =>
      character?.skills.where((s) => s.skillName == skill).firstOrNull?.proficient ?? false;

  bool skillExpertise(String skill) =>
      character?.skills.where((s) => s.skillName == skill).firstOrNull?.expertise ?? false;

  void clearError() {
    _errorMessage = null;
  }

  String signedInt(int v) => v >= 0 ? '+$v' : '$v';

  String get spellcastingAbility {
    final cls = character?.dndClassName?.toLowerCase() ?? '';
    if (cls.contains('wizard') || cls.contains('eldritch knight')) return 'INT';
    if (cls.contains('cleric') || cls.contains('druid') ||
        cls.contains('ranger') || cls.contains('monk')) return 'WIS';
    if (cls.contains('bard') || cls.contains('paladin') ||
        cls.contains('sorcerer') || cls.contains('warlock')) return 'CHA';
    return 'INT';
  }

  bool get alwaysPreparedClass {
    final cls = character?.dndClassName?.toLowerCase() ?? '';
    return cls.contains('bard') || cls.contains('sorcerer') ||
        cls.contains('warlock') || cls.contains('ranger');
  }
}