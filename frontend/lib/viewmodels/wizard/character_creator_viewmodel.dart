import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/models/wizard/background_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/race_option.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';



// - Enums
enum WizardStep {preferences, dndClass, background, race, abilityScores}

enum AbilityScoreMethod {standardArray, manual}

// - Constante D&D
const List<int> kStandardArray = [15, 14, 13, 12, 10, 8];
const List<String> kAbilityNames = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];


// - ViewModel
class CharacterCreatorViewModel extends ChangeNotifier {
  final WizardReferenceService _refService;
  final CharacterService       _charService;

  CharacterCreatorViewModel({
    WizardReferenceService? refService,
    CharacterService?       charService,
  })  : _refService  = refService  ?? WizardReferenceService(),
        _charService = charService ?? CharacterService();

  //- Navegación
  WizardStep _currentStep = WizardStep.preferences;
  WizardStep get currentStep => _currentStep;
  int get currentStepIndex => WizardStep.values.indexOf(_currentStep);
  int get totalSteps => WizardStep.values.length;
  bool get isFirstStep => _currentStep == WizardStep.values.first;
  bool get isLastStep => _currentStep == WizardStep.values.last;

  void goToStep(WizardStep step){
    _currentStep = step;
    notifyListeners();
  }

  void nextStep(){
    final idx = currentStepIndex;
    if (idx < totalSteps -1){
      _currentStep = WizardStep.values[idx + 1];
      _loadStepData();
      notifyListeners();
    }
  }

  void previousStep(){
    final idx = currentStepIndex;
    if (idx > 0){
      _currentStep = WizardStep.values[idx-1];
      notifyListeners();
    }
  }

  //- Estado de carga / error
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _setLoading(bool v){ _isLoading = v; notifyListeners();}
  void _setError(String? v) {_error = v; notifyListeners();}

  // - PASO 1: Preferencias
  // ────────────────────────────────────────────────────────────

  String characterName = '';
  bool useMilestone = true; // true = milestone, false = XP
  bool useEncumbrance = false;

  void setName(String v) {characterName = v; notifyListeners();}
  void setMilestone(bool v) {useMilestone = v; notifyListeners();}
  void setEncumbrance(bool v) {useEncumbrance = v; notifyListeners();}

  bool get preferencesValid => characterName.trim().isNotEmpty;

  // PASO 2: Clase
  // ────────────────────────────────────────────────────────────

  List<ClassOption> classes = [];
  ClassOption? selectedClass;
  List<ClassFeature> classFeatures = [];
  List<SubclassOption> subclasses = [];
  SubclassOption? selectedSubclass;
  int selectedLevel = 1;

  Future<void> loadClasses() async {
    _setLoading(true);
    _setError(null);
    try{
      classes = await _refService.getClasses();      
    } catch(e) {
      _setError('Error loading classes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadClassFeatures(int classId) async {
    _setLoading(true);
    _setError(null);
    try {
      classFeatures = await _refService.getClassFeatures(classId);
    } catch(e) {
      _setError('Error loading class features: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectClass(ClassOption c) {
    selectedClass = c;
    notifyListeners();
  }

  void clearClass() {
    selectedClass = null;
    selectedSubclass = null;
    selectedLevel = 1;
    _hpRolls.clear();
    classFeatures.clear();
    subclasses.clear();
    notifyListeners();
  }

  void selectSubclass(SubclassOption s) {
    selectedSubclass = s;
    notifyListeners();
  }

  void setLevel(int level) {
    selectedLevel = level.clamp(1,20);
    notifyListeners();
  }

  // Tiradas de HP por nivel (nivel → tirada, sin incluir nivel 1)
  final Map<int, int?> _hpRolls = {};
  Map<int, int?> get hpRolls => Map.unmodifiable(_hpRolls);

  void setHpRolls(Map<int, int?> rolls) {
    _hpRolls
      ..clear()
      ..addAll(rolls);
    notifyListeners();
  }

  //Features del nivel actual y anteriores (acumuladas)
  List<ClassFeature> get featuresUpToCurrentLevel =>
    classFeatures.where((f) => f.level <= selectedLevel).toList();

  int get calculatedHp{
    final base = selectedClass?.hitDie ?? 8;
    final conMod = abilityModifier('CON');
    //Nivel 1: máximo. Niveles siguientes: media redondeada arriba + CON
    if(selectedLevel == 1) return base + conMod;
    return (base + conMod) + ((base ~/ 2 + 1 + conMod) * (selectedLevel - 1));  
    }

    bool get classValid => selectedClass != null;

  // PASO 3: Background
  // ────────────────────────────────────────────────────────────
  List<BackgroundOption> backgrounds = [];
  BackgroundOption? selectedBackground;

  Future<void> loadBackgrounds() async {
    _setLoading(true);
    _setError(null);
    try{
      backgrounds = await _refService.getBackgrounds();
    } catch(e){
      _setError('Error loading backgrounds: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectBackground(BackgroundOption b){
    selectedBackground = b;
    notifyListeners();
  }

  bool get backgroundValid => selectedBackground != null;


  // PASO 4: Raza
  // ────────────────────────────────────────────────────────────

  List<RaceOption> races = [];
  RaceOption? selectedRace;

  Future<void> loadRaces() async{
    _setLoading(true);
    _setError(null);
    try{
      races = await _refService.getRaces();
    } catch(e) {
      _setError('Error loading races: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectRace(RaceOption r) {
    selectedRace = r;
    notifyListeners();
  }

  bool get raceValid => selectedRace != null;

  //PASO 5: Ability Scores
  // ────────────────────────────────────────────────────────────
  AbilityScoreMethod scoreMethod = AbilityScoreMethod.standardArray;

  //Mapa: 'STR' -> valor asignado
  final Map<String, int> abilityScores = {
    for (final a in kAbilityNames) a: 10,
  };

  //Standard array: qué indice de kStandardArray está asignado a cada ability
  //null = sin asignar todavía
  final Map<String, int?> standardArrayAssignments = {
    for (final a in kAbilityNames) a: null,
  };

  void setScoreMethod(AbilityScoreMethod m){
    scoreMethod = m;
    //Reset
    for (final a in kAbilityNames){
      abilityScores[a] = 10;
      standardArrayAssignments[a] = null;
    }
    notifyListeners();
  }

  /// Asigna un valor del standard array a una ability
  void assignStandardArrayValue(String ability, int arrayIndex){
    //Si ese índice ya estaba asignado a otra ability, lo libra
    standardArrayAssignments.forEach((key, val){
      if(val == arrayIndex) standardArrayAssignments[key] = null;
    });
    standardArrayAssignments[ability] = arrayIndex;
    abilityScores[ability] = kStandardArray[arrayIndex];
    notifyListeners();
  }

  ///Asigna un valor manual a una ability
  void setManualScore(String ability, int value){
    abilityScores[ability] = value.clamp(3, 20);
    notifyListeners();
  }

  /// Elimina la asignación del standard array para una ability
  void clearStandardArrayAssignment(String ability) {
    standardArrayAssignments[ability] = null;
    abilityScores[ability] = 10;
    notifyListeners();
  }

  /// Bonos raciales aplicados sobre los scores base
  Map<String, int> get racialBonuses =>
    selectedRace?.abilityBonuses ?? {};

  /// Score final = base + bono racial
  int finalScore(String ability) =>
    (abilityScores[ability] ?? 10) + (racialBonuses[ability] ?? 0);

  /// Modificador de la ability (score final)
  int abilityModifier(String ability) => ((finalScore(ability) - 10) /2).floor();

  bool get allArrayValuesAssigned =>
    standardArrayAssignments.values.every((v) => v != null);

  bool get abilityScoresValid => scoreMethod == AbilityScoreMethod.manual || allArrayValuesAssigned;

  // Validación global y submit
  bool get canFinish =>
    preferencesValid &&
    classValid &&
    backgroundValid &&
    raceValid &&
    abilityScoresValid;

    bool get canProceedCurrentStep {
    switch (_currentStep) {
      case WizardStep.preferences:   return preferencesValid;
      case WizardStep.dndClass:      return classValid;
      case WizardStep.background:    return backgroundValid;
      case WizardStep.race:          return raceValid;
      case WizardStep.abilityScores: return abilityScoresValid;
    }
  }

  bool _isSaving = false;
  bool get isSaving => _isSaving;
  bool _saveSuccess = false;
  bool get saveSuccess => _saveSuccess;

  Future<void> submit() async {
    if (!canFinish) return;
    _isSaving = true;
    _saveSuccess = false;
    notifyListeners();
    try {
      await _charService.createCharacter(
        name:         characterName.trim(),
        raceId:       selectedRace!.id,
        classId:      selectedClass!.id,
        backgroundId: selectedBackground!.id,
        abilityScores: {
          'STR': abilityScores['STR']!,
          'DEX': abilityScores['DEX']!,
          'CON': abilityScores['CON']!,
          'INT': abilityScores['INT']!,
          'WIS': abilityScores['WIS']!,
          'CHA': abilityScores['CHA']!,
        },
      );
      _saveSuccess = true;
    } catch (e) {
      _setError('Error saving character: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Carga automática al cambiar de paso

  void _loadStepData() {
    switch (_currentStep) {
      case WizardStep.dndClass:
        if (classes.isEmpty) loadClasses();
        break;
      case WizardStep.background:
        if (backgrounds.isEmpty) loadBackgrounds();
        break;
      case WizardStep.race:
        if (races.isEmpty) loadRaces();
        break;
      default:
        break;
    }
  }
}