import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/dnd_choice_options.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
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

/// Elección de feature requerida – mostrada como sección en el paso Features del wizard.
class WizardChoiceConfig {
  /// Tipo de tarea D&D, p.ej. 'FIGHTING_STYLE', 'FAVORED_ENEMY'.
  final String type;
  /// Nivel en el que se adquiere esta feature.
  final int level;
  /// Etiqueta mostrada en la UI del wizard.
  final String label;
  /// Opciones seleccionables.
  final List<DndChoiceOption> options;
  /// Si es false, esta elección no bloquea classFeatureChoicesDone (p.ej. ASI).
  final bool required;
  /// Cuántos ítems debe elegir el usuario (1 = elección única, 2+ = multi-elección).
  final int pickCount;
  const WizardChoiceConfig({
    required this.type,
    required this.level,
    required this.label,
    required this.options,
    this.required = true,
    this.pickCount = 1,
  });
  /// Clave única para guardar / buscar la selección: p.ej. 'FAVORED_ENEMY_6'.
  String get key => '${type}_$level';
}


// - ViewModel -------------------
class CharacterCreatorViewModel extends ChangeNotifier {
  final WizardReferenceService _refService;
  final CharacterService       _charService;
  final InventoryService      _inventoryService;
  final PendingTaskService    _pendingTaskService;

  // ── Edit mode state ──────────────────────────────────────────────────────
  bool _editMode = false;
  bool get isEditMode => _editMode;
  bool _levelUpMode = false;
  bool get isLevelUpMode => _levelUpMode;
  /// En modo nivel-up: el nivel mínimo seleccionable (originalLevel + 1).
  int get levelUpMinLevel => _levelUpMode ? _originalLevel + 1 : 1;
  int? _editCharacterId;
  int _originalLevel = 1;
  /// IDs de spells que el personaje ya tenía antes de esta sesión de subida de nivel.
  Set<int> _preExistingSpellIds = {};
  int? _initialClassId;
  int? _initialSubclassId;
  int? _initialBackgroundId;
  int? _initialRaceId;

  CharacterCreatorViewModel({
    WizardReferenceService? refService,
    CharacterService?       charService,
    InventoryService?      inventoryService,
    PendingTaskService?    pendingTaskService,
  })  : _refService  = refService  ?? WizardReferenceService(),
        _charService = charService ?? CharacterService(),
        _inventoryService = inventoryService ?? InventoryService(),
        _pendingTaskService = pendingTaskService ?? PendingTaskService();

  /// Constructor nombrado que pre-rellena el wizard a partir de un personaje existente para el modo edición.
  CharacterCreatorViewModel.forEdit(
    PlayerCharacter char, {
    WizardReferenceService? refService,
    CharacterService?       charService,
    InventoryService?      inventoryService,
    PendingTaskService?    pendingTaskService,
  })  : _refService  = refService  ?? WizardReferenceService(),
        _charService = charService ?? CharacterService(),
        _inventoryService = inventoryService ?? InventoryService(),
        _pendingTaskService = pendingTaskService ?? PendingTaskService(),
        _editMode    = true,
        _editCharacterId = char.id,
        _originalLevel   = char.level,
        _initialClassId  = char.dndClassId,
        _initialSubclassId  = char.subclassId,
        _initialBackgroundId = char.backgroundId,
        _initialRaceId  = char.raceId {
    // Rellenar campos de texto/valor inmediatamente
    characterName    = char.name;
    selectedLevel    = char.level;
    alignment        = char.alignment;
    personality      = char.personalityTrait ?? '';
    ideals           = char.ideal ?? '';
    bonds            = char.bond ?? '';
    flaws            = char.flaw ?? '';
    hair             = char.hair ?? '';
    eyes             = char.eyes ?? '';
    skin             = char.skin ?? '';
    age              = char.age?.toString() ?? '';
    height           = char.height ?? '';
    weight           = char.weight ?? '';
    abilityDisplayMode = char.abilityDisplayMode;
    // Ability scores: pre-rellenar con los scores actuales del personaje (ya incluyen el bonus racial)
    for (final key in kAbilityNames) {
      abilityScores[key] = char.abilityScores[key] ?? 10;
    }
    scoreMethod = AbilityScoreMethod.manual;
    // Pre-rellenar los IDs de spells existentes para que el paso de spells los muestre como ya seleccionados
    _preExistingSpellIds = char.characterSpells.map((s) => s.spellId).toSet();
    selectedSpellIds.addAll(_preExistingSpellIds);
  }

  /// Constructor nombrado para subir de nivel a un personaje existente.
  /// Inicia el wizard en el paso Clase con el nivel pre-establecido en actual+1.
  CharacterCreatorViewModel.forLevelUp(
    PlayerCharacter char, {
    WizardReferenceService? refService,
    CharacterService?       charService,
    InventoryService?      inventoryService,
    PendingTaskService?    pendingTaskService,
  })  : _refService  = refService  ?? WizardReferenceService(),
        _charService = charService ?? CharacterService(),
        _inventoryService = inventoryService ?? InventoryService(),
        _pendingTaskService = pendingTaskService ?? PendingTaskService(),
        _editMode    = true,
        _levelUpMode = true,
        _editCharacterId = char.id,
        _originalLevel   = char.level,
        _initialClassId  = char.dndClassId,
        _initialSubclassId  = char.subclassId,
        _initialBackgroundId = char.backgroundId,
        _initialRaceId  = char.raceId {
    characterName    = char.name;
    selectedLevel    = char.level + 1;  // Pre-incremento: estamos subiendo de nivel
    // Pre-rellenar los IDs de spells existentes para que el paso de spells los muestre como ya seleccionados
    _preExistingSpellIds = char.characterSpells.map((s) => s.spellId).toSet();
    selectedSpellIds.addAll(_preExistingSpellIds);
    alignment        = char.alignment;
    personality      = char.personalityTrait ?? '';
    ideals           = char.ideal ?? '';
    bonds            = char.bond ?? '';
    flaws            = char.flaw ?? '';
    hair             = char.hair ?? '';
    eyes             = char.eyes ?? '';
    skin             = char.skin ?? '';
    age              = char.age?.toString() ?? '';
    height           = char.height ?? '';
    weight           = char.weight ?? '';
    abilityDisplayMode = char.abilityDisplayMode;
    for (final key in kAbilityNames) {
      abilityScores[key] = char.abilityScores[key] ?? 10;
    }
    scoreMethod = AbilityScoreMethod.manual;
    _currentStep = WizardStep.dndClass;
  }


  //- Navegación ------------------
  WizardStep _currentStep = WizardStep.preferences;
  WizardStep get currentStep => _currentStep;

  //Los pasos visibles dependen de si el personaje tiene spells

  List<WizardStep> get activeSteps {
    if (_levelUpMode) {
      final steps = [WizardStep.dndClass];
      if (isSpellcaster) steps.add(WizardStep.spells);
      return steps;
    }
    // Modo edición: wizard completo (Preferencias, Clase, Background, Raza, Ability Scores, + Spells si es spellcaster)
    if (_editMode) {
      final steps = [WizardStep.preferences, WizardStep.dndClass, WizardStep.background, WizardStep.race, WizardStep.abilityScores];
      if (isSpellcaster) steps.add(WizardStep.spells);
      steps.add(WizardStep.equipment);
      return steps;
    }
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
      // Lanzadores half (Ranger, Paladin): nivel de hechizo limitado por tabla PHB
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
      // Los slots de Magical Secrets se llevan aparte; restarlos de la tabla
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
  /// Wrapper público — permite que widgets externos disparen un rebuild sin
  /// violar la restricción @protected en notifyListeners().
  void notify() => notifyListeners();

  // - PASO 1: Preferencias
  // ────────────────────────────────────────────────────────────

  String characterName = '';
  // [DISABLED] XP/Encumbrance — not used. Always milestone, never encumbrance.
  // bool useMilestone = true;
  // bool useEncumbrance = false;
  bool useMilestone = true;      // mantenido para la llamada al backend; siempre true
  bool useEncumbrance = false;   // mantenido para la llamada al backend; siempre false
  String abilityDisplayMode = 'SCORES_TOP'; // 'SCORES_TOP' o 'MODIFIERS_TOP'

  void setName(String v) {characterName = v; _markDirty(WizardStep.preferences); notifyListeners();}
  void setAbilityDisplayMode(String v) {abilityDisplayMode = v; _markDirty(WizardStep.preferences); notifyListeners();}
  // [DISABLED] setMilestone/setEncumbrance — UI removed, no longer called.
  // void setMilestone(bool v) {useMilestone = v; _markDirty(WizardStep.preferences); notifyListeners();}
  // void setEncumbrance(bool v) {useEncumbrance = v; _markDirty(WizardStep.preferences); notifyListeners();}

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
      // Modo edición: seleccionar automáticamente la clase existente del personaje
      if (_editMode && _initialClassId != null && selectedClass == null) {
        final matches = classes.where((c) => c.id == _initialClassId);
        if (matches.isNotEmpty) {
          selectedClass = matches.first;
          await loadClassFeatures(selectedClass!.id);
          await _loadSubclassesFor(selectedClass!.id);
        }
      }
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
    // Limpiar elecciones de features de clase antes de limpiar selectedClass
    for (final c in classFeatureChoices) {
      featureChoices.remove(c.key);
    }
    // Limpiar también las sub-claves de multi-selección (p.ej. EXPERTISE_PICK_0_3)
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
      // Modo edición: seleccionar automáticamente la subclase existente del personaje
      if (_editMode && _initialSubclassId != null && selectedSubclass == null) {
        final matches = subclasses.where((s) => s.id == _initialSubclassId);
        if (matches.isNotEmpty) {
          selectedSubclass = matches.first;
          await _loadSubclassFeaturesFor(selectedSubclass!.id);
        }
      }
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
    // Limpiar elecciones de features específicas de subclase (Hunter, etc.)
    for (final c in subclassFeatureChoices) featureChoices.remove(c.key);
    // Eliminar también DRACONIC_ANCESTRY si fue una elección de clase impulsada por subclase
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
    selectedLevel = level.clamp(1, 20);
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

    bool get classValid {
      if (_editMode) return selectedClass != null;
      return selectedClass != null && classFeatureChoicesDone && classSkillPicksDone;
    }

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
      // Si esta skill tenía expertise, eliminar también esas elecciones
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

  /// Convierte un índice de skill con guiones en un nombre de pantalla.
  /// p.ej. 'sleight-of-hand' → 'Sleight Of Hand'
  String _skillIndexToDisplay(String idx) =>
      idx.split('-').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');

  /// Elimina cualquier featureChoice EXPERTISE_PICK_* cuyo valor coincida con [displayName].
  void _removeExpertisePicksForSkill(String displayName) {
    featureChoices.removeWhere(
      (k, v) => k.contains('EXPERTISE_PICK') && v == displayName,
    );
  }

  /// Normaliza un índice de skill del API: elimina el prefijo 'skill-'
  /// que llevan las proficiencias de background (p.ej. 'skill-insight' → 'insight').
  static String _normalizeSkillIndex(String s) =>
      s.startsWith('skill-') ? s.substring(6) : s;

  /// Skills otorgadas por el background seleccionado actualmente (indices normalizados).
  /// Usadas por el selector de skills de clase para bloquear las ya cubiertas.
  Set<String> get backgroundSkillIndices {
    if (selectedBackground == null) return const {};
    return selectedBackground!.skillProficiencies
        .map(_normalizeSkillIndex)
        .toSet();
  }

  /// Skills en las que el personaje ya tiene proficiency (elecciones de clase + background).
  /// Usadas para restringir las opciones de Expertise a elecciones válidas según las reglas de D&D 5e.
  Set<String> get _proficientSkillIndices {
    final indices = <String>{};
    // Elecciones de skill de clase (en minúsculas con guiones, p.ej. 'sleight-of-hand')
    indices.addAll(_classSkillIndices);
    // Proficiencias de skill del background — normalizar 'skill-X' → 'X'
    if (selectedBackground != null) {
      for (final s in selectedBackground!.skillProficiencies) {
        indices.add(_normalizeSkillIndex(s));
      }
    }
    return indices;
  }

  /// Devuelve solo las opciones de kSkills en las que el personaje ya tiene proficiency.
  /// Devuelve lista vacía si no hay ninguna seleccionada aún (Expertise requiere proficiency previa).
  List<DndChoiceOption> get proficientSkillOptions {
    final proficient = _proficientSkillIndices;
    if (proficient.isEmpty) return const [];
    // Normalizar el nombre de kSkills al formato de índice: 'Sleight of Hand' → 'sleight-of-hand'
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
      // Modo edición: seleccionar automáticamente el background existente del personaje
      if (_editMode && _initialBackgroundId != null && selectedBackground == null) {
        final matches = backgrounds.where((b) => b.id == _initialBackgroundId);
        if (matches.isNotEmpty) selectedBackground = matches.first;
      }
    } catch(e){
      _setError('Error loading backgrounds: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Selecciona el background y elimina las elecciones de skill de clase que entren en conflicto
  /// (la misma skill no puede venir a la vez de clase y background en D&D 5e).
  /// Devuelve los nombres de pantalla de las skills que se deseleccionaron de la clase.
  List<String> selectBackground(BackgroundOption b) {
    selectedBackground = b;
    _markDirty(WizardStep.background);

    // Encontrar skills de clase que solapan con las proficiencias de skill del background.
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

    // Devolver nombres legibles para mostrar una advertencia en la UI
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

  bool get backgroundValid {
    if (_editMode) return selectedBackground != null;
    return selectedBackground != null;
  }


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
      // Modo edición: seleccionar automáticamente la raza existente del personaje
      if (_editMode && _initialRaceId != null && selectedRace == null) {
        final matches = races.where((r) => r.id == _initialRaceId);
        if (matches.isNotEmpty) selectedRace = matches.first;
      }
    } catch(e) {
      _setError('Error loading races: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectRace(RaceOption r) {
    // Limpiar elecciones de features de raza y subraza anteriores antes de cambiar
    for (final c in raceFeatureChoices) featureChoices.remove(c.key);
    for (final c in subraceFeatureChoices) featureChoices.remove(c.key); // debe ejecutarse antes de limpiar la subraza
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
    // Limpiar elecciones de features de subraza anteriores antes de cambiar
    for (final c in subraceFeatureChoices) {
      featureChoices.remove(c.key);
    }
    selectedSubrace = s;
    _markDirty(WizardStep.race);
    notifyListeners();
  }

  bool get raceValid {
    if (_editMode) return selectedRace != null; // Raza pre-seleccionada; las elecciones de features ya se resolvieron en la creación
    return selectedRace != null &&
      (subraces.isEmpty || selectedSubrace != null) &&
      raceFeatureChoicesDone;
  }

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
  /// Cuántos slots de Magical Secrets están disponibles (PHB: 2 en nv10, +2 en nv14, +2 en nv18).
  int get magicalSecretsSlots {
    final className = selectedClass?.name.toLowerCase() ?? '';
    if (!className.contains('bard')) return 0;
    final lv = selectedLevel;
    if (lv >= 18) return 6;
    if (lv >= 14) return 4;
    if (lv >= 10) return 2;
    return 0;
  }

  /// 2 elecciones extra gratuitas para bards del College of Lore a nivel 6+ (Additional Magical Secrets).
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

  /// Elecciones de features de clase sin filtrar (todos los niveles hasta selectedLevel).
  List<WizardChoiceConfig> _buildClassFeatureChoices() {
    final choices = <WizardChoiceConfig>[];
    final className = selectedClass?.name.toLowerCase() ?? '';
    final subcName  = selectedSubclass?.name.toLowerCase() ?? '';
    final level     = selectedLevel;

    // Fighter: Fighting Style en el nivel 1
    if (className.contains('fighter') && level >= 1) {
      choices.add(const WizardChoiceConfig(
        type: 'FIGHTING_STYLE', level: 1,
        label: 'Fighting Style',
        options: kFightingStyles,
      ));
    }
    // Paladin: Fighting Style en el nivel 2
    if (className.contains('paladin') && level >= 2) {
      choices.add(const WizardChoiceConfig(
        type: 'FIGHTING_STYLE', level: 2,
        label: 'Fighting Style',
        options: kFightingStyles,
      ));
    }
    // Ranger: Fighting Style en el nivel 2
    if (className.contains('ranger') && level >= 2) {
      choices.add(const WizardChoiceConfig(
        type: 'FIGHTING_STYLE', level: 2,
        label: 'Fighting Style',
        options: kRangerFightingStyles,
      ));
    }
    // Ranger: Favored Enemy en los niveles 1, 6, 14
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
      // Natural Explorer Terrain en los niveles 1, 6, 10
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
    // ASI_OR_FEAT — disponible en los niveles 4, 8, 12, 16, 19 para la mayoría de clases;
    // Fighter también en 6, 14; Rogue también en 10, 18. Marcado como opcional (no bloqueante).
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
            options: const [], // gestionado por el widget especial de ASI, opciones no utilizadas aquí
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
    // ── Expertise: duplica el bonus de proficiency para las skills elegidas ───────────────
    // Rogue: nv 1 y nv 6 (2 skills cada uno)
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
    // Bard: nv 3 y nv 10 (2 skills cada uno)
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
    // Nv 3: 2 elecciones; nv 10 y 17: 1 elección cada uno
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

  /// Choices requeridas por la subraza seleccionada (p.ej. cantrip de High Elf, idioma extra).
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

  /// Choices requeridas por la clase seleccionada en el nivel seleccionado.
  /// En modo nivel-up solo devuelve elecciones para niveles NUEVOS (> originalLevel).
  List<WizardChoiceConfig> get classFeatureChoices {
    final rawChoices = _buildClassFeatureChoices();
    if (_levelUpMode) {
      return rawChoices.where((c) => c.level > _originalLevel).toList();
    }
    return rawChoices;
  }

  /// Todas las elecciones de features de clase para TODOS los niveles (usado en modo nivel-up
  /// para mostrar en modo lectura las elecciones previas).
  List<WizardChoiceConfig> get allClassFeatureChoices => _buildClassFeatureChoices();

  /// Mapa de clave de elección (p.ej. 'FAVORED_ENEMY_1') → nombre de opción seleccionada.
  final Map<String, String> featureChoices = {};

  void setFeatureChoice(String key, String value) {
    featureChoices[key] = value;
    notifyListeners();
  }

  /// Choices requeridas por la subclase seleccionada en el nivel seleccionado.
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

    // In level-up mode: only show choices for levels the character didn't have before
    if (_levelUpMode) {
      return choices.where((c) => c.level > _originalLevel).toList();
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

  bool get canFinish {
    if (_levelUpMode) return classValid;
    if (_editMode) return preferencesValid && classValid && backgroundValid && raceValid && abilityScoresValid;
    return preferencesValid &&
      classValid &&
      backgroundValid &&
      raceValid &&
      abilityScoresValid;
  }

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
    if (_editMode) {
      await _submitEdit();
      return;
    }
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
        abilityDisplayMode: abilityDisplayMode,
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

  /// Pre-carga todos los datos de referencia necesarios para el modo edición y
  /// selecciona automáticamente la clase, subclase, background y raza del personaje.
  Future<void> loadEditData() async {
    if (!_editMode) return;
    await loadClasses();     // also triggers _loadSubclassesFor → auto-selects subclass
    await loadBackgrounds();
    await loadRaces();
    if (isSpellcaster) await loadAvailableSpells();
  }

  /// Pre-carga los datos de clase para el modo nivel-up y selecciona la clase existente.
  Future<void> loadLevelUpData() async {
    if (!_levelUpMode) return;
    await loadClasses(); // auto-selects existing class + subclass
    if (isSpellcaster) await loadAvailableSpells();
    // Pre-populate previously resolved feature choices so the ClassOptionsScreen
    // can display them as read-only for old levels.
    if (_editCharacterId != null) {
      try {
        final tasks = await _pendingTaskService.getPendingTasks(_editCharacterId!);
        for (final t in tasks) {
          if (t.completed && t.resolvedChoice != null) {
            featureChoices['${t.taskType}_${t.relatedLevel}'] = t.resolvedChoice!;
          }
        }
      } catch (_) {} // silencioso
    }
  }

  /// Envía los cambios en modo edición: sube de nivel el personaje si el nivel ha aumentado,
  /// actualiza los campos del perfil y auto-resuelve las nuevas elecciones de features.
  Future<void> _submitEdit() async {
    if (_editCharacterId == null) return;
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      // 1. Level-up if needed (one POST per level gained)
      final levelsGained = selectedLevel - _originalLevel;
      if (levelsGained > 0) {
        for (int i = 0; i < levelsGained; i++) {
          await _charService.levelUp(_editCharacterId!);
        }
      }

      // 2. Actualizar metadatos del perfil
      await _charService.updateProfile(
        id: _editCharacterId!,
        name: characterName.trim(),
        alignment: alignment,
        personalityTrait: personality.isNotEmpty ? personality : null,
        ideal:   ideals.isNotEmpty   ? ideals   : null,
        bond:    bonds.isNotEmpty    ? bonds    : null,
        flaw:    flaws.isNotEmpty    ? flaws    : null,
        hair:    hair.isNotEmpty     ? hair     : null,
        eyes:    eyes.isNotEmpty     ? eyes     : null,
        skin:    skin.isNotEmpty     ? skin     : null,
        age:     age.isNotEmpty      ? int.tryParse(age) : null,
        height:  height.isNotEmpty   ? height   : null,
        weight:  weight.isNotEmpty   ? weight   : null,
        abilityDisplayMode: abilityDisplayMode,
        useEncumbrance: useEncumbrance,
        subclassId: selectedSubclass?.id,
        backgroundId: selectedBackground?.id,
        raceId: selectedRace?.id,
        subraceId: selectedSubrace?.id,
        abilityScores: _levelUpMode ? null : {
          'str': abilityScores['STR'] ?? 10,
          'dex': abilityScores['DEX'] ?? 10,
          'con': abilityScores['CON'] ?? 10,
          'int': abilityScores['INT'] ?? 10,
          'wis': abilityScores['WIS'] ?? 10,
          'cha': abilityScores['CHA'] ?? 10,
        },
      );

      // 3. Auto-resolve feature choices collected in the wizard (e.g. new level features)
      if (featureChoices.isNotEmpty) {
        await _autoResolveFeatureChoices(_editCharacterId!);
      }

      // 4. Sincronizar spells: nivel-up añade solo los nuevos; modo edición añade nuevos y elimina los deseleccionados
      if (_levelUpMode) {
        final newSpellIds = selectedSpellIds.difference(_preExistingSpellIds);
        if (newSpellIds.isNotEmpty) {
          await _charService.addSpellsToCharacter(
            id: _editCharacterId!,
            spellIds: newSpellIds.toList(),
          );
        }
      } else if (isSpellcaster) {
        final newSpells     = selectedSpellIds.difference(_preExistingSpellIds);
        final removedSpells = _preExistingSpellIds.difference(selectedSpellIds);
        if (newSpells.isNotEmpty) {
          await _charService.addSpellsToCharacter(
            id: _editCharacterId!,
            spellIds: newSpells.toList(),
          );
        }
        for (final spellId in removedSpells) {
          await _charService.removeSpell(
            characterId: _editCharacterId!,
            spellId: spellId,
          );
        }
      }

      _saveSuccess = true;
    } catch (e) {
      _setError('Error saving changes: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Carga las tareas pendientes del personaje recién creado y resuelve silenciosamente
  /// cualquier tarea cuya clave (taskType_relatedLevel) coincida con una elección recogida en el wizard.
  Future<void> _autoResolveFeatureChoices(int characterId) async {
    try {
      final tasks = await _pendingTaskService.getPendingTasks(characterId);
      for (final task in tasks) {
        final key = '${task.taskType}_${task.relatedLevel}';

        // Multi-pick tasks (e.g. EXPERTISE_PICK_0_1, EXPERTISE_PICK_1_1):
        // aggregate all individual picks into a comma-separated string.
        final multiKeys = featureChoices.keys
            .where((k) => k.startsWith('${task.taskType}_PICK_') && k.endsWith('_${task.relatedLevel}'))
            .toList()
          ..sort();
        final multiPicks = multiKeys
            .map((k) => featureChoices[k])
            .whereType<String>()
            .toList();

        final choice = multiPicks.isNotEmpty
            ? multiPicks.join(',')
            : featureChoices[key];

        if (choice != null && choice.isNotEmpty) {
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