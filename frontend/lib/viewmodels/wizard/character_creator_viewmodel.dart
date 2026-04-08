import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/models/wizard/background_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/race_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';



// - Enums ---------------------
enum WizardStep {preferences, dndClass, background, race, abilityScores, spells}
enum AbilityScoreMethod {standardArray, manual}

// - Constante D&D ------------------
const List<int> kStandardArray = [15, 14, 13, 12, 10, 8];
const List<String> kAbilityNames = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];


// - ViewModel -------------------
class CharacterCreatorViewModel extends ChangeNotifier {
  final WizardReferenceService _refService;
  final CharacterService       _charService;

  CharacterCreatorViewModel({
    WizardReferenceService? refService,
    CharacterService?       charService,
  })  : _refService  = refService  ?? WizardReferenceService(),
        _charService = charService ?? CharacterService();

  //- Navegación ------------------
  WizardStep _currentStep = WizardStep.preferences;
  WizardStep get currentStep => _currentStep;

  //Los pasos visibles dependen de si el personaje tiene spells

  List<WizardStep> get activeSteps {
    final steps = [
      WizardStep.preferences,
      WizardStep.dndClass,
      WizardStep.background,
      WizardStep.race,
      WizardStep.abilityScores,
    ];
    if(isSpellcaster) steps.add(WizardStep.spells);
    return steps;
  }

  int get currentStepIndex => activeSteps.indexOf(_currentStep);
  int get totalSteps => activeSteps.length;
  bool get isFirstStep => _currentStep == activeSteps.first;
  bool get isLastStep => _currentStep == activeSteps.last;

  //Detecta si el personaje es spellcaster (clase o subclase con spellCastingAbility)
  bool get isSpellcaster =>
    (selectedClass?.spellCastingAbility != null &&
      selectedClass!.spellCastingAbility!.isNotEmpty) ||
    (selectedSubclass?.spellCastingAbility != null &&
      selectedSubclass!.spellCastingAbility!.isNotEmpty);

  //Nivel máximo de spell que puede aprender según nivel del personaje
  //Regla simplificada: ceil (characterLevel / 2), maximo 9
  int get maxSpellLevel => isSpellcaster
    ? ((selectedLevel / 2).ceil()).clamp(1, 9)
    : 0;

  // Límite de selección de hechizos ------------
  // Cantrips conocidos según clase y nivel (tablas PHB exactas 2014)
  int get maxCantrips {
    if (!isSpellcaster) return 0;
    final level = selectedLevel;
    final className = selectedClass?.name.toLowerCase() ?? '';

    if (className.contains('wizard')) {
      const table = [0, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5];
      return table[level.clamp(0, 20)];
    }
    if (className.contains('sorcerer')) {
      const table = [0, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6];
      return table[level.clamp(0, 20)];
    }
    if (className.contains('bard')) {
      const table = [0, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
      return table[level.clamp(0, 20)];
    }
    if (className.contains('cleric')) {
      const table = [0, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5];
      return table[level.clamp(0, 20)];
    }
    if (className.contains('druid')) {
      const table = [0, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
      return table[level.clamp(0, 20)];
    }
    if (className.contains('warlock')) {
      const table = [0, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4];
      return table[level.clamp(0, 20)];
    }
    
    // Eldritch Knight / Arcane Trickster: Empiezan con 2, suben a 3 al nivel 10
    if (selectedSubclass?.spellCastingAbility != null) {
      return level >= 10 ? 3 : 2;
    }
    
    return 0; 
  }

  // Spells conocidos/preparados según clase y nivel
  int get maxSpellsKnown {
    if (!isSpellcaster) return 0;
    final level = selectedLevel;
    final className = selectedClass?.name.toLowerCase() ?? '';

    // 1. Clases de "Conocidos" (Tablas fijas)
    if (className.contains('sorcerer')) {
      const table = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 13, 13, 14, 14, 15, 15, 15, 15];
      return table[level.clamp(0, 20)];
    }
    if (className.contains('bard')) {
      // Incluye Secretos Mágicos en niveles 10, 14 y 18
      const table = [0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 15, 16, 18, 19, 19, 20, 22, 22, 22];
      return table[level.clamp(0, 20)];
    }
    if (className.contains('warlock')) {
      const table = [0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15];
      return table[level.clamp(0, 20)];
    }
    if (className.contains('ranger')) {
      if (level < 2) return 0; // No tienen hechizos a nivel 1
      const table = [0, 0, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11];
      return table[level.clamp(0, 20)];
    }

    // 2. Clases de "Preparación" (Modificador + Nivel)
    if (className.contains('wizard')) {
      return (abilityModifier('INT') + level).clamp(1, 99);
    }
    if (className.contains('cleric') || className.contains('druid')) {
      return (abilityModifier('WIS') + level).clamp(1, 99);
    }
    if (className.contains('paladin')) {
      if (level < 2) return 0; // No preparan hechizos a nivel 1
      // Half-caster: Nivel/2 (abajo) + Modificador
      return ((level / 2).floor() + abilityModifier('CHA')).clamp(1, 99);
    }

    // 3. Subclases (Eldritch Knight / Arcane Trickster)
    if (selectedSubclass?.spellCastingAbility != null) {
      const table = [0, 0, 0, 3, 4, 4, 4, 5, 6, 6, 7, 8, 8, 9, 10, 10, 11, 11, 11, 12, 13];
      return table[level.clamp(0, 20)];
    }

    return 0;
  }

  // Cuántos cantrips y spells lleva seleccionados
  int get selectedCantripCount =>
      availableSpells.where((s) => selectedSpellIds.contains(s.id) && s.isCantrip).length;
  int get selectedSpellCount =>
      availableSpells.where((s) => selectedSpellIds.contains(s.id) && !s.isCantrip).length;

  bool get cantripLimitReached => selectedCantripCount >= maxCantrips;
  bool get spellLimitReached => selectedSpellCount >= maxSpellsKnown;


  // Pasos que tienen cambios pero no están completos -> muestra ⚠️
  // Solo se añade cuando el usuario modifica datos, no al navegar
  final Set<WizardStep> _dirtySteps = {};
  void _markDirty(WizardStep step) => _dirtySteps.add(step);

  // Devuelve si un paso concreto está 100% válido (tick)
  bool isStepCompleted(WizardStep step){
    switch(step){
      case WizardStep.preferences: return preferencesValid;
      case WizardStep.dndClass: return classValid;
      case WizardStep.background: return backgroundValid;
      case WizardStep.race: return raceValid;
      case WizardStep.abilityScores: return abilityScoresValid;
      case WizardStep.spells: return spellsValid;
    }
  }

  // Con cambios parciales pero incompleto → muestra ⚠️
  bool isStepPartial(WizardStep step) =>
    _dirtySteps.contains(step) && !isStepCompleted(step);

  // Navega a cualquier paso libremente (sin restricciones)
  void goToStep(WizardStep target){
    if(!activeSteps.contains(target)) return;
    _currentStep = target;
    _loadStepData();
    notifyListeners();
  }

  void nextStep(){
    final idx = currentStepIndex;
    if (idx < totalSteps -1){
      _currentStep = activeSteps[idx + 1];
      _loadStepData();
      notifyListeners();
    }
  }

  void previousStep(){
    final idx = currentStepIndex;
    if (idx > 0){
      _currentStep = activeSteps[idx-1];
      _loadStepData();
      notifyListeners();
    }
  }

  //- Estado de carga / error
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {_error = null; notifyListeners();}
  void _setLoading(bool v){ _isLoading = v; notifyListeners();}
  void _setError(String? v) {_error = v; notifyListeners();}

  // - PASO 1: Preferencias
  // ────────────────────────────────────────────────────────────

  String characterName = '';
  bool useMilestone = true; // true = milestone, false = XP
  bool useEncumbrance = false;

  void setName(String v) {characterName = v; _markDirty(WizardStep.preferences); notifyListeners();}
  void setMilestone(bool v) {useMilestone = v; _markDirty(WizardStep.preferences); notifyListeners();}
  void setEncumbrance(bool v) {useEncumbrance = v; _markDirty(WizardStep.preferences); notifyListeners();}

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
    //Si cambia la clase, limpiar spells seleccionados
    selectedSpellIds.clear();
    availableSpells.clear();
    _markDirty(WizardStep.dndClass);
    notifyListeners();
  }

  void clearClass() {
    selectedClass = null;
    selectedSubclass = null;
    selectedLevel = 1;
    _hpRolls.clear();
    classFeatures.clear();
    subclasses.clear();
    selectedSpellIds.clear();
    availableSpells.clear();
    _spellsStepVisited = false;
    _markDirty(WizardStep.dndClass);
    notifyListeners();
  }

  void selectSubclass(SubclassOption s) {
    selectedSubclass = s;
    selectedSpellIds.clear();
    availableSpells.clear();
    _markDirty(WizardStep.dndClass);
    notifyListeners();
  }

  void setLevel(int level) {
    selectedLevel = level.clamp(1,20);
    _markDirty(WizardStep.dndClass);
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
    _markDirty(WizardStep.background);
    notifyListeners();
  }

  // Características físicas y personales (persistentes entre tabs)
  String hair        = '';
  String eyes        = '';
  String skin        = '';
  String age         = '';
  String height      = '';
  String weight      = '';
  String personality = '';
  String ideals      = '';
  String bonds       = '';
  String flaws       = '';

  void setHair(String v)        { hair        = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setEyes(String v)        { eyes        = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setSkin(String v)        { skin        = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setAge(String v)         { age         = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setHeight(String v)      { height      = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setWeight(String v)      { weight      = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setPersonality(String v) { personality = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setIdeals(String v)      { ideals      = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setBonds(String v)       { bonds       = v; _markDirty(WizardStep.background); notifyListeners(); }
  void setFlaws(String v)       { flaws       = v; _markDirty(WizardStep.background); notifyListeners(); }

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
    _markDirty(WizardStep.race);
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
    _markDirty(WizardStep.abilityScores);
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
    _markDirty(WizardStep.abilityScores);
    notifyListeners();
  }

  ///Asigna un valor manual a una ability
  void setManualScore(String ability, int value){
    abilityScores[ability] = value.clamp(3, 20);
    _markDirty(WizardStep.abilityScores);
    notifyListeners();
  }

  /// Elimina la asignación del standard array para una ability
  void clearStandardArrayAssignment(String ability) {
    standardArrayAssignments[ability] = null;
    abilityScores[ability] = 10;
    _markDirty(WizardStep.abilityScores);
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


//PASO 6: Spells (dinámico - solo si isSpellcaster)
// ────────────────────────────────────────────────────────────

  List<SpellOption> availableSpells = [];
  final Set<int> selectedSpellIds = {};
  // Se marca true la primera vez que el usuario llega al paso de spells
  bool _spellsStepVisited = false;

  //El paso de spells es válido sólo si el usuario lo ha visitado
  bool get spellsValid => _spellsStepVisited;

  List<SpellOption> get selectedSpells =>
    availableSpells.where((s) => selectedSpellIds.contains(s.id)).toList();

  void toggleSpell(int spellId){
    if (selectedSpellIds.contains(spellId)){
      selectedSpellIds.remove(spellId);
    } else {
      selectedSpellIds.add(spellId);
    }
    _markDirty(WizardStep.spells);
    notifyListeners();
  }

  Future<void> loadAvailableSpells() async {
    _setLoading(true);
    _setError(null);
    try {
      availableSpells = await _refService.getAvailableSpells(
        classId: selectedClass?.id,
        subclassId: selectedSubclass?.id,
        maxLevel: maxSpellLevel,
      );
    } catch(e) {
      _setError('Error loading spells: $e');
    } finally {
      _setLoading(false);
    }
  }



  // Validación global
  // ────────────────────────────────────────────────────────────

  bool get canFinish =>
    preferencesValid &&
    classValid &&
    backgroundValid &&
    raceValid &&
    abilityScoresValid;

  bool get canProceedCurrentStep => isStepCompleted(_currentStep);  

  //Submit
  // ────────────────────────────────────────────────────────────

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _saveSuccess = false;
  bool get saveSuccess => _saveSuccess;

  int? _createdCharacterId;
  int? get createdCharacterId => _createdCharacterId;

  Future<void> submit() async {
    if (_isSaving) return; // guard contra doble click
    if (!canFinish) return;
    _isSaving = true;
    _createdCharacterId = null;
    _error = null;
    notifyListeners();
    try {
      final result = await _charService.createCharacter(
        name:         characterName.trim(),
        raceId:       selectedRace!.id,
        classId:      selectedClass!.id,
        backgroundId: selectedBackground!.id,        
        level:        selectedLevel,           
        subclassId:   selectedSubclass?.id,
        spellIds:    selectedSpellIds.toList(),     
        abilityScores: {
          'str': abilityScores['STR']!,
          'dex': abilityScores['DEX']!,
          'con': abilityScores['CON']!,
          'int': abilityScores['INT']!,
          'wis': abilityScores['WIS']!,
          'cha': abilityScores['CHA']!,
        },
        personalityTrait: personality.isNotEmpty ? personality : null,
        ideal:  ideals.isNotEmpty  ? ideals  : null,
        bond:   bonds.isNotEmpty   ? bonds   : null,
        flaw:   flaws.isNotEmpty   ? flaws   : null,
        hair:   hair.isNotEmpty    ? hair    : null,
        eyes:   eyes.isNotEmpty    ? eyes    : null,
        skin:   skin.isNotEmpty    ? skin    : null,
        age:    age.isNotEmpty     ? age     : null,
        height: height.isNotEmpty  ? height  : null,
        weight: weight.isNotEmpty  ? weight  : null,
      );
      _createdCharacterId = result.id;
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
      case WizardStep.spells:
        _spellsStepVisited = true;
        if (availableSpells.isEmpty) loadAvailableSpells();
        break;
      default:
        break;
    }
  }
}