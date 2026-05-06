import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/dnd_choice_options.dart';
import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';
import 'package:gestor_personajes_dnd/models/wizard/background_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/race_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/subrace_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/characters/pending_task_service.dart';
import 'package:gestor_personajes_dnd/services/inventory/inventory_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';



// - Enums ---------------------
enum WizardStep {preferences, dndClass, background, race, abilityScores, spells, equipment}
enum AbilityScoreMethod {standardArray, manual}

// - Constante D&D ------------------
const List<int> kStandardArray = [15, 14, 13, 12, 10, 8];
const List<String> kAbilityNames = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];

/// One required feature choice – shown as a section in the wizard Features step.
class WizardChoiceConfig {
  /// D&D task type, e.g. 'FIGHTING_STYLE', 'FAVORED_ENEMY'.
  final String type;
  /// Level at which this feature is acquired.
  final int level;
  /// Display label shown in the wizard UI.
  final String label;
  /// Selectable options.
  final List<DndChoiceOption> options;
  /// If false, this choice does not block classFeatureChoicesDone (e.g. ASI).
  final bool required;
  /// How many items the user must pick (1 = single pick, 2+ = multi-pick).
  final int pickCount;
  const WizardChoiceConfig({
    required this.type,
    required this.level,
    required this.label,
    required this.options,
    this.required = true,
    this.pickCount = 1,
  });
  /// Unique key used to store / look up the selection: e.g. 'FAVORED_ENEMY_6'.
  String get key => '${type}_$level';
}


// - ViewModel -------------------
class CharacterCreatorViewModel extends ChangeNotifier {
  final WizardReferenceService _refService;
  final CharacterService       _charService;
  final InventoryService      _inventoryService;
  final PendingTaskService    _pendingTaskService;

  CharacterCreatorViewModel({
    WizardReferenceService? refService,
    CharacterService?       charService,
    InventoryService?      inventoryService,
    PendingTaskService?    pendingTaskService,
  })  : _refService  = refService  ?? WizardReferenceService(),
        _charService = charService ?? CharacterService(),
        _inventoryService = inventoryService ?? InventoryService(),
        _pendingTaskService = pendingTaskService ?? PendingTaskService();


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
    steps.add(WizardStep.equipment);
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
  // Half-casters (Ranger, Paladin): nivel de hechizo limitado por tabla PHB
  // Third-casters (EK, AT): lv3→1, lv7→2, lv13→3
  // Full-casters: ceil(level/2), máximo 9
  int get maxSpellLevel {
    if (!isSpellcaster) return 0;
    final className = selectedClass?.name.toLowerCase() ?? '';
    final level = selectedLevel;
    // Third-caster subclasses
    if (selectedSubclass?.spellCastingAbility != null &&
        selectedClass?.spellCastingAbility == null) {
      if (level >= 13) return 3;
      if (level >= 7)  return 2;
      if (level >= 3)  return 1;
      return 0;
    }
    if (className.contains('ranger') || className.contains('paladin')) {
      // Half-caster: spell slot level table (levels 0-20)
      const table = [0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5];
      return table[level.clamp(0, 20)];
    }
    return ((level / 2).ceil()).clamp(1, 9);
  }

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
    if (selectedSubclass?.spellCastingAbility != null &&
        selectedClass?.spellCastingAbility == null) {
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
      // Magical Secrets slots are tracked separately; subtract them from the table
      const table = [0, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 15, 16, 18, 19, 19, 20, 22, 22, 22];
      return (table[level.clamp(0, 20)] - magicalSecretsSlots).clamp(0, 99);
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
    if (selectedSubclass?.spellCastingAbility != null &&
        selectedClass?.spellCastingAbility == null) {
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
      case WizardStep.equipment: return selectedItemIds.isNotEmpty; // optional step, tick only if items selected
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
  /// Public wrapper — lets external widgets trigger a rebuild without
  /// violating the @protected restriction on notifyListeners().
  void notify() => notifyListeners();

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
    selectedSubclass = null;
    subclasses = [];
    //Si cambia la clase, limpiar spells seleccionados
    selectedSpellIds.clear();
    availableSpells.clear();
    magicalSecretIds.clear();
    additionalMagicalSecretIds.clear();
    magicalSecretsPool.clear();
    _markDirty(WizardStep.dndClass);
    notifyListeners();
    _loadSubclassesFor(c.id);
  }

  void clearClass() {
    // Clear class feature choices before clearing selectedClass
    for (final c in classFeatureChoices) {
      featureChoices.remove(c.key);
    }
    // Also clear individual multi-pick sub-keys (e.g. EXPERTISE_PICK_0_3)
    featureChoices.removeWhere((k, _) => k.contains('_PICK_'));
    selectedClass = null;
    selectedSubclass = null;
    selectedLevel = 1;
    _hpRolls.clear();
    _classSkillIndices.clear();
    _classSkillRequiredCount = 0;
    classFeatures.clear();
    subclasses.clear();
    subclassFeatures = [];
    selectedSpellIds.clear();
    availableSpells.clear();
    magicalSecretIds.clear();
    additionalMagicalSecretIds.clear();
    magicalSecretsPool.clear();
    _spellsStepVisited = false;
    _markDirty(WizardStep.dndClass);
    notifyListeners();
  }

  bool get isLoadingSubclasses => subclasses.isEmpty && selectedClass != null;

  Future<void> loadSubclasses(int classId) async {
    try {
      subclasses = await _refService.getSubclasses(classId);
    } catch (_) {
      subclasses = [];
    }
    notifyListeners();
  }

  Future<void> _loadSubclassesFor(int classId) async {
    subclasses = [];
    notifyListeners();
    try {
      subclasses = await _refService.getSubclasses(classId);
    } catch (_) {
      subclasses = [];
    }
    notifyListeners();
  }

  void selectSubclass(SubclassOption s) {
    selectedSubclass = s;
    subclassFeatures = [];
    selectedSpellIds.clear();
    availableSpells.clear();
    magicalSecretIds.clear();
    additionalMagicalSecretIds.clear();
    magicalSecretsPool.clear();
    _markDirty(WizardStep.dndClass);
    notifyListeners();
    _loadSubclassFeaturesFor(s.id);
  }

  void clearSubclass() {
    // Clear subclass-specific feature choices (Hunter choices etc.)
    for (final c in subclassFeatureChoices) featureChoices.remove(c.key);
    // Also remove DRACONIC_ANCESTRY if it was a subclass-driven class choice
    for (final c in classFeatureChoices) {
      if (c.type == 'DRACONIC_ANCESTRY') featureChoices.remove(c.key);
    }
    selectedSubclass = null;
    subclassFeatures = [];
    _markDirty(WizardStep.dndClass);
    notifyListeners();
  }

  List<ClassFeature> subclassFeatures = [];

  Future<void> _loadSubclassFeaturesFor(int subclassId) async {
    try {
      subclassFeatures = await _refService.getSubclassFeatures(subclassId);
    } catch (_) {
      subclassFeatures = [];
    }
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

    bool get classValid => selectedClass != null && classFeatureChoicesDone && classSkillPicksDone;

  // Class skill picks
  final Set<String> _classSkillIndices = {};
  Set<String> get classSkillIndices => Set.unmodifiable(_classSkillIndices);

  // Override count set from ClassOptionsScreen to avoid stale ClassOption
  int _classSkillRequiredCount = 0;

  void setClassSkillRequiredCount(int count) {
    if (_classSkillRequiredCount != count) {
      _classSkillRequiredCount = count;
    }
  }

  int get _effectiveSkillCount =>
      _classSkillRequiredCount > 0
          ? _classSkillRequiredCount
          : (selectedClass?.skillChoiceCount ?? 0);

  bool get classSkillPicksDone {
    final count = _effectiveSkillCount;
    if (count == 0) return true;
    return _classSkillIndices.length >= count;
  }

  void toggleClassSkill(String skillIndex) {
    if (_classSkillIndices.contains(skillIndex)) {
      _classSkillIndices.remove(skillIndex);
      // If this skill had expertise, remove those picks too
      _removeExpertisePicksForSkill(_skillIndexToDisplay(skillIndex));
    } else {
      final count = _effectiveSkillCount;
      if (_classSkillIndices.length < count) {
        _classSkillIndices.add(skillIndex);
      }
    }
    _markDirty(WizardStep.dndClass);
    notifyListeners();
  }

  /// Converts a hyphenated skill index to a display name.
  /// e.g. 'sleight-of-hand' → 'Sleight Of Hand'
  String _skillIndexToDisplay(String idx) =>
      idx.split('-').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');

  /// Removes any EXPERTISE_PICK_* featureChoices whose value matches [displayName].
  void _removeExpertisePicksForSkill(String displayName) {
    featureChoices.removeWhere(
      (k, v) => k.contains('EXPERTISE_PICK') && v == displayName,
    );
  }

  /// Normalises a skill index from the API: strips the leading 'skill-' prefix
  /// that background proficiencies carry (e.g. 'skill-insight' → 'insight').
  static String _normalizeSkillIndex(String s) =>
      s.startsWith('skill-') ? s.substring(6) : s;

  /// Skills the character is already proficient in (class picks + background).
  /// Used to restrict Expertise options to only valid choices per D&D 5e rules.
  Set<String> get _proficientSkillIndices {
    final indices = <String>{};
    // Class skill picks (lowercase hyphenated, e.g. 'sleight-of-hand')
    indices.addAll(_classSkillIndices);
    // Background skill proficiencies — normalize 'skill-X' → 'X'
    if (selectedBackground != null) {
      for (final s in selectedBackground!.skillProficiencies) {
        indices.add(_normalizeSkillIndex(s));
      }
    }
    return indices;
  }

  /// Returns only the kSkills options the character already has proficiency in.
  /// Returns empty list if none are selected yet (Expertise requires prior proficiency).
  List<DndChoiceOption> get proficientSkillOptions {
    final proficient = _proficientSkillIndices;
    if (proficient.isEmpty) return const [];
    // Normalize kSkills name to index format: 'Sleight of Hand' → 'sleight-of-hand'
    String toIndex(String name) =>
        name.toLowerCase().replaceAll(' ', '-');
    final filtered = kSkills
        .where((s) => proficient.contains(toIndex(s.name)))
        .toList();
    return filtered;
  }

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

  /// Selects the background and removes any class skill picks that conflict
  /// (same skill can't come from both class and background in D&D 5e).
  /// Returns the display names of any skills that were deselected from the class.
  List<String> selectBackground(BackgroundOption b) {
    selectedBackground = b;
    _markDirty(WizardStep.background);

    // Find class skills that overlap with background skill proficiencies.
    // Background indices have a 'skill-' prefix (e.g. 'skill-insight'),
    // class indices do not (e.g. 'insight') — normalise before comparing.
    final bgNormalised = b.skillProficiencies
        .map(CharacterCreatorViewModel._normalizeSkillIndex)
        .toSet();
    final conflicts = _classSkillIndices
        .where((idx) => bgNormalised.contains(idx))
        .toList();

    if (conflicts.isNotEmpty) {
      for (final idx in conflicts) {
        _classSkillIndices.remove(idx);
        _removeExpertisePicksForSkill(_skillIndexToDisplay(idx));
      }
      _markDirty(WizardStep.dndClass);
    }

    notifyListeners();

    // Return human-readable display names for the UI to show a warning
    String toDisplay(String idx) =>
        idx.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
    return conflicts.map(toDisplay).toList();
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
  String? alignment;

  void setAlignment(String? v) { alignment = v; _markDirty(WizardStep.background); notifyListeners(); }
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
  List<SubraceOption> subraces = [];
  SubraceOption? selectedSubrace;
  bool isLoadingSubraces = false;

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
    // Clear previous race AND subrace feature choices before switching
    for (final c in raceFeatureChoices) featureChoices.remove(c.key);
    for (final c in subraceFeatureChoices) featureChoices.remove(c.key); // must be before clearing subrace
    selectedRace = r;
    selectedSubrace = null;
    subraces = [];
    _markDirty(WizardStep.race);
    notifyListeners();
    _loadSubracesFor(r.id);
  }

  Future<void> _loadSubracesFor(int raceId) async {
    isLoadingSubraces = true;
    notifyListeners();
    try {
      subraces = await _refService.getSubRaces(raceId);
    } catch (_) {
      subraces = [];
    } finally {
      isLoadingSubraces = false;
      notifyListeners();
    }
  }

  void selectSubrace(SubraceOption s) {
    // Clear previous subrace feature choices before switching
    for (final c in subraceFeatureChoices) {
      featureChoices.remove(c.key);
    }
    selectedSubrace = s;
    _markDirty(WizardStep.race);
    notifyListeners();
  }

  bool get raceValid =>
      selectedRace != null &&
      (subraces.isEmpty || selectedSubrace != null) &&
      raceFeatureChoicesDone;

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

  // ── Magical Secrets ─────────────────────────────────────────
  /// How many Magical Secrets picks are available (PHB: 2 at lv10, +2 at lv14, +2 at lv18).
  int get magicalSecretsSlots {
    final className = selectedClass?.name.toLowerCase() ?? '';
    if (!className.contains('bard')) return 0;
    final lv = selectedLevel;
    if (lv >= 18) return 6;
    if (lv >= 14) return 4;
    if (lv >= 10) return 2;
    return 0;
  }

  /// Extra 2 free picks for College of Lore bards at level 6+ (Additional Magical Secrets).
  int get additionalMagicalSecretsSlots {
    final subName = selectedSubclass?.name.toLowerCase() ?? '';
    if (!subName.contains('lore')) return 0;
    return selectedLevel >= 6 ? 2 : 0;
  }

  List<SpellOption> magicalSecretsPool = [];
  bool _isLoadingMagicalSecrets = false;
  bool get isLoadingMagicalSecrets => _isLoadingMagicalSecrets;

  final Set<int> magicalSecretIds = {};
  final Set<int> additionalMagicalSecretIds = {};

  int get selectedMagicalSecretCount => magicalSecretIds.length;
  int get selectedAdditionalMagicalSecretCount => additionalMagicalSecretIds.length;
  bool get magicalSecretLimitReached => selectedMagicalSecretCount >= magicalSecretsSlots;
  bool get additionalMagicalSecretLimitReached =>
      selectedAdditionalMagicalSecretCount >= additionalMagicalSecretsSlots;

  Future<void> loadMagicalSecretsPool() async {
    _isLoadingMagicalSecrets = true;
    notifyListeners();
    try {
      magicalSecretsPool = await _refService.getAvailableSpells(
        maxLevel: maxSpellLevel,
      );
    } catch (_) {
      magicalSecretsPool = [];
    } finally {
      _isLoadingMagicalSecrets = false;
      notifyListeners();
    }
  }

  void toggleMagicalSecret(int spellId) {
    if (magicalSecretIds.contains(spellId)) {
      magicalSecretIds.remove(spellId);
    } else {
      magicalSecretIds.add(spellId);
    }
    _markDirty(WizardStep.spells);
    notifyListeners();
  }

  void toggleAdditionalMagicalSecret(int spellId) {
    if (additionalMagicalSecretIds.contains(spellId)) {
      additionalMagicalSecretIds.remove(spellId);
    } else {
      additionalMagicalSecretIds.add(spellId);
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
      if (magicalSecretsSlots > 0 || additionalMagicalSecretsSlots > 0) {
        await loadMagicalSecretsPool();
      }
    } catch(e) {
      _setError('Error loading spells: $e');
    } finally {
      _setLoading(false);
    }
  }

// PASO 7: Equipment (opcional, no bloquea)
// ────────────────────────────────────────────────────────────
List<ItemCatalogEntry> _catalogItems = [];
List<ItemCatalogEntry> get catalogItems => _catalogItems;

bool _isLoadingItems = false;
bool get isLoadingItems => _isLoadingItems;

String? _itemsError;
String? get itemsError => _itemsError;

final Set<int> selectedItemIds = {};

Future<void> loadItemCatalog() async {
  _isLoadingItems = true;
  _itemsError = null;
  notifyListeners();
  try {
    _catalogItems = await _inventoryService.searchItems();
  } catch (e) {
    _itemsError = e.toString().replaceFirst('Exception: ', '');
  } finally {
    _isLoadingItems = false;
    notifyListeners();
  }
}

void toggleItem(int itemId) {
  if (selectedItemIds.contains(itemId)){
    selectedItemIds.remove(itemId); 
  }else {
    selectedItemIds.add(itemId);
  }
  notifyListeners();
}


  // Feature Choices — inline en el step de clase y el step de raza
  // ────────────────────────────────────────────────────────────

  /// Choices requeridas por la clase/subclase al nivel seleccionado.
  List<WizardChoiceConfig> get classFeatureChoices {
    final choices = <WizardChoiceConfig>[];
    final className = selectedClass?.name.toLowerCase() ?? '';
    final subcName  = selectedSubclass?.name.toLowerCase() ?? '';
    final level     = selectedLevel;

    // Fighter: Fighting Style at level 1
    if (className.contains('fighter') && level >= 1) {
      choices.add(const WizardChoiceConfig(
        type: 'FIGHTING_STYLE', level: 1,
        label: 'Fighting Style',
        options: kFightingStyles,
      ));
    }
    // Paladin: Fighting Style at level 2
    if (className.contains('paladin') && level >= 2) {
      choices.add(const WizardChoiceConfig(
        type: 'FIGHTING_STYLE', level: 2,
        label: 'Fighting Style',
        options: kFightingStyles,
      ));
    }
    // Ranger: Fighting Style at level 2
    if (className.contains('ranger') && level >= 2) {
      choices.add(const WizardChoiceConfig(
        type: 'FIGHTING_STYLE', level: 2,
        label: 'Fighting Style',
        options: kRangerFightingStyles,
      ));
    }
    // Ranger: Favored Enemy at levels 1, 6, 14
    if (className.contains('ranger')) {
      for (final l in [1, 6, 14]) {
        if (level >= l) {
          choices.add(WizardChoiceConfig(
            type: 'FAVORED_ENEMY', level: l,
            label: 'Favored Enemy (lv $l)',
            options: kFavoredEnemies,
          ));
        }
      }
      // Natural Explorer Terrain at levels 1, 6, 10
      for (final l in [1, 6, 10]) {
        if (level >= l) {
          choices.add(WizardChoiceConfig(
            type: 'FAVORED_TERRAIN', level: l,
            label: 'Natural Explorer Terrain (lv $l)',
            options: kFavoredTerrains,
          ));
        }
      }
    }
    // ASI_OR_FEAT — available at level 4, 8, 12, 16, 19 for most classes;
    // Fighter also at 6, 14; Rogue also at 10, 18. Marked optional (not blocking).
    {
      final List<int> asiLevels;
      if (className.contains('fighter')) {
        asiLevels = [4, 6, 8, 12, 14, 16, 19];
      } else if (className.contains('rogue')) {
        asiLevels = [4, 8, 10, 12, 16, 18];
      } else {
        asiLevels = [4, 8, 12, 16, 19];
      }
      for (final l in asiLevels) {
        if (level >= l) {
          choices.add(WizardChoiceConfig(
            type: 'ASI_OR_FEAT', level: l,
            label: 'Ability Score Improvement (lv $l)',
            options: const [], // handled by special ASI widget, options unused here
            required: false,
          ));
        }
      }
    }
    // Draconic Sorcerer: Draconic Ancestry at level 1
    if (className.contains('sorcerer') &&
        subcName.contains('draconic') &&
        level >= 1) {
      choices.add(const WizardChoiceConfig(
        type: 'DRACONIC_ANCESTRY', level: 1,
        label: 'Draconic Ancestry',
        options: kDraconicAncestries,
      ));
    }
    // ── Expertise: doubles proficiency bonus for chosen skills ──────────────
    // Rogue: lv 1 and lv 6 (2 skills each)
    if (className.contains('rogue')) {
      for (final l in [1, 6]) {
        if (level >= l) choices.add(WizardChoiceConfig(
          type: 'EXPERTISE', level: l,
          label: 'Expertise (lv $l)',
          options: proficientSkillOptions,
          pickCount: 2,
          required: false,
        ));
      }
    }
    // Bard: lv 3 and lv 10 (2 skills each)
    if (className.contains('bard')) {
      for (final l in [3, 10]) {
        if (level >= l) choices.add(WizardChoiceConfig(
          type: 'EXPERTISE', level: l,
          label: 'Expertise (lv $l)',
          options: proficientSkillOptions,
          pickCount: 2,
          required: false,
        ));
      }
    }
    // ── Sorcerer Metamagic ───────────────────────────────────────────────────
    // lv 3: 2 picks; lv 10 and 17: 1 pick each
    if (className.contains('sorcerer')) {
      if (level >= 3)  choices.add(WizardChoiceConfig(type: 'METAMAGIC', level: 3,  label: 'Metamagic (lv 3)',  options: kMetamagicOptions, pickCount: 2, required: false));
      if (level >= 10) choices.add(WizardChoiceConfig(type: 'METAMAGIC', level: 10, label: 'Metamagic (lv 10)', options: kMetamagicOptions, required: false));
      if (level >= 17) choices.add(WizardChoiceConfig(type: 'METAMAGIC', level: 17, label: 'Metamagic (lv 17)', options: kMetamagicOptions, required: false));
    }
    // ── Warlock Eldritch Invocations ─────────────────────────────────────────
    // Count scales with level: 2 at lv2, +1 at lv5/7/9/12/15/18
    if (className.contains('warlock') && level >= 2) {
      final invCount = level >= 18 ? 8 : level >= 15 ? 7 : level >= 12 ? 6
          : level >= 9 ? 5 : level >= 7 ? 4 : level >= 5 ? 3 : 2;
      choices.add(WizardChoiceConfig(
        type: 'INVOCATION', level: 2,
        label: 'Eldritch Invocations',
        options: kEldritchInvocations,
        pickCount: invCount,
        required: false,
      ));
    }
    return choices;
  }

  /// Choices requeridas por la raza seleccionada (nivel de raza, no subraza).
  List<WizardChoiceConfig> get raceFeatureChoices {
    final choices = <WizardChoiceConfig>[];
    final raceName = selectedRace?.name.toLowerCase() ?? '';

    // Dragonborn: Draconic Ancestry
    if (raceName.contains('dragonborn')) {
      choices.add(const WizardChoiceConfig(
        type: 'DRACONIC_ANCESTRY', level: 1,
        label: 'Draconic Ancestry',
        options: kDraconicAncestries,
      ));
    }

    // Human: Extra Language
    if (raceName == 'human' || raceName.contains('human')) {
      choices.add(const WizardChoiceConfig(
        type: 'EXTRA_LANGUAGE', level: 1,
        label: 'Extra Language',
        options: kLanguages,
      ));
    }

    // Half-Elf: Skill Versatility (two separate skills) + Extra Language
    if (raceName.contains('half-elf') || raceName.contains('half elf')) {
      choices.add(const WizardChoiceConfig(
        type: 'SKILL_VERSATILITY_1', level: 1,
        label: 'Skill Versatility — First Skill',
        options: kSkills,
      ));
      choices.add(const WizardChoiceConfig(
        type: 'SKILL_VERSATILITY_2', level: 1,
        label: 'Skill Versatility — Second Skill',
        options: kSkills,
      ));
      choices.add(const WizardChoiceConfig(
        type: 'EXTRA_LANGUAGE', level: 1,
        label: 'Extra Language',
        options: kLanguages,
      ));
    }

    // Dwarf (Hill Dwarf subrace trait, but some toolsets expose it at race level):
    // Tool Proficiency — handled here to catch the race-level trait
    if (raceName.contains('dwarf')) {
      choices.add(const WizardChoiceConfig(
        type: 'TOOL_PROFICIENCY', level: 1,
        label: 'Tool Proficiency',
        options: kDwarfTools,
      ));
    }

    return choices;
  }

  /// Choices required by the selected subrace (e.g. High Elf cantrip, extra language).
  List<WizardChoiceConfig> get subraceFeatureChoices {
    final choices = <WizardChoiceConfig>[];
    final subIdx = selectedSubrace?.indexName.toLowerCase() ?? '';
    if (subIdx.contains('high-elf') || subIdx == 'high-elf') {
      choices.add(const WizardChoiceConfig(
        type: 'HIGH_ELF_CANTRIP', level: 1,
        label: 'High Elf Cantrip (Wizard cantrip)',
        options: kWizardCantrips,
      ));
      choices.add(const WizardChoiceConfig(
        type: 'EXTRA_LANGUAGE', level: 1,
        label: 'Extra Language',
        options: kLanguages,
      ));
    }
    return choices;
  }

  /// Map of choice key (e.g. 'FAVORED_ENEMY_1') → selected option name.
  final Map<String, String> featureChoices = {};

  void setFeatureChoice(String key, String value) {
    featureChoices[key] = value;
    notifyListeners();
  }

  /// Choices required by the selected subclass at the selected level.
  List<WizardChoiceConfig> get subclassFeatureChoices {
    final choices = <WizardChoiceConfig>[];
    final subcIdx  = selectedSubclass?.indexName.toLowerCase() ?? '';
    final level    = selectedLevel;

    // Hunter Ranger
    if (subcIdx.contains('hunter')) {
      if (level >= 3)  choices.add(const WizardChoiceConfig(type: 'HUNTERS_PREY',               level: 3,  label: "Hunter's Prey",                  options: kHuntersPrey));
      if (level >= 7)  choices.add(const WizardChoiceConfig(type: 'DEFENSIVE_TACTICS',          level: 7,  label: 'Defensive Tactics',              options: kDefensiveTactics));
      if (level >= 11) choices.add(const WizardChoiceConfig(type: 'HUNTER_MULTIATTACK',         level: 11, label: 'Multiattack',                    options: kHunterMultiattack));
      if (level >= 15) choices.add(const WizardChoiceConfig(type: 'SUPERIOR_HUNTERS_DEFENSE',   level: 15, label: "Superior Hunter's Defense",       options: kSuperiorHuntersDefense));
    }

    // Totem Warrior Barbarian
    if (subcIdx.contains('totem')) {
      if (level >= 3)  choices.add(const WizardChoiceConfig(type: 'TOTEM_SPIRIT',       level: 3,  label: 'Totem Spirit',       options: kTotemSpirit));
      if (level >= 6)  choices.add(const WizardChoiceConfig(type: 'TOTEM_ASPECT',       level: 6,  label: 'Aspect of the Beast', options: kTotemAspect));
      if (level >= 14) choices.add(const WizardChoiceConfig(type: 'TOTEMIC_ATTUNEMENT', level: 14, label: 'Totemic Attunement',  options: kTotemicAttunement));
    }

    // Battle Master Fighter (choose 3 maneuvers at lv3, +2 at lv7, +2 at lv15)
    if (subcIdx.contains('battle-master') || subcIdx.contains('battlemaster') || subcIdx.contains('battle master')) {
      if (level >= 3)  choices.add(WizardChoiceConfig(type: 'BATTLEMASTER_MANEUVER_1', level: 3,  label: 'Maneuver 1', options: kBattleMasterManeuvers));
      if (level >= 3)  choices.add(WizardChoiceConfig(type: 'BATTLEMASTER_MANEUVER_2', level: 3,  label: 'Maneuver 2', options: kBattleMasterManeuvers));
      if (level >= 3)  choices.add(WizardChoiceConfig(type: 'BATTLEMASTER_MANEUVER_3', level: 3,  label: 'Maneuver 3', options: kBattleMasterManeuvers));
      if (level >= 7)  choices.add(WizardChoiceConfig(type: 'BATTLEMASTER_MANEUVER_4', level: 7,  label: 'Maneuver 4', options: kBattleMasterManeuvers));
      if (level >= 7)  choices.add(WizardChoiceConfig(type: 'BATTLEMASTER_MANEUVER_5', level: 7,  label: 'Maneuver 5', options: kBattleMasterManeuvers));
      if (level >= 15) choices.add(WizardChoiceConfig(type: 'BATTLEMASTER_MANEUVER_6', level: 15, label: 'Maneuver 6', options: kBattleMasterManeuvers));
      if (level >= 15) choices.add(WizardChoiceConfig(type: 'BATTLEMASTER_MANEUVER_7', level: 15, label: 'Maneuver 7', options: kBattleMasterManeuvers));
    }

    // Way of the Four Elements Monk (choose disciplines at lv3/6/11/17)
    if (subcIdx.contains('four-elements') || subcIdx.contains('four elements')) {
      if (level >= 3)  choices.add(WizardChoiceConfig(type: 'FOUR_ELEM_DISC_1', level: 3,  label: 'Discipline 1', options: kFourElementsDisciplines));
      if (level >= 3)  choices.add(WizardChoiceConfig(type: 'FOUR_ELEM_DISC_2', level: 3,  label: 'Discipline 2', options: kFourElementsDisciplines));
      if (level >= 6)  choices.add(WizardChoiceConfig(type: 'FOUR_ELEM_DISC_3', level: 6,  label: 'Discipline 3', options: kFourElementsDisciplines));
      if (level >= 11) choices.add(WizardChoiceConfig(type: 'FOUR_ELEM_DISC_4', level: 11, label: 'Discipline 4', options: kFourElementsDisciplines));
      if (level >= 17) choices.add(WizardChoiceConfig(type: 'FOUR_ELEM_DISC_5', level: 17, label: 'Discipline 5', options: kFourElementsDisciplines));
    }

    // ── College of Lore Bard: Bonus Proficiencies at lv 3 (pick 3 skills) ──
    if (subcIdx.contains('lore') && level >= 3) {
      choices.add(WizardChoiceConfig(
        type: 'LORE_BONUS_PROF', level: 3,
        label: 'Bonus Proficiencies (3 skills)',
        options: kSkills,
        pickCount: 3,
        required: false,
      ));
    }

    return choices;
  }

  bool get classFeatureChoicesDone =>
    classFeatureChoices.where((c) => c.required).every((c) => featureChoices.containsKey(c.key)) &&
    subclassFeatureChoices.every((c) => featureChoices.containsKey(c.key));

  bool get raceFeatureChoicesDone =>
    raceFeatureChoices.every((c) => featureChoices.containsKey(c.key)) &&
    subraceFeatureChoices.every((c) => featureChoices.containsKey(c.key));


  // Validación global
  // ────────────────────────────────────────────────────────────

  bool get canFinish =>
    preferencesValid &&
    classValid &&
    backgroundValid &&
    raceValid &&
    abilityScoresValid;

  bool get canProceedCurrentStep {
    // Equipment is optional — it never blocks navigation or creation
    if (_currentStep == WizardStep.equipment) return canFinish;
    return isStepCompleted(_currentStep);
  }

  //Submit
  // ────────────────────────────────────────────────────────────

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  bool _saveSuccess = false;
  bool get saveSuccess => _saveSuccess;

  int? _createdCharacterId;
  int? get createdCharacterId => _createdCharacterId;

  Object? get requiredFeatureChoices => null;

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
        magicalSecretSpellIds: [...magicalSecretIds, ...additionalMagicalSecretIds].toList(),
        classSkillIndices: _classSkillIndices.toList(),
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
        alignment: alignment,
        hair:   hair.isNotEmpty    ? hair    : null,
        eyes:   eyes.isNotEmpty    ? eyes    : null,
        skin:   skin.isNotEmpty    ? skin    : null,
        age:    age.isNotEmpty     ? age     : null,
        height: height.isNotEmpty  ? height  : null,
        weight: weight.isNotEmpty  ? weight  : null,
        useEncumbrance: useEncumbrance,
      );
      _createdCharacterId = result.id;

      // Auto-resolve the simple feature choices collected in the wizard
      if (featureChoices.isNotEmpty) {
        await _autoResolveFeatureChoices(_createdCharacterId!);
      }

      //añadir equipamiento inicial (si se ha seleccionado alguno, en paralelo al submit del personaje para no bloquearlo)
      if (selectedItemIds.isNotEmpty){
        for (final itemId in selectedItemIds){
          try{
            await _inventoryService.addItem(_createdCharacterId!, itemId);
          } catch (_) {
              // Si falla añadir un item, no bloqueamos el proceso ni mostramos error, simplemente se omite ese item
          }
        }
      }
      _saveSuccess = true;
    } catch (e) {
      _setError('Error saving character: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Carga automática al cambiar de paso

  /// Loads pending tasks for the newly created character and silently resolves
  /// any task whose key (taskType_relatedLevel) matches a wizard-collected choice.
  Future<void> _autoResolveFeatureChoices(int characterId) async {
    try {
      final tasks = await _pendingTaskService.getPendingTasks(characterId);
      for (final task in tasks) {
        final key = '${task.taskType}_${task.relatedLevel}';
        final choice = featureChoices[key];
        if (choice != null) {
          await _pendingTaskService.resolveTask(
            characterId: characterId,
            taskId: task.id,
            choice: choice,
          );
        }
      }
    } catch (_) {
      // Non-fatal: remaining choices are resolved from PendingTasksScreen
    }
  }

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
      case WizardStep.equipment:
      if (catalogItems.isEmpty) loadItemCatalog();
      default:
        break;
    }
  }
}