import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/models/wizard/background_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/race_option.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';

class CharacterCreatorViewModel extends ChangeNotifier {
  final WizardReferenceService _refService;
  final CharacterService       _charService;

  CharacterCreatorViewModel({
    WizardReferenceService? refService,
    CharacterService?       charService,
  })  : _refService  = refService  ?? WizardReferenceService(),
        _charService = charService ?? CharacterService();

  // ── Step control ────────────────────────────────────────────────
  int _currentStep = 0;
  int get currentStep => _currentStep;
  static const int totalSteps = 4; // Race, Class, Scores, Background

  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // ── Reference data ───────────────────────────────────────────────
  List<RaceOption>       races       = [];
  List<ClassOption>      classes     = [];
  List<BackgroundOption> backgrounds = [];
  bool  _loadingRefs  = false;
  String? _refsError;

  bool    get loadingRefs => _loadingRefs;
  String? get refsError   => _refsError;

  Future<void> loadReferenceData() async {
    _loadingRefs = true;
    _refsError   = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _refService.getRaces(),
        _refService.getClasses(),
        _refService.getBackgrounds(),
      ]);
      races       = results[0] as List<RaceOption>;
      classes     = results[1] as List<ClassOption>;
      backgrounds = results[2] as List<BackgroundOption>;
    } catch (e) {
      _refsError = e.toString();
    } finally {
      _loadingRefs = false;
      notifyListeners();
    }
  }

  // ── Step 1: Character name ───────────────────────────────────────
  String characterName = '';

  // ── Step 1: Race ────────────────────────────────────────────────
  RaceOption? selectedRace;
  void selectRace(RaceOption race) {
    selectedRace = race;
    notifyListeners();
  }

  // ── Step 2: Class ────────────────────────────────────────────────
  ClassOption? selectedClass;
  void selectClass(ClassOption cls) {
    selectedClass = cls;
    notifyListeners();
  }

  // ── Step 3: Ability Scores ───────────────────────────────────────
  // Standard array: 15,14,13,12,10,8
  static const List<int> standardArray = [15, 14, 13, 12, 10, 8];
  static const List<String> abilityNames = [
    'STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'
  ];

  // Map: abilityName → assigned score (null = unassigned)
  Map<String, int?> abilityAssignments = {
    for (final a in abilityNames) a: null,
  };

  // Which standard array values are still available
  List<int> get availableScores {
    final assigned = abilityAssignments.values.whereType<int>().toList();
    final pool = List<int>.from(standardArray);
    for (final v in assigned) {
      pool.remove(v);
    }
    return pool;
  }

  bool get allScoresAssigned =>
      abilityAssignments.values.every((v) => v != null);

  void assignScore(String ability, int? score) {
    // If reassigning, free the previous value
    abilityAssignments[ability] = score;
    notifyListeners();
  }

  int abilityModifier(int score) => ((score - 10) / 2).floor();
  String modifierLabel(int score) {
    final mod = abilityModifier(score);
    return mod >= 0 ? '+$mod' : '$mod';
  }

  // ��─ Step 4: Background ──────────────��───────────────────────────
  BackgroundOption? selectedBackground;
  void selectBackground(BackgroundOption bg) {
    selectedBackground = bg;
    notifyListeners();
  }

  // ── Validation ──────────────────────────────────────────────────
  bool get step0Valid => characterName.trim().isNotEmpty && selectedRace != null;
  bool get step1Valid => selectedClass != null;
  bool get step2Valid => allScoresAssigned;
  bool get step3Valid => selectedBackground != null;

  bool get canProceed {
    switch (_currentStep) {
      case 0: return step0Valid;
      case 1: return step1Valid;
      case 2: return step2Valid;
      case 3: return step3Valid;
      default: return false;
    }
  }

  // ── Create ──────────────────────────────────────────────────────
  bool    _isCreating  = false;
  String? _createError;
  bool    _createSuccess = false;

  bool    get isCreating    => _isCreating;
  String? get createError   => _createError;
  bool    get createSuccess => _createSuccess;

  Future<void> createCharacter() async {
    if (!step0Valid || !step1Valid || !step2Valid || !step3Valid) return;

    _isCreating  = true;
    _createError = null;
    notifyListeners();

    try {
      final scores = <String, int>{
        for (final e in abilityAssignments.entries)
          if (e.value != null) e.key: e.value!,
      };

      await _charService.createCharacter(
        name:         characterName.trim(),
        raceId:       selectedRace!.id,
        classId:      selectedClass!.id,
        backgroundId: selectedBackground!.id,
        abilityScores: scores,
      );
      _createSuccess = true;
    } catch (e) {
      _createError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }
}