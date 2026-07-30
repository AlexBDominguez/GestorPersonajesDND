import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/dnd_choice_options.dart';
import 'package:gestor_personajes_dnd/models/character/character_class_entry.dart';
import 'package:gestor_personajes_dnd/models/character/character_skill.dart';
import 'package:gestor_personajes_dnd/models/character/pending_task.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/content_source.dart';
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
enum WizardStep {preferences, dndClass, background, race, abilityScores, spells, equipment, classPicker}
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

/// Multiclase (Aurora_Fixes.md #17, fase 2b): configuración ya confirmada de una clase
/// adicional añadida durante la creación (además de la primaria). `featureChoices`/
/// `hpRolls` llevan claves relativas a ESTA clase (nivel 1..N), igual que si fuera la
/// única clase del wizard.
class _AdditionalClassConfig {
  final ClassOption classOption;
  final SubclassOption? subclass;
  final int level;
  final Map<String, String> featureChoices;
  final Map<int, int?> hpRolls;

  const _AdditionalClassConfig({
    required this.classOption,
    required this.subclass,
    required this.level,
    required this.featureChoices,
    required this.hpRolls,
  });
}

/// Multiclase (fase 2b): estado de la clase primaria guardado aparte mientras se
/// configura una clase adicional en los mismos campos compartidos del ViewModel.
class _PrimaryClassSnapshot {
  final ClassOption? selectedClass;
  final SubclassOption? selectedSubclass;
  final int selectedLevel;
  final List<ClassFeature> classFeatures;
  final List<SubclassOption> subclasses;
  final Map<String, String> featureChoices;
  final Map<int, int?> hpRolls;
  final Set<String> classSkillIndices;
  final int classSkillRequiredCount;

  const _PrimaryClassSnapshot({
    required this.selectedClass,
    required this.selectedSubclass,
    required this.selectedLevel,
    required this.classFeatures,
    required this.subclasses,
    required this.featureChoices,
    required this.hpRolls,
    required this.classSkillIndices,
    required this.classSkillRequiredCount,
  });
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
  /// Multiclase (fase 2a): "nivel ya alcanzado" a efectos de filtrar qué es viejo/nuevo
  /// en level-up — nivel EN LA CLASE elegida una vez hay una (`_levelUpTargetStartLevel`,
  /// 0 para una clase nueva), o nivel de personaje si todavía no se ha elegido ninguna
  /// (p.ej. antes de pasar por "classPicker"). Único punto de verdad para
  /// levelUpMinLevel/classFeatureChoices/subclassFeatureChoices — que antes usaban
  /// _originalLevel cada uno por su lado y se desincronizaban entre sí al multiclasear
  /// (ver fix de levelUpMinLevel: sin esto, elecciones como Fighting Style de una clase
  /// nueva quedaban filtradas como "ya vistas" y nunca se ofrecían en el wizard).
  int get _levelUpBaselineLevel =>
      _levelUpTargetClassId != null ? _levelUpTargetStartLevel : _originalLevel;
  /// En modo nivel-up: el nivel mínimo seleccionable en el dropdown de nivel.
  int get levelUpMinLevel => _levelUpMode ? _levelUpBaselineLevel + 1 : 1;
  int? _editCharacterId;
  int _originalLevel = 1;
  /// IDs de spells que el personaje ya tenía antes de esta sesión de subida de nivel.
  Set<int> _preExistingSpellIds = {};
  int? _initialClassId;
  int? _initialSubclassId;
  int? _initialBackgroundId;
  int? _initialRaceId;
  List<CharacterSkill> _editCharSkills = [];
  // Multiclase (Aurora_Fixes.md #17, fase 2a): clase elegida en el paso "classPicker" para
  // este level-up (existente o nueva) — null hasta que el jugador elige, en cuyo caso el
  // filtro de PendingTasks por clase no descarta nada (mismo comportamiento que antes de
  // esta fase). Ver también `_levelUpCharacterClasses` (paso classPicker).
  int? _levelUpTargetClassId;
  // Nivel EN LA CLASE elegida antes de esta sesión (0 para una clase nueva) — distinto de
  // _originalLevel (nivel TOTAL de personaje, usado para indexar hpRolls, que siguen
  // siendo por nivel de personaje sin cambios). selectedLevel pasa a significar "nivel en
  // la clase elegida" en vez de "nivel de personaje" una vez se elige clase en este flujo.
  int _levelUpTargetStartLevel = 0;
  List<CharacterClassEntry> _levelUpCharacterClasses = [];

  CharacterCreatorViewModel({
    WizardReferenceService? refService,
    CharacterService?       charService,
    InventoryService?      inventoryService,
    PendingTaskService?    pendingTaskService,
  })  : _refService  = refService  ?? WizardReferenceService(),
        _charService = charService ?? CharacterService(),
        _inventoryService = inventoryService ?? InventoryService(),
        _pendingTaskService = pendingTaskService ?? PendingTaskService() {
    _loadStepData(); // load content sources immediately on preferences step
  }

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
    // Guardar skills del personaje para pre-popular la selección de clase tras cargar los datos
    _editCharSkills = char.skills;
    // Pre-rellenar las tiradas de HP por nivel ya guardadas, para que "Manage HP" no
    // aparezca vacío al editar (bug #1 del backlog) y para no sobrescribirlas con null
    // si el usuario confirma la pantalla de clase sin tocar el HP.
    _hpRolls.addAll(char.hpRolls);
    // Restaurar las sources activas del personaje — sin esto, el wizard arrancaba
    // siempre con solo PHB, dejando invisibles en los catálogos filtrados cualquier
    // raza/clase/subclase/background de una source no-PHB (se "perdían" al editar).
    if (char.selectedSources.isNotEmpty) {
      selectedSources
        ..clear()
        ..addAll(char.selectedSources)
        ..add('PHB');
    }
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
    // Multiclase (Aurora_Fixes.md #17, fase 2a): clases del personaje para el paso
    // "classPicker". Fallback defensivo por si char.classes llega vacío (personaje sin
    // backfill todavía, o backend anterior a la fase 1) — sintetiza la clase legacy.
    _levelUpCharacterClasses = char.classes.isNotEmpty
        ? char.classes
        : (char.dndClassId != null
            ? [
                CharacterClassEntry(
                  id: 0,
                  dndClassId: char.dndClassId!,
                  dndClassName: char.dndClassName ?? '',
                  subclassId: char.subclassId,
                  subclassName: char.subclassName,
                  level: char.level,
                  classOrder: 0,
                ),
              ]
            : []);
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
    // Necesario para poder resolver nombre de skill → ID al sincronizar Expertise
    // ganada en este level-up (_syncExpertiseChanges en _submitEdit()).
    _editCharSkills = char.skills;
    // Restaurar las sources activas (ver forEdit) — necesario para que loadClasses()
    // pueda volver a encontrar la clase/subclase actual del personaje.
    if (char.selectedSources.isNotEmpty) {
      selectedSources
        ..clear()
        ..addAll(char.selectedSources)
        ..add('PHB');
    }
    _currentStep = WizardStep.classPicker;
  }


  //- Navegación ------------------
  WizardStep _currentStep = WizardStep.preferences;
  WizardStep get currentStep => _currentStep;

  //Los pasos visibles dependen de si el personaje tiene spells

  List<WizardStep> get activeSteps {
    if (_levelUpMode) {
      final steps = [WizardStep.classPicker, WizardStep.dndClass];
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
    if (className.contains('artificer')) {
      // Progresión propia (TCE/ERLW): 1º desde nivel 1, 2º en 7, 3º en 13, 4º en 18 — nunca más alto.
      if (level >= 18) return 4;
      if (level >= 13) return 3;
      if (level >= 7)  return 2;
      return 1;
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
    if (className.contains('artificer')) {
      const table = [0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4];
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
    if (className.contains('artificer')) {
      // Mod. INT + mitad del nivel (redondeado abajo), mínimo 1. No hay nivel mínimo:
      // a diferencia de Paladin/Ranger, el Artificer ya prepara hechizos desde nivel 1.
      return (abilityModifier('INT') + (level / 2).floor()).clamp(1, 99);
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
      case WizardStep.classPicker: return _levelUpTargetClassId != null;
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
  bool useMilestone = true;
  bool useEncumbrance = false;
  String abilityDisplayMode = 'SCORES_TOP';

  // Content sources
  List<ContentSource> availableContentSources = [];
  bool _sourcesLoading = false;
  bool get sourcesLoading => _sourcesLoading;
  // PHB siempre activo; el Set refleja las fuentes seleccionadas por el usuario.
  final Set<String> selectedSources = {'PHB'};

  List<String> get selectedSourcesList => selectedSources.toList();

  Future<void> loadContentSources() async {
    _sourcesLoading = true;
    notifyListeners();
    try {
      availableContentSources = await _refService.getContentSources();
    } catch (_) {
      availableContentSources = [];
    } finally {
      _sourcesLoading = false;
      notifyListeners();
    }
  }

  void toggleSource(String shortName) {
    if (shortName == 'PHB') return; // PHB siempre activo
    if (selectedSources.contains(shortName)) {
      selectedSources.remove(shortName);
    } else {
      selectedSources.add(shortName);
    }
    // Limpiar selecciones de clase/raza/trasfondo porque pueden ya no estar disponibles
    _clearCatalogSelections();
    _markDirty(WizardStep.preferences);
    notifyListeners();
  }

  void _clearCatalogSelections() {
    // Reutiliza el mismo núcleo de limpieza que clearClass()/deselectRace(),
    // para no dejar huérfanos _classSkillIndices, _classSkillRequiredCount,
    // featureChoices, _hpRolls o magical secrets (bug #2 del backlog).
    // No marca dndClass/race como dirty aquí: el usuario puede no haber
    // visitado esos pasos todavía y no deben aparecer con "!" prematuramente.
    _resetClassState();
    classes = [];
    _resetRaceState();
    races = [];
    backgrounds = [];
    selectedBackground = null;
  }

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

  // Multiclase (Aurora_Fixes.md #17, fase 2b): permite configurar varias clases dentro
  // del propio wizard de creación reutilizando los mismos campos compartidos de arriba
  // (selectedClass/selectedSubclass/selectedLevel/featureChoices/_hpRolls) para "la clase
  // que se está configurando ahora mismo" -- nunca hay dos clases compartiéndolos a la
  // vez. Al empezar a configurar una clase adicional se guarda aparte (snapshot) lo que
  // hubiera en esos campos y se limpian; al confirmar o cancelar se archiva o se descarta
  // y se restaura el snapshot. Ver setHpRolls()/clearClass() para los puntos de enganche.
  final List<_AdditionalClassConfig> _additionalClasses = [];
  List<_AdditionalClassConfig> get additionalClasses => List.unmodifiable(_additionalClasses);
  bool _configuringAdditionalClass = false;
  bool get isConfiguringAdditionalClass => _configuringAdditionalClass;
  _PrimaryClassSnapshot? _primaryClassSnapshot;

  /// Empieza a configurar una clase adicional: guarda aparte la clase actualmente en los
  /// campos compartidos (solo la primera vez -- si ya había un snapshot de una clase
  /// adicional anterior ya confirmada, no se pisa) y los deja en blanco para la nueva.
  void startConfiguringAdditionalClass() {
    _primaryClassSnapshot ??= _PrimaryClassSnapshot(
      selectedClass: selectedClass,
      selectedSubclass: selectedSubclass,
      selectedLevel: selectedLevel,
      classFeatures: List.of(classFeatures),
      subclasses: List.of(subclasses),
      featureChoices: Map.of(featureChoices),
      hpRolls: Map.of(_hpRolls),
      classSkillIndices: Set.of(_classSkillIndices),
      classSkillRequiredCount: _classSkillRequiredCount,
    );
    featureChoices.clear();
    _hpRolls.clear();
    // Una clase adicional nunca otorga elección de skills (regla real, ver guard en
    // class_options_screen.dart), pero se limpia igualmente por si acaso -- que quede
    // vacío durante toda la sub-sesión, nunca con las skills de la clase primaria.
    _classSkillIndices.clear();
    _classSkillRequiredCount = 0;
    selectedClass = null;
    selectedSubclass = null;
    subclasses = [];
    classFeatures = [];
    selectedLevel = 1;
    _configuringAdditionalClass = true;
    notifyListeners();
  }

  /// Descarta o archiva la clase adicional en construcción y restaura el snapshot
  /// primario. `save`=true la guarda en additionalClasses antes de restaurar (confirmar);
  /// `save`=false la descarta (cancelar / vuelta atrás sin confirmar).
  void _endConfiguringAdditionalClass({required bool save}) {
    if (!_configuringAdditionalClass) return;
    if (save && selectedClass != null) {
      _additionalClasses.add(_AdditionalClassConfig(
        classOption: selectedClass!,
        subclass: selectedSubclass,
        level: selectedLevel,
        featureChoices: Map.of(featureChoices),
        hpRolls: Map.of(_hpRolls),
      ));
    }
    final snap = _primaryClassSnapshot!;
    selectedClass = snap.selectedClass;
    selectedSubclass = snap.selectedSubclass;
    selectedLevel = snap.selectedLevel;
    classFeatures = snap.classFeatures;
    subclasses = snap.subclasses;
    featureChoices
      ..clear()
      ..addAll(snap.featureChoices);
    _hpRolls
      ..clear()
      ..addAll(snap.hpRolls);
    _classSkillIndices
      ..clear()
      ..addAll(snap.classSkillIndices);
    _classSkillRequiredCount = snap.classSkillRequiredCount;
    _configuringAdditionalClass = false;
  }

  /// Limpia un flujo de "clase adicional" que quedó a medias (p.ej. el usuario volvió
  /// atrás desde ClassDetailScreen con la flecha, sin llegar a confirmar ni cancelar
  /// explícitamente) — restaura la clase primaria sin archivar nada.
  void cancelDanglingAdditionalClass() {
    _endConfiguringAdditionalClass(save: false);
    notifyListeners();
  }

  void removeAdditionalClass(int index) {
    if (index < 0 || index >= _additionalClasses.length) return;
    _additionalClasses.removeAt(index);
    notifyListeners();
  }

  Future<void> loadClasses() async {
    _setLoading(true);
    _setError(null);
    try{
      classes = await _refService.getClasses(sources: selectedSourcesList);
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
    if (_levelUpMode) {
      // Multiclase (Aurora_Fixes.md #17, fase 2a): en level-up, elegir una clase del
      // catálogo (este método) solo pasa al tomar una clase NUEVA — la clase que se
      // continúa se auto-selecciona en loadClasses() sin pasar por aquí (ver
      // selectLevelUpTargetClass) — así que siempre es nivel 1 en esa clase, no
      // nivel de personaje + 1.
      _levelUpTargetClassId = c.id;
      _levelUpTargetStartLevel = 0;
      selectedLevel = 1;
    }
    _markDirty(WizardStep.dndClass);
    notifyListeners();
    _loadSubclassesFor(c.id);
  }

  /// Multiclase (Aurora_Fixes.md #17, fase 2a): getters para el paso "classPicker".
  List<CharacterClassEntry> get characterClasses => _levelUpCharacterClasses;
  int? get levelUpTargetClassId => _levelUpTargetClassId;

  /// El jugador elige subir de nivel una clase que YA tiene (existente en
  /// `characterClasses`), no una nueva — busca su ClassOption/SubclassOption en el
  /// catálogo y fija selectedLevel = nivel-en-esa-clase + 1 (no nivel de personaje + 1).
  Future<void> selectLevelUpTargetClass(CharacterClassEntry entry) async {
    _levelUpTargetClassId = entry.dndClassId;
    _levelUpTargetStartLevel = entry.level;
    selectedSubclass = null;
    subclasses = [];
    if (classes.isEmpty) await loadClasses();
    final match = classes.where((c) => c.id == entry.dndClassId);
    if (match.isNotEmpty) selectedClass = match.first;
    selectedLevel = entry.level + 1;
    if (selectedClass != null) {
      await loadClassFeatures(selectedClass!.id);
      await _loadSubclassesFor(selectedClass!.id);
      if (entry.subclassId != null) {
        final subMatch = subclasses.where((s) => s.id == entry.subclassId);
        if (subMatch.isNotEmpty) selectedSubclass = subMatch.first;
      }
    }
    // Re-ejecutar ahora que _levelUpTargetClassId ya se conoce, para que las elecciones
    // ya resueltas de ESTA clase (y no de otra) se prellenen correctamente.
    await _prePopulateFeatureChoicesForEdit();
    _markDirty(WizardStep.classPicker);
    notifyListeners();
  }

  void clearClass() {
    // Multiclase (fase 2b): si se estaba configurando una clase adicional, "Cancel" en
    // ClassOptionsScreen (que llama a este método, sin cambios en ese archivo) descarta
    // esa clase y restaura la primaria, en vez del reset completo de siempre.
    if (_configuringAdditionalClass) {
      _endConfiguringAdditionalClass(save: false);
      notifyListeners();
      return;
    }
    _resetClassState();
    _markDirty(WizardStep.dndClass);
    notifyListeners();
  }

  /// Limpieza pura del estado de clase/subclase, sin marcar el paso como
  /// dirty ni notificar — usado por clearClass() y por _clearCatalogSelections()
  /// (esta última no debe forzar el "!" en pasos que el usuario no ha visitado).
  void _resetClassState() {
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
  }

  bool get isLoadingSubclasses => subclasses.isEmpty && selectedClass != null;

  Future<void> loadSubclasses(int classId) async {
    try {
      subclasses = await _refService.getSubclasses(classId, sources: selectedSourcesList);
    } catch (_) {
      subclasses = [];
    }
    notifyListeners();
  }

  Future<void> _loadSubclassesFor(int classId) async {
    subclasses = [];
    notifyListeners();
    try {
      subclasses = await _refService.getSubclasses(classId, sources: selectedSourcesList);
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
    // Multiclase (fase 2b): _onConfirm() de ClassOptionsScreen llama a setLevel() y luego
    // a este método como último paso antes de cerrar la pantalla con éxito -- si se
    // estaba configurando una clase adicional, es la señal de "confirmado": se archiva y
    // se restaura la clase primaria, sin tocar ClassOptionsScreen.
    if (_configuringAdditionalClass) {
      _endConfiguringAdditionalClass(save: true);
    }
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

  /// En modo edición: pre-pobla _classSkillIndices a partir de las skills
  /// proficientes del personaje que coincidan con las permitidas por la clase
  /// y que NO vengan del background. Requiere clase y background ya cargados.
  void _prePopulateClassSkillsForEdit() {
    if (!_editMode || selectedClass == null || _editCharSkills.isEmpty) return;
    if (_classSkillIndices.isNotEmpty) return;

    final proficientNames = _editCharSkills
        .where((s) => s.proficient)
        .map((s) => s.skillName.toLowerCase())
        .toSet();

    final bgNames = backgroundSkillIndices
        .map((idx) => _skillIndexToDisplay(idx).toLowerCase())
        .toSet();

    for (final idx in selectedClass!.allowedSkillIndices) {
      final name = _skillIndexToDisplay(idx).toLowerCase();
      if (proficientNames.contains(name) && !bgNames.contains(name)) {
        _classSkillIndices.add(idx);
      }
    }
    // Snapshot de la selección original — usado en _submitEdit() para detectar
    // qué skills añadió/quitó el usuario y sincronizar solo esos cambios.
    _originalClassSkillIndices = Set.of(_classSkillIndices);
    notifyListeners();
  }

  /// Selección de skills de clase tal como estaba al entrar en modo edición
  /// (snapshot tomado por _prePopulateClassSkillsForEdit). Permite diffear
  /// contra _classSkillIndices al guardar y sincronizar solo lo que cambió.
  Set<String> _originalClassSkillIndices = {};

  /// En modo edición: pre-pobla los picks de Expertise (EXPERTISE_PICK_n_level) a partir
  /// de las skills con expertise=true en el personaje. Necesario porque, igual que las
  /// class skills, Expertise se aplica directamente en la creación (PlayerCharacterService
  /// .create(), vía dto.getExpertiseSkillNames()) y NUNCA pasa por una PendingTask — por
  /// eso _prePopulateFeatureChoicesForEdit() (que solo lee PendingTasks) nunca encuentra
  /// nada que restaurar y el picker aparecía vacío al editar.
  void _prePopulateExpertiseForEdit() {
    if (!_editMode || selectedClass == null || _editCharSkills.isEmpty) return;

    final expertNames = _editCharSkills.where((s) => s.expertise).map((s) => s.skillName).toList();
    if (expertNames.isEmpty) return;

    final expertiseConfigs = allClassFeatureChoices.where((c) => c.type == 'EXPERTISE').toList()
      ..sort((a, b) => a.level.compareTo(b.level));

    int idx = 0;
    for (final config in expertiseConfigs) {
      final picks = <String>[];
      for (int i = 0; i < config.pickCount && idx < expertNames.length; i++, idx++) {
        featureChoices['EXPERTISE_PICK_${i}_${config.level}'] = expertNames[idx];
        picks.add(expertNames[idx]);
      }
      if (picks.isNotEmpty) featureChoices[config.key] = picks.join(', ');
    }
    // Snapshot — usado en _submitEdit() para detectar qué skills de expertise
    // añadió/quitó el usuario y sincronizar solo esos cambios.
    _originalExpertiseSkillNames = expertNames.take(idx).toSet();
    notifyListeners();
  }

  /// Skills con expertise tal como estaban al entrar en modo edición (snapshot tomado
  /// por _prePopulateExpertiseForEdit). Permite diffear al guardar.
  Set<String> _originalExpertiseSkillNames = {};

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
    // Lore Bard Bonus Proficiencies: 'Sleight of Hand' → 'sleight-of-hand'
    for (final name in loreBonusProfSkillNames) {
      indices.add(name.toLowerCase().replaceAll(' ', '-'));
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

  /// Nombres en formato kSkills de las skills elegidas como Lore Bard Bonus Proficiencies.
  /// Usados para impedir que se elijan las mismas skills en ambas secciones.
  Set<String> get loreBonusProfSkillNames {
    final result = <String>{};
    for (int i = 0; i < 3; i++) {
      final v = featureChoices['LORE_BONUS_PROF_PICK_${i}_3'];
      if (v != null) result.add(v);
    }
    return result;
  }

  /// Nombres en formato kSkills de las skills de clase elegidas actualmente.
  /// Usados para impedir conflictos con Lore Bard Bonus Proficiencies.
  Set<String> get classSkillKSkillsNames {
    String indexToKSkillsName(String idx) {
      final norm = idx.replaceAll('-', ' ');
      for (final s in kSkills) {
        if (s.name.toLowerCase() == norm) return s.name;
      }
      return _skillIndexToDisplay(idx);
    }
    return _classSkillIndices.map(indexToKSkillsName).toSet();
  }

  // PASO 3: Background
  // ────────────────────────────────────────────────────────────
  List<BackgroundOption> backgrounds = [];
  BackgroundOption? selectedBackground;

  Future<void> loadBackgrounds() async {
    _setLoading(true);
    _setError(null);
    try{
      backgrounds = await _refService.getBackgrounds(sources: selectedSourcesList);
      backgrounds.sort((a, b) => a.name.compareTo(b.name));
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
      races = await _refService.getRaces(sources: selectedSourcesList);
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

  /// Colapsa la raza actualmente seleccionada (segundo tap sobre la misma raza).
  void deselectRace() {
    _resetRaceState();
    _markDirty(WizardStep.race);
    notifyListeners();
  }

  /// Limpieza pura del estado de raza/subraza, sin marcar el paso como dirty
  /// ni notificar — usado por deselectRace() y por _clearCatalogSelections().
  void _resetRaceState() {
    for (final c in raceFeatureChoices) featureChoices.remove(c.key);
    for (final c in subraceFeatureChoices) featureChoices.remove(c.key);
    selectedRace = null;
    selectedSubrace = null;
    subraces = [];
  }

  Future<void> _loadSubracesFor(int raceId) async {
    isLoadingSubraces = true;
    notifyListeners();
    try {
      subraces = await _refService.getSubRaces(raceId, sources: selectedSourcesList);
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
        sources: selectedSourcesList,
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
        sources: selectedSourcesList,
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
    // Blood Hunter: Fighting Style en el nivel 2 (opciones limitadas)
    if ((className.contains('blood hunter') || className.contains('blood-hunter')) && level >= 2) {
      choices.add(const WizardChoiceConfig(
        type: 'FIGHTING_STYLE', level: 2,
        label: 'Fighting Style',
        options: kBloodHunterFightingStyles,
      ));
    }
    // Blood Hunter: Blood Curse en los niveles 1 (Blood Maledict), 6, 10, 14, 18
    if (className.contains('blood hunter') || className.contains('blood-hunter')) {
      for (final l in [1, 6, 10, 14, 18]) {
        if (level >= l) {
          choices.add(WizardChoiceConfig(
            type: 'BLOOD_CURSE_CHOICE', level: l,
            label: l == 1 ? 'Blood Curse (Blood Maledict)' : 'Blood Curse (lv $l)',
            options: kBloodCurses,
          ));
        }
      }
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
    // Fighter también en 6, 14; Rogue también en 10, 18. Artificer en 20 (no 19).
    // Marcado como opcional (no bloqueante).
    {
      final List<int> asiLevels;
      if (className.contains('fighter')) {
        asiLevels = [4, 6, 8, 12, 14, 16, 19];
      } else if (className.contains('rogue')) {
        asiLevels = [4, 8, 10, 12, 16, 18];
      } else if (className.contains('artificer')) {
        asiLevels = [4, 8, 12, 16, 20];
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
    // ── Artificer Infusions (Infuse Item) ─────────────────────────────────────
    // 4 conocidas a nivel 2, +2 en 6/10/14/18. A diferencia de Eldritch Invocations (una sola
    // PendingTask acumulativa), el backend crea una tarea INFUSION_CHOICE nueva por cada hito
    // (mismo class_level_feature por nivel que Expertise), así que cada hito es su propio
    // WizardChoiceConfig con su propio pickCount incremental, no uno acumulativo.
    if (className.contains('artificer')) {
      const milestones = {2: 4, 6: 2, 10: 2, 14: 2, 18: 2};
      for (final entry in milestones.entries) {
        if (level >= entry.key) {
          choices.add(WizardChoiceConfig(
            type: 'INFUSION_CHOICE', level: entry.key,
            label: 'Artificer Infusions (lv ${entry.key})',
            options: kArtificerInfusionsUpToLevel(entry.key),
            pickCount: entry.value,
            required: false,
          ));
        }
      }
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
      return rawChoices.where((c) => c.level > _levelUpBaselineLevel).toList();
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
      // Type debe coincidir EXACTAMENTE con PlayerCharacterService.createSubclassTask
      // ("TOTEM_ATTUNEMENT", sin "IC") — antes decía 'TOTEMIC_ATTUNEMENT' y la elección
      // nunca se resolvía contra ninguna PendingTask real (bug #1 del backlog).
      if (level >= 14) choices.add(const WizardChoiceConfig(type: 'TOTEM_ATTUNEMENT', level: 14, label: 'Totemic Attunement',  options: kTotemicAttunement));
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

    // Rune Knight Fighter — 2 runas a nivel 3, +1 a nivel 7/10/15 (5 en total). Slots
    // numerados igual que Battle Master Maneuvers/Four Elements Disciplines: el backend crea
    // una PendingTask "RUNE_CHOICE" *distinta* en cada uno de esos 4 niveles (ver
    // PlayerCharacterService.createSubclassLevelTasks), así que cada slot debe llevar el
    // `level` del hito en el que se desbloquea, no todos nivel 3 — _resolveSlottedChoice()
    // agrupa los slots por ese nivel para formar el "choice" de cada tarea por separado.
    if (subcIdx.contains('rune_knight') || subcIdx.contains('rune-knight') || subcIdx.contains('rune knight')) {
      if (level >= 3)  choices.add(WizardChoiceConfig(type: 'RUNE_SLOT_1', level: 3,  label: 'Rune 1', options: kRuneOptions));
      if (level >= 3)  choices.add(WizardChoiceConfig(type: 'RUNE_SLOT_2', level: 3,  label: 'Rune 2', options: kRuneOptions));
      if (level >= 7)  choices.add(WizardChoiceConfig(type: 'RUNE_SLOT_3', level: 7,  label: 'Rune 3', options: kRuneOptions));
      if (level >= 10) choices.add(WizardChoiceConfig(type: 'RUNE_SLOT_4', level: 10, label: 'Rune 4', options: kRuneOptions));
      if (level >= 15) choices.add(WizardChoiceConfig(type: 'RUNE_SLOT_5', level: 15, label: 'Rune 5', options: kRuneOptions));
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

    // Draconic Bloodline Sorcerer: Draconic Ancestry at level 1
    if (subcIdx.contains('draconic') && level >= 1) {
      choices.add(const WizardChoiceConfig(
        type: 'DRACONIC_ANCESTRY', level: 1,
        label: 'Draconic Ancestry',
        options: kDraconicAncestries,
      ));
    }

    // Gunslinger Fighter: 2 Trick Shots at lv3, +1 at lv7/10/15/18
    if (subcIdx.contains('gunslinger')) {
      if (level >= 3) {
        choices.add(WizardChoiceConfig(type: 'TRICK_SHOT_CHOICE_1', level: 3, label: 'Trick Shot 1', options: kTrickShots));
        choices.add(WizardChoiceConfig(type: 'TRICK_SHOT_CHOICE_2', level: 3, label: 'Trick Shot 2', options: kTrickShots));
      }
      if (level >= 7)  choices.add(WizardChoiceConfig(type: 'TRICK_SHOT_CHOICE_3', level: 7,  label: 'Trick Shot 3',  options: kTrickShots));
      if (level >= 10) choices.add(WizardChoiceConfig(type: 'TRICK_SHOT_CHOICE_4', level: 10, label: 'Trick Shot 4',  options: kTrickShots));
      if (level >= 15) choices.add(WizardChoiceConfig(type: 'TRICK_SHOT_CHOICE_5', level: 15, label: 'Trick Shot 5',  options: kTrickShots));
      if (level >= 18) choices.add(WizardChoiceConfig(type: 'TRICK_SHOT_CHOICE_6', level: 18, label: 'Trick Shot 6',  options: kTrickShots));
    }

    // Blood Hunter — Order of the Lycan: choose Hybrid Transformation type at lv3
    if (subcIdx.contains('lycan') && level >= 3) {
      choices.add(const WizardChoiceConfig(
        type: 'LYCAN_TYPE', level: 3,
        label: 'Hybrid Transformation',
        options: kLycanTypes,
      ));
    }

    // Blood Hunter — Order of the Profane Soul: choose patron at lv3
    if (subcIdx.contains('profane-soul') || subcIdx.contains('profane soul')) {
      if (level >= 3) {
        choices.add(const WizardChoiceConfig(
          type: 'PROFANE_SOUL_PATRON', level: 3,
          label: 'Profane Soul Patron',
          options: kProfaneSoulPatrons,
        ));
      }
    }

    // Blood Hunter — Order of the Mutant: number of mutagenic formulas known
    // scales with Intelligence modifier (minimum 1), not a fixed single pick.
    if (subcIdx.contains('mutant') && level >= 3) {
      final formulaCount = abilityModifier('INT').clamp(1, 99);
      choices.add(WizardChoiceConfig(
        type: 'MUTAGEN_CHOICE', level: 3,
        label: 'Mutagenic Formula',
        options: kMutagens,
        pickCount: formulaCount,
        required: false,
      ));
    }

    // In level-up mode: only show choices for levels the character didn't have before
    if (_levelUpMode) {
      return choices.where((c) => c.level > _levelUpBaselineLevel).toList();
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

  // Multiclase (Aurora_Fixes.md #17, fase 2a): avisos no bloqueantes devueltos por el
  // backend al subir de nivel (prerrequisitos de característica, elecciones de
  // proficiency no automatizadas) — para que la pantalla los muestre tras guardar.
  List<String> _lastLevelUpWarnings = [];
  List<String> get lastLevelUpWarnings => _lastLevelUpWarnings;

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
        subraceId:    selectedSubrace?.id,
        spellIds:    selectedSpellIds.toList(),
        magicalSecretSpellIds: [...magicalSecretIds, ...additionalMagicalSecretIds].toList(),
        classSkillIndices: _classSkillIndices.toList(),
        expertiseSkillNames: featureChoices.entries
            .where((e) => e.key.startsWith('EXPERTISE_PICK_') && e.value.isNotEmpty)
            .map((e) => e.value)
            .toList(),
        hpRolls: Map.fromEntries(_hpRolls.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!))),
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
        selectedSources: selectedSourcesList,
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

      // Multiclase (Aurora_Fixes.md #17, fase 2b): clases adicionales configuradas en el
      // wizard, enviadas ahora como subidas de nivel secuenciales sobre el personaje ya
      // creado -- una llamada por nivel de esa clase, igual que hace _submitEdit() para
      // un level-up normal. El backend sigue sin saber nada de "creación multiclase": es
      // el mismo mecanismo ya probado de la fase 2a, solo que encadenado automáticamente
      // aquí en vez de a través del wizard de level-up.
      final creationWarnings = <String>[];
      for (final add in _additionalClasses) {
        for (int lvl = 1; lvl <= add.level; lvl++) {
          final result = await _charService.levelUp(
            _createdCharacterId!,
            hpRoll: lvl > 1 ? add.hpRolls[lvl] : null,
            classId: add.classOption.id,
            // subclassId solo en la última llamada: el backend valida que el nivel-en-
            // esta-clase alcanzado ya cumpla el mínimo de la subclase, y por construcción
            // el usuario solo pudo elegirla en el wizard si el nivel ya estaba ahí.
            subclassId: (lvl == add.level) ? add.subclass?.id : null,
          );
          creationWarnings.addAll(result.warnings);
        }
        // Resolver las PendingTask de ESTA clase adicional -- se intercambia featureChoices/
        // _levelUpTargetClassId por su propio snapshot (claves de nivel relativas a ella)
        // para no arrastrar las elecciones de la clase primaria, y se restauran después.
        final previousFeatureChoices = Map<String, String>.from(featureChoices);
        final previousTargetClassId = _levelUpTargetClassId;
        featureChoices
          ..clear()
          ..addAll(add.featureChoices);
        _levelUpTargetClassId = add.classOption.id;
        await _autoResolveFeatureChoices(_createdCharacterId!);
        featureChoices
          ..clear()
          ..addAll(previousFeatureChoices);
        _levelUpTargetClassId = previousTargetClassId;
      }
      _lastLevelUpWarnings = creationWarnings;

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
    _prePopulateClassSkillsForEdit(); // cross-reference skills una vez clase + background están listos
    _prePopulateExpertiseForEdit();
    await loadRaces();
    if (isSpellcaster) {
      await loadAvailableSpells();
      // En edición los hechizos ya existentes se pre-cargan en el constructor — el
      // paso ya es válido desde el principio, no depende de que el usuario lo visite
      // (a diferencia de la creación, donde forzamos al menos una visita).
      _spellsStepVisited = true;
    }
    await _prePopulateFeatureChoicesForEdit();
  }

  /// Pre-carga en featureChoices las elecciones de features ya resueltas (Fighting Style,
  /// Expertise, Favored Enemy, elecciones de raza/subraza, etc.) para que no aparezcan
  /// vacías al entrar en modo edición — de lo contrario el usuario las ve como pendientes
  /// y, si las vuelve a elegir, puede sobrescribir la elección original (bug #1 del backlog).
  /// Multiclase (Aurora_Fixes.md #17, fase 2a): en modo level-up, solo se rellenan las
  /// elecciones ya resueltas de la clase objetivo (`_levelUpTargetClassId`) — si todavía no
  /// se ha elegido (p.ej. la primera carga, antes de pasar por el paso "classPicker"), el
  /// filtro no descarta nada (mismo comportamiento que antes de esta fase, ver
  /// `_taskBelongsToLevelUpTarget`). Se vuelve a llamar tras elegir clase, ver setLevelUpTargetClass().
  Future<void> _prePopulateFeatureChoicesForEdit() async {
    if (_editCharacterId == null) return;
    try {
      final tasks = (await _pendingTaskService.getPendingTasks(_editCharacterId!))
          .where(_taskBelongsToLevelUpTarget);
      final allConfigs = [
        ...allClassFeatureChoices,
        ...subclassFeatureChoices,
        ...raceFeatureChoices,
        ...subraceFeatureChoices,
      ];
      for (final t in tasks) {
        if (!t.completed || t.resolvedChoice == null) continue;
        final key = '${t.taskType}_${t.relatedLevel}';
        if (t.taskType == 'ASI_OR_FEAT') {
          _prePopulateAsiOrFeatChoice(t.relatedLevel, t.resolvedChoice!);
          continue;
        }
        if (_slottedChoicePrefixByTaskType.containsKey(t.taskType)) {
          _prePopulateSlottedChoice(
              _slottedChoicePrefixByTaskType[t.taskType]!,
              t.relatedLevel,
              t.resolvedChoice!,
              allConfigs);
          continue;
        }
        featureChoices[key] = t.resolvedChoice!;
        final config = allConfigs.where((c) => c.key == key).firstOrNull;
        if (config != null && config.pickCount > 1) {
          final picks = t.resolvedChoice!.split(',').map((s) => s.trim()).toList();
          for (int i = 0; i < picks.length && i < config.pickCount; i++) {
            featureChoices['${t.taskType}_PICK_${i}_${t.relatedLevel}'] = picks[i];
          }
        }
      }
      notifyListeners();
    } catch (_) {} // silencioso, igual que loadLevelUpData
  }

  /// Reparte un resolvedChoice separado por comas ('Maneuver A,Maneuver B,...') entre
  /// los slots numerados del wizard para ese nivel (p.ej. BATTLEMASTER_MANEUVER_1_3,
  /// BATTLEMASTER_MANEUVER_2_3...), en el mismo orden en que aparecen en [allConfigs].
  void _prePopulateSlottedChoice(String prefix, int level, String resolvedChoice,
      List<WizardChoiceConfig> allConfigs) {
    final names = resolvedChoice.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (names.isEmpty) return;
    final slotKeys = allConfigs
        .where((c) => c.level == level && c.type.startsWith('${prefix}_'))
        .map((c) => c.key)
        .toList();
    for (int i = 0; i < names.length && i < slotKeys.length; i++) {
      featureChoices[slotKeys[i]] = names[i];
    }
  }

  /// Reconstruye las claves locales del wizard (ASI_A_n, ASI_B_n, FEAT_CHOICE_n y el badge
  /// resumen) a partir del string que guarda el backend ('ASI:STR:+2', 'ASI:STR:+1+DEX:+1' o
  /// 'FEAT:NombreDote'). Si el valor no tiene ese formato — personajes de prueba creados antes
  /// de este fix, que guardaron literalmente el texto del badge ('Str / Con' / 'Feat') — no se
  /// pre-rellena nada y la elección aparece vacía, igual que antes.
  void _prePopulateAsiOrFeatChoice(int level, String resolvedChoice) {
    if (resolvedChoice.startsWith('FEAT:')) {
      featureChoices['FEAT_CHOICE_$level'] = resolvedChoice.substring(5).trim();
      featureChoices['ASI_OR_FEAT_$level'] = 'Feat';
      return;
    }
    if (!resolvedChoice.startsWith('ASI:')) return;

    final parts = resolvedChoice.substring(4).split(':');
    String? abbrevA, abbrevB;
    if (parts.length == 2) {
      abbrevA = abbrevB = parts[0];
    } else if (parts.length == 3) {
      abbrevA = parts[0];
      abbrevB = parts[1].split('+').last;
    }
    if (abbrevA == null || abbrevB == null) return;

    String? fullName(String abbrev) =>
        kAbilityScoreNames.where((a) => a.description == abbrev).firstOrNull?.name;
    final nameA = fullName(abbrevA);
    final nameB = fullName(abbrevB);
    if (nameA == null || nameB == null) return;

    featureChoices['ASI_A_$level'] = nameA;
    featureChoices['ASI_B_$level'] = nameB;
    String shorten(String s) => s.length > 3 ? s.substring(0, 3) : s;
    featureChoices['ASI_OR_FEAT_$level'] = '${shorten(nameA)} / ${shorten(nameB)}';
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
        // Multiclase (fase 2a): filtrado por _taskBelongsToLevelUpTarget — en esta
        // primera carga _levelUpTargetClassId todavía es null (el usuario no ha pasado
        // por "classPicker" todavía), así que el filtro no descarta nada aquí; se vuelve
        // a poblar correctamente por clase en selectLevelUpTargetClass()/selectClass()
        // vía _prePopulateFeatureChoicesForEdit().
        final tasks = (await _pendingTaskService.getPendingTasks(_editCharacterId!))
            .where(_taskBelongsToLevelUpTarget);
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
      // 1. Level-up if needed (one POST per level gained), enviando la tirada de HP
      // que el usuario hizo para ese nivel concreto en "Manage HP" (si la hizo).
      // Multiclase (Aurora_Fixes.md #17, fase 2a): en level-up, selectedLevel significa
      // "nivel en la clase elegida" (ver selectClass/selectLevelUpTargetClass), no nivel
      // de personaje — levelsGained se calcula contra _levelUpTargetStartLevel, no contra
      // _originalLevel (que sigue usándose tal cual para indexar _hpRolls, siempre por
      // nivel TOTAL de personaje). En edición pura (sin level-up) el cálculo no cambia.
      final levelsGained = (_levelUpMode && _levelUpTargetClassId != null)
          ? selectedLevel - _levelUpTargetStartLevel
          : selectedLevel - _originalLevel;
      final levelUpWarnings = <String>[];
      if (levelsGained > 0) {
        for (int i = 0; i < levelsGained; i++) {
          final newLevel = _originalLevel + i + 1;
          final result = await _charService.levelUp(
            _editCharacterId!,
            hpRoll: _hpRolls[newLevel],
            classId: _levelUpTargetClassId,
            subclassId: _levelUpTargetClassId != null ? selectedSubclass?.id : null,
          );
          levelUpWarnings.addAll(result.warnings);
        }
      }
      _lastLevelUpWarnings = levelUpWarnings;

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

      // 5. Sincronizar skills de clase: solo los índices que el usuario añadió/quitó
      // respecto al snapshot original (ver _prePopulateClassSkillsForEdit), no en modo nivel-up.
      if (!_levelUpMode) {
        await _syncClassSkillChanges();
      }

      // 6. Sincronizar Expertise: tanto en edición (cambios sobre lo ya elegido) como en
      // nivel-up (nueva Expertise ganada al nivel nuevo, p.ej. Rogue nivel 6) — Expertise
      // nunca pasa por PendingTask, así que sin esto no se guarda en ninguno de los dos modos.
      await _syncExpertiseChanges();

      _saveSuccess = true;
    } catch (e) {
      _setError('Error saving changes: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Sincroniza con el backend los índices de skill de clase que el usuario añadió o quitó
  /// en modo edición, comparando contra el snapshot tomado al cargar el wizard (bug #1 del backlog).
  /// Resuelve el índice a un ID de skill numérico vía _editCharSkills (requiere que el nombre
  /// coincida — las skills nuevas que el personaje no tenía aún no se pueden resolver así).
  Future<void> _syncClassSkillChanges() async {
    if (_editCharacterId == null) return;
    final added   = _classSkillIndices.difference(_originalClassSkillIndices);
    final removed = _originalClassSkillIndices.difference(_classSkillIndices);
    if (added.isEmpty && removed.isEmpty) return;

    Future<void> apply(String idx, bool proficient) async {
      final name = _skillIndexToDisplay(idx).toLowerCase();
      final skill = _editCharSkills.where((s) => s.skillName.toLowerCase() == name).firstOrNull;
      if (skill?.id == null) return; // skill no encontrada en el personaje — no se puede resolver el ID
      await _charService.setSkillProficiency(
        characterId: _editCharacterId!,
        skillId: skill!.id!,
        proficient: proficient,
      );
    }

    for (final idx in added)   { await apply(idx, true); }
    for (final idx in removed) { await apply(idx, false); }
  }

  /// Nombres de skill con Expertise según las claves EXPERTISE_PICK_* actualmente
  /// presentes en featureChoices (todas las que el wizard tiene cargadas — en modo
  /// edición incluye las ya existentes gracias a _prePopulateExpertiseForEdit; en modo
  /// nivel-up solo las del nivel nuevo, ya que classFeatureChoices filtra niveles viejos).
  Set<String> get _currentExpertiseSkillNames => featureChoices.entries
      .where((e) => e.key.contains('EXPERTISE_PICK'))
      .map((e) => e.value)
      .toSet();

  /// Sincroniza con el backend la Expertise que el usuario añadió o quitó, comparando
  /// contra el snapshot tomado al cargar el wizard (_originalExpertiseSkillNames, vacío
  /// en modo nivel-up ya que ahí solo importan los picks nuevos). Expertise se aplica
  /// directamente en la creación (igual que las class skills) y nunca pasa por una
  /// PendingTask, así que _autoResolveFeatureChoices() nunca la resuelve por su cuenta.
  Future<void> _syncExpertiseChanges() async {
    if (_editCharacterId == null) return;
    final current = _currentExpertiseSkillNames;
    final added   = current.difference(_originalExpertiseSkillNames);
    final removed = _originalExpertiseSkillNames.difference(current);
    if (added.isEmpty && removed.isEmpty) return;

    Future<void> apply(String skillName, bool expertise) async {
      final skill = _editCharSkills.where((s) => s.skillName.toLowerCase() == skillName.toLowerCase()).firstOrNull;
      if (skill?.id == null) return; // skill no encontrada en el personaje — no se puede resolver el ID
      await _charService.setSkillExpertise(
        characterId: _editCharacterId!,
        skillId: skill!.id!,
        expertise: expertise,
      );
    }

    for (final name in added)   { await apply(name, true); }
    for (final name in removed) { await apply(name, false); }
  }

  /// Devuelve la abreviatura de 3 letras (p.ej. 'STR') de un nombre completo
  /// de habilidad (p.ej. 'Strength'), tal como las guarda kAbilityScoreNames.
  String? _abilityAbbrev(String fullName) =>
      kAbilityScoreNames.where((a) => a.name == fullName).firstOrNull?.description;

  /// Construye el string de resolución que PendingTaskService.java espera para
  /// una tarea ASI_OR_FEAT ('ASI:STR:+2', 'ASI:STR:+1+DEX:+1' o 'FEAT:NombreDote'),
  /// a partir de las claves locales del wizard (ASI_A_n, ASI_B_n, FEAT_CHOICE_n).
  /// Antes se enviaba directamente el texto del badge ('Str / Con' o 'Feat'), que el
  /// backend no reconoce — el ASI/Feat elegido en el wizard nunca se aplicaba (bug #1).
  String? _resolveAsiOrFeatChoice(int level) {
    final feat = featureChoices['FEAT_CHOICE_$level'];
    if (feat != null) return 'FEAT:$feat';

    final asiA = featureChoices['ASI_A_$level'];
    final asiB = featureChoices['ASI_B_$level'];
    if (asiA == null || asiB == null) return null;
    final abbrevA = _abilityAbbrev(asiA);
    final abbrevB = _abilityAbbrev(asiB);
    if (abbrevA == null || abbrevB == null) return null;
    return asiA == asiB ? 'ASI:$abbrevA:+2' : 'ASI:$abbrevA:+1+$abbrevB:+1';
  }

  /// Algunas elecciones de subclase se modelan en el wizard como varios "slots"
  /// numerados (un WizardChoiceConfig por elemento elegido, p.ej.
  /// 'BATTLEMASTER_MANEUVER_1'..'_7'), pero el backend las espera como UNA sola
  /// PendingTask por nivel cuyo resolvedChoice es la lista completa separada por
  /// comas (ver PlayerCharacterService.createSubclassTask). Sin este mapeo, el
  /// taskType del backend nunca coincidía con ninguna clave del wizard y la
  /// elección no se aplicaba nunca (bug #1 del backlog, mismo patrón que ASI/Feat).
  static const Map<String, String> _slottedChoicePrefixByTaskType = {
    'MANEUVER_CHOICE': 'BATTLEMASTER_MANEUVER',
    'ELEMENTAL_DISCIPLINE': 'FOUR_ELEM_DISC',
    'TRICK_SHOT_CHOICE': 'TRICK_SHOT_CHOICE',
    'RUNE_CHOICE': 'RUNE_SLOT',
  };

  /// Recoge los valores de todos los slots `${prefix}_N_$level` (N = 1, 2, 3...)
  /// y los une en una sola cadena separada por comas, en el orden de los slots.
  String? _resolveSlottedChoice(String prefix, int level) {
    final re = RegExp('^${RegExp.escape(prefix)}_(\\d+)_$level\$');
    final entries = featureChoices.entries.where((e) => re.hasMatch(e.key)).toList()
      ..sort((a, b) => int.parse(re.firstMatch(a.key)!.group(1)!)
          .compareTo(int.parse(re.firstMatch(b.key)!.group(1)!)));
    final values = entries.map((e) => e.value).where((v) => v.isNotEmpty).toList();
    return values.isEmpty ? null : values.join(',');
  }

  /// Multiclase (Aurora_Fixes.md #17, fase 2a): una tarea pendiente "pertenece" a la clase
  /// que se está subiendo en esta sesión si no tiene clase asignada (personaje mono-clase,
  /// o tarea creada antes de esta fase) o si es exactamente esa clase. Sin esto, dos clases
  /// distintas que alcanzan el mismo taskType al mismo nivel-en-su-clase (p.ej. ambas su
  /// propio ASI de nivel 4) colisionarían en la misma clave `taskType_relatedLevel`.
  bool _taskBelongsToLevelUpTarget(PendingTask t) =>
      t.dndClassId == null || t.dndClassId == _levelUpTargetClassId;

  /// Carga las tareas pendientes del personaje recién creado y resuelve silenciosamente
  /// cualquier tarea cuya clave (taskType_relatedLevel) coincida con una elección recogida en el wizard.
  Future<void> _autoResolveFeatureChoices(int characterId) async {
    try {
      final tasks = (await _pendingTaskService.getPendingTasks(characterId))
          .where(_taskBelongsToLevelUpTarget);
      for (final task in tasks) {
        // Las tareas ya completadas no se pueden volver a resolver — el backend lo rechaza
        // con un error. En modo edición, featureChoices puede tener un valor no-nulo para
        // ellas (pre-rellenado solo para mostrarlas en el wizard, ver
        // _prePopulateFeatureChoicesForEdit), pero eso no significa que haya que reenviarlas.
        if (task.completed) continue;

        final key = '${task.taskType}_${task.relatedLevel}';

        String? choice;
        if (task.taskType == 'ASI_OR_FEAT') {
          choice = _resolveAsiOrFeatChoice(task.relatedLevel);
        } else if (_slottedChoicePrefixByTaskType.containsKey(task.taskType)) {
          choice = _resolveSlottedChoice(
              _slottedChoicePrefixByTaskType[task.taskType]!, task.relatedLevel);
        } else {
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

          choice = multiPicks.isNotEmpty
              ? multiPicks.join(',')
              : featureChoices[key];
        }

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
      case WizardStep.preferences:
        if (availableContentSources.isEmpty) loadContentSources();
        break;
      case WizardStep.dndClass:
        if (classes.isEmpty) loadClasses();
        break;
      case WizardStep.classPicker:
        // Necesario para poder ofrecer "Take a new class" con el catálogo completo.
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