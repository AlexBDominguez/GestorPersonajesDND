import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/combat_features.dart';
import 'package:gestor_personajes_dnd/services/storage/local_cache_service.dart';
import 'package:gestor_personajes_dnd/models/character/pending_task.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/racial_trait.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/feat_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/characters/pending_task_service.dart';
import 'package:gestor_personajes_dnd/services/feats/feat_service.dart';
import 'package:gestor_personajes_dnd/services/inventory/inventory_service.dart';
import 'package:gestor_personajes_dnd/services/spells/spell_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';

// Consumable features: indexName -> max uses (o código especial negativo)
// Keys deben coincidir con los index_name reales de la DB.
// -1 = CHA mod, -2 = nivel*5, -3 = nivel, -4 = tabla Barbarian
const _kConsumableFeatures = <String, int>{
  // Barbarian
  'rage':                    -4,
  // Bard — las variantes (d6/d8/d10/d12) se resuelven por prefijo
  'bardic-inspiration':      -1,
  // Cleric — variantes por usos/descanso
  'channel-divinity-1-rest': 1,
  'channel-divinity-2-rest': 2,
  'channel-divinity-3-rest': 3,
  // Druid — variantes de CR se resuelven por prefijo
  'wild-shape':              2,
  // Fighter
  'action-surge-1-use':      1,
  'action-surge-2-uses':     2,
  'second-wind':             1,
  // Monk — el recurso principal se llama 'ki' en la DB (no 'ki-points')
  'ki':                      -3,
  // Paladin
  'channel-divinity':        1,
  'lay-on-hands':            -2,
  'divine-sense':            -5,   // 1 + CHA mod
  // Sorcerer
  'sorcery-points':          -3,   // = level (igual que ki)
  // Wizard
  'arcane-recovery':         1,
  // Fighter (Battle Master subclass)
  'combat-superiority':      -6,   // superiority dice table
  'superiority-dice':        -6,
};

// Prefijos que se resuelven por coincidencia parcial (indexName.startsWith(prefix + '-'))
const _kConsumableFeaturePrefixes = <String>{
  'bardic-inspiration', // cubre d6/d8/d10/d12
  'wild-shape',         // cubre todas las variantes de CR
};

// Familias de features "escalonadas": la API pública de D&D 5e representa cada
// mejora de nivel como un indexName propio (channel-divinity-1-rest, -2-rest,
// -3-rest...) en vez de una sola feature que escala. Sin filtrar, un Clérigo
// nivel 6+ acumula TODAS las variantes ya desbloqueadas a la vez como tarjetas
// separadas, cada una con su propio contador — duplicando (o triplicando)
// los usos reales disponibles. Cada lista va de nivel más bajo a más alto;
// nos quedamos solo con la variante más alta que el personaje ya desbloqueó.
const _kTieredFeatureFamilies = <List<String>>[
  ['channel-divinity-1-rest', 'channel-divinity-2-rest', 'channel-divinity-3-rest'],
  ['action-surge-1-use', 'action-surge-2-uses'],
  ['indomitable-1-use', 'indomitable-2-uses', 'indomitable-3-uses'],
];

List<ClassFeature> _dedupeTieredFeatures(List<ClassFeature> features) {
  final present = features.map((f) => f.indexName.toLowerCase()).toSet();
  final toRemove = <String>{};
  for (final family in _kTieredFeatureFamilies) {
    final highest = family.lastWhere(present.contains, orElse: () => '');
    if (highest.isEmpty) continue;
    toRemove.addAll(family.where((k) => k != highest));
  }
  if (toRemove.isEmpty) return features;
  return features.where((f) => !toRemove.contains(f.indexName.toLowerCase())).toList();
}

// Channel Divinity: cada Dominio/Juramento añade una opción propia
// (Preserve Life, Turn Undead, Sacred Weapon...) que gasta del MISMO fondo
// de usos que la feature base "Channel Divinity" — no es un recurso aparte.
// Resuelve a qué indexName de fondo apunta cada opción según clase/nivel del
// personaje, para que todas compartan el mismo contador en vez de que cada
// opción lleve su propio contador independiente (lo que permitiría "usar"
// Preserve Life y Turn Undead cada uno por separado sin límite compartido).
const _kChannelDivinityBaseKeys = <String>{
  'channel-divinity-1-rest',
  'channel-divinity-2-rest',
  'channel-divinity-3-rest',
  'channel-divinity', // Paladin
};

class CharacterSheetViewModel extends ChangeNotifier {
  // Varios métodos de carga (_loadSubclassFeaturesIfNeeded, _loadClassFeaturesIfNeeded, etc.)
  // se disparan sin esperar (`fire-and-forget`) desde loadCharacter() y pueden resolver después
  // de que la pantalla se haya cerrado y el ViewModel se haya dispose()ado, provocando
  // "used after being disposed". Se ignora silenciosamente en vez de propagar el error.
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  final CharacterService _service;
  final int characterId;
  final SpellService _spellService;
  final WizardReferenceService _refService;
  final PendingTaskService _taskService = PendingTaskService();
  final InventoryService _inventoryService;
  final FeatService _featService;
  List<PendingTask> _pendingTasks = [];
  /// Solo las tareas incompletas — las completadas se muestran en otra pestaña (Features).
  /// También filtra las tareas gestionadas fuera del flujo de pending tasks:
  ///   • LEARN_SPELLS / PREPARE_SPELLS – los spells iniciales se añaden directamente en el wizard
  ///   • CHOOSE_SUBCLASS – la subclase se asignó en el wizard
  List<PendingTask> get pendingTasks => _pendingTasks.where((t) {
    if (t.completed) return false;
    if (t.taskType == 'LEARN_SPELLS' || t.taskType == 'PREPARE_SPELLS') return false;
    if (t.taskType == 'CHOOSE_SUBCLASS' && character?.subclassId != null) return false;
    return true;
  }).toList();
  bool get hasPendingTasks => _pendingTasks.any((t) {
    if (t.completed) return false;
    if (t.taskType == 'LEARN_SPELLS' || t.taskType == 'PREPARE_SPELLS') return false;
    if (t.taskType == 'CHOOSE_SUBCLASS' && character?.subclassId != null) return false;
    return true;
  });

  CharacterSheetViewModel({
    required this.characterId,
    CharacterService? service,
    SpellService? spellService,
    WizardReferenceService? refService,
    InventoryService? inventoryService,
    FeatService? featService,
  })  : _service = service ?? CharacterService(),
        _spellService = spellService ?? SpellService(),
        _refService = refService ?? WizardReferenceService(),
        _inventoryService = inventoryService ?? InventoryService(),
        _featService = featService ?? FeatService();

  // ── State 
  PlayerCharacter? character;
  bool _isLoading = false;
  bool _fromCache = false;

  // ── Offhand weapon ──────────────────────────────────────────────────────────
  /// ID del InventoryItem designado como arma secundaria (off-hand). Nulo si no hay.
  int? _offhandWeaponId;

  /// El arma equipada actualmente designada como off-hand, o null si no hay ninguna.
  InventoryItem? get offhandWeapon => _inventoryItems
      .where((i) =>
          i.equipped &&
          i.id == _offhandWeaponId &&
          i.damageDice != null &&
          i.damageDice!.isNotEmpty)
      .firstOrNull;

  /// True si el personaje eligió el fighting style "Two-Weapon Fighting".
  /// Antes comprobaba una ClassFeature con indexName 'two-weapon-fighting' que nunca
  /// existe — Fighting Style es una elección (PendingTask), no una feature de clase —
  /// así que esto nunca era true (bug #15 del backlog). Ahora lee el campo real.
  bool get hasTwoWeaponFighting =>
      character?.fightingStyle?.toLowerCase() == 'two-weapon fighting';

  /// True si el personaje eligió el fighting style "Dueling" (+2 al daño cuerpo a
  /// cuerpo cuando empuña un arma a una mano y ninguna otra arma).
  bool get hasDueling =>
      character?.fightingStyle?.toLowerCase() == 'dueling';

  /// True si el personaje tiene el feat "Dual Wielder".
  bool get hasDualWielderFeat => _characterFeats
      .any((f) => f.name.toLowerCase().contains('dual wielder'));

  /// Devuelve true si el item puede usarse como arma secundaria.
  /// Requisito: ser arma (tener damageDice) + propiedad Light O tener el feat Dual Wielder.
  bool canWeaponBeOffhand(InventoryItem item) {
    if (item.damageDice == null || item.damageDice!.isEmpty) return false;
    if (hasDualWielderFeat) return true;
    return item.weaponProperties.any((p) => p.toLowerCase() == 'light');
  }

  /// Designa o quita la designación de arma off-hand.
  void setOffhandWeapon(int? inventoryId) {
    _offhandWeaponId = inventoryId;
    notifyListeners();
  }

  // ── Feats ───────────────────────────────────────────────────────────────────
  List<CharacterFeat> _characterFeats = [];
  List<CharacterFeat> get characterFeats => _characterFeats;

  Future<void> _loadFeats() async {
    try {
      _characterFeats = await _featService.getCharacterFeats(characterId);
      notifyListeners();
    } catch (_) {
      // silencioso
    }
  }
  DateTime? _cacheTimestamp;
  bool get fromCache => _fromCache;
  DateTime? get cacheTimestamp => _cacheTimestamp;
  // Caché local de la última moneda guardada. Se usa en _CurrencyRow.initState()
  // para leer valores frescos sin necesidad de recargar el personaje.
  // No llama a notifyListeners() para evitar rebuilds innecesarios.
  Map<String, int>? _lastSavedCurrency;
  Map<String, int>? get lastSavedCurrency => _lastSavedCurrency;
  void cacheCurrency(Map<String, int> values) {
    _lastSavedCurrency = Map.unmodifiable(values);
  }
  String? _errorMessage;
  int _tabIndex = 0;
  List<RacialTrait> _racialTraits = [];
  List<RacialTrait> get racialTraits => _racialTraits;
  List<InventoryItem> _inventoryItems = [];
  List<InventoryItem> get equippedWeapons => _inventoryItems
      .where((i) => i.equipped &&
          i.damageDice != null &&
          i.damageDice!.isNotEmpty)
      .toList();

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
    notifyListeners(); // spinner inmediato

    // ── 1. Mostrar caché local mientras llega la API ──────────────────────
    final cachedChar = await LocalCacheService.loadCharacter(characterId);
    if (cachedChar != null) {
      final cachedInv = await LocalCacheService.loadInventory(characterId);
      character       = cachedChar;
      _inventoryItems = cachedInv ?? [];
      _fromCache      = true;
      _cacheTimestamp = await LocalCacheService.characterSavedAt(characterId);
      _initSpellSlots();
      notifyListeners(); // muestra datos en caché con banner
    }

    // ── 2. Fetch desde API ────────────────────────────────────────────────
    try {
      character = await _service.getCharacterById(characterId);
      _fromCache = false;
      _cacheTimestamp = null;
      await _loadPendingTasks();
      _initSpellSlots();
      _loadInventory();
      if (character?.dndClassId != null && _classFeatures.isEmpty) {
        _loadClassFeaturesIfNeeded();
      }
      if (character?.subclassId != null && _subclassFeatures.isEmpty) {
        _loadSubclassFeaturesIfNeeded();
      }
      if (character?.raceId != null && _racialTraits.isEmpty){
        _loadRacialTraits();
      }
      if (_characterFeats.isEmpty) {
        _loadFeats();
      }
    } catch (e) {
      if (character == null) {
        // Sin caché disponible: mostrar error
        _errorMessage = e.toString().replaceFirst('Exception', '');
      }
      // Si hay caché, _fromCache sigue en true y se muestra el banner
    } finally {
        _isLoading = false;
        _lastSavedCurrency = null; // el personaje recargado ya tiene datos frescos
        notifyListeners();
      }
  }

  /// Recarga el personaje silenciosamente (sin spinner de carga).
  /// Usar tras cualquier mutación para refrescar datos sin interrumpir la UI.
  /// Lanza personaje e inventario en paralelo y notifica UNA sola vez al
  /// terminar, evitando rebuilds dobles en la capa de UI.
  Future<void> silentRefresh() async {
    try {
      final charFuture = _service.getCharacterById(characterId);
      final invFuture  = _inventoryService.getInventory(characterId);
      character        = await charFuture;
      _inventoryItems  = await invFuture;
      _optimisticSpells = null; // server data is now authoritative
      _initSpellSlots();
      notifyListeners(); // única notificación
    } catch (_) {
      // Ignorar errores en refresco silencioso
    }
  }

  // ── Estado optimista del spell preparado ────────────────────────────────────────────
  // No nulo mientras una llamada a togglePrepareSpell está en vuelo; limpiado por silentRefresh.
  List<CharacterSpell>? _optimisticSpells;

  /// La lista de spells autoritativa para la UI: usa la sobreescritura optimista mientras
  /// la llamada a la API está en vuelo y luego vuelve a los datos del modelo.
  List<CharacterSpell> get currentSpells =>
      _optimisticSpells ?? character?.characterSpells ?? [];

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
    final spell = currentSpells.where((s) => s.spellId == spellId).firstOrNull;
    // Validar el límite de preparación antes de aplicar la actualización optimista
    if (spell != null && !spell.prepared && !spell.isCantrip && !alwaysPreparedClass) {
      final preparedCount = currentSpells.where((s) => s.prepared && !s.isCantrip).length;
      final max = character!.maxPreparedSpells;
      if (max > 0 && preparedCount >= max) {
        _errorMessage = 'Prepared spell limit reached ($preparedCount/$max). Unprepare a spell first.';
        notifyListeners();
        return;
      }
    }
    // Actualización optimista: cambiar el flag prepared inmediatamente
    final newPrepared = !(spell?.prepared ?? false);
    _optimisticSpells = currentSpells
        .map((s) => s.spellId == spellId ? s.copyWith(prepared: newPrepared) : s)
        .toList();
    notifyListeners();
    try {
      await _service.togglePrepareSpell(characterId: characterId, spellId: spellId);
      await silentRefresh(); // limpia _optimisticSpells y sincroniza el estado del servidor
    } catch (e) {
      _optimisticSpells = null; // revertir a datos del modelo (fallo de llamada API, servidor sin cambios)
      _errorMessage = e.toString().replaceFirst('Exception', '');
      notifyListeners();
    }
  }

  Future<void> removeSpell(int spellId) async {
    try {
      await _service.removeSpell(characterId: characterId, spellId: spellId);
      await silentRefresh();
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
      await _spellService.learnSpell(
        characterId: characterId,
        spellId: spellId,
        prepared: alwaysPreparedClass,
      );
      await silentRefresh();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
      notifyListeners();
    }
  }

  Future<void> recordDeathSave({required bool success}) async {
    try {
      final updated = await _service.recordDeathSave(characterId, success: success);
      character = updated;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception', '');
      notifyListeners();
    }
  }

  Future<void> resetDeathSaves() async {
    try {
      final updated = await _service.resetDeathSaves(characterId);
      character = updated;
      notifyListeners();
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

  // ── Long Rest / Short Rest ─────────────────────────────────────────────────

  Future<void> longRest() async {
    final updated = await _service.longRest(characterId);
    character = updated;
    _initSpellSlots();
    notifyListeners();
  }

  Future<void> shortRest({required int hitDiceToSpend, required int hitDiceRoll}) async {
    final updated = await _service.shortRest(characterId,
        hitDiceToSpend: hitDiceToSpend, hitDiceRoll: hitDiceRoll);
    character = updated;
    notifyListeners();
  }

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
      _classFeatures = _dedupeTieredFeatures(
          all.where((f) => f.level <= charLevel).toList())
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
      _subclassFeatures = _dedupeTieredFeatures(
          all.where((f) => f.level <= charLevel).toList())
        ..sort((a, b) => a.level.compareTo(b.level));
    } catch (_) {
      // silencioso
    } finally {
      _isLoadingSubclassFeatures = false;
      notifyListeners();
    }
  }

  /// Carga las subclases disponibles para la clase del personaje (usado por el
  /// resolvedor de tareas pendientes CHOOSE_SUBCLASS).
  Future<List<SubclassOption>> loadSubclassOptions() async {
    final classId = character?.dndClassId;
    if (classId == null) return [];
    return _refService.getSubclasses(classId);
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

  Future<void> _loadInventory() async {
    try {
      _inventoryItems = await _inventoryService.getInventory(characterId);
      // Si el arma off-hand designada ya no está equipada, quitarla.
      if (_offhandWeaponId != null && offhandWeapon == null) {
        _offhandWeaponId = null;
      }
      notifyListeners();
    } catch (_) {}
  }

  // ── Consumable feature tracking
  final Map<String, int> _featureUsesRemaining = {};

  /// Si esta feature es una opción de Channel Divinity (Preserve Life, Turn
  /// Undead, Sacred Weapon...), devuelve el indexName del fondo compartido de
  /// usos que le corresponde según la clase/nivel del personaje. Null si la
  /// feature no es una opción de Channel Divinity (incluye las propias claves
  /// base, que no se redirigen a sí mismas).
  String? _sharedResourcePoolKey(String indexNameLower) {
    if (!indexNameLower.startsWith('channel-divinity-') ||
        _kChannelDivinityBaseKeys.contains(indexNameLower)) {
      return null;
    }
    final className = character?.dndClassName?.toLowerCase() ?? '';
    final lvl = character?.level ?? 1;
    if (className.startsWith('paladin')) {
      return lvl >= 3 ? 'channel-divinity' : null;
    }
    // Por defecto asumimos Clérigo (cubre también subclases con el mismo prefijo).
    if (lvl >= 18) return 'channel-divinity-3-rest';
    if (lvl >= 6)  return 'channel-divinity-2-rest';
    if (lvl >= 2)  return 'channel-divinity-1-rest';
    return null;
  }

  /// Clave real a usar para lookup/almacenamiento de usos: el propio indexName,
  /// o el fondo compartido si esta feature redirige a uno (ver arriba).
  String _resourceKey(ClassFeature f) {
    final key = f.indexName.toLowerCase();
    return _sharedResourcePoolKey(key) ?? key;
  }

  int featureMaxUses(ClassFeature f) {
    final key = _resourceKey(f);
    // 1. Coincidencia exacta
    int? raw = _kConsumableFeatures[key];
    // 2. Coincidencia por prefijo para variantes (bardic-inspiration-d6, wild-shape-cr-*, …)
    if (raw == null) {
      for (final prefix in _kConsumableFeaturePrefixes) {
        if (key.startsWith('$prefix-')) {
          raw = _kConsumableFeatures[prefix];
          break;
        }
      }
    }
    if (raw == null) return 0;
    final lvl = character?.level ?? 1;
    if (raw == -1) return ((character?.abilityScores['cha'] ?? character?.abilityScores['CHA'] ?? 10) - 10) ~/ 2;
    if (raw == -2) return lvl * 5;
    if (raw == -3) return lvl;
    if (raw == -4) {          // Barbarian rages (PHB table)
      if (lvl >= 17) return 6;
      if (lvl >= 12) return 5;
      if (lvl >= 6)  return 4;
      if (lvl >= 3)  return 3;
      return 2;
    }
    if (raw == -5) {          // 1 + CHA mod (Divine Sense, etc.)
      final chaMod = ((character?.abilityScores['cha'] ??
          character?.abilityScores['CHA'] ?? 10) - 10) ~/ 2;
      return (1 + chaMod).clamp(1, 99);
    }
    if (raw == -6) {          // Battle Master superiority dice
      if (lvl >= 15) return 6;
      if (lvl >= 7)  return 5;
      return 4;
    }
    return raw;
  }

  int featureUsesRemaining(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return 0;
    return _featureUsesRemaining[_resourceKey(f)] ?? max;
  }

  bool isConsumableFeature(ClassFeature f) => featureMaxUses(f) > 0;

  /// Devuelve true si esta feature usa una UI de pool (contador + botón Usar)
  /// en lugar de círculos individuales.
  bool isPoolResource(ClassFeature f) {
    final key = f.indexName.toLowerCase();
    if (_sharedResourcePoolKey(key) != null) return true; // opción de Channel Divinity
    return key == 'rage'                   ||
           key == 'ki'                     ||
           key == 'lay-on-hands'           ||
           key == 'divine-sense'           ||
           key == 'sorcery-points'         ||
           key == 'arcane-recovery'        ||
           key == 'channel-divinity'       ||
           key == 'channel-divinity-1-rest'||
           key == 'channel-divinity-2-rest'||
           key == 'channel-divinity-3-rest'||
           key == 'combat-superiority'     ||
           key == 'superiority-dice'       ||
           key.startsWith('bardic-inspiration');
  }

  void useFeature(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return;
    final current = featureUsesRemaining(f);
    if (current <= 0) return;
    _featureUsesRemaining[_resourceKey(f)] = current - 1;
    notifyListeners();
  }

  void restoreFeature(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return;
    final current = featureUsesRemaining(f);
    if (current >= max) return;
    _featureUsesRemaining[_resourceKey(f)] = current + 1;
    notifyListeners();
  }

  void useFeatureN(ClassFeature f, int n) {
    final max = featureMaxUses(f);
    if (max <= 0 || n <= 0) return;
    final current = featureUsesRemaining(f);
    _featureUsesRemaining[_resourceKey(f)] = (current - n).clamp(0, max);
    notifyListeners();
  }

  void restoreFeatureToFull(ClassFeature f) {
    final max = featureMaxUses(f);
    if (max <= 0) return;
    _featureUsesRemaining[_resourceKey(f)] = max;
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

  /// Devuelve el valor de elección resuelto (de las tareas completadas) para un
  /// tipo de tarea y nivel dados, o null si aún no se ha resuelto.
  String? resolvedChoiceFor(String taskType, int level) {
    for (final task in _pendingTasks) {
      if (task.taskType == taskType && task.relatedLevel == level && task.completed) {
        return task.resolvedChoice;
      }
    }
    return null;
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
      await silentRefresh();
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
    final sub = character?.subclassName?.toLowerCase() ?? '';
    // Lanzadores basados en subclase (los lanzadores 1/3 usan INT)
    if (sub.contains('eldritch knight') || sub.contains('arcane trickster')) return 'INT';
    if (cls.contains('wizard')) return 'INT';
    if (cls.contains('cleric') || cls.contains('druid') ||
        cls.contains('ranger') || cls.contains('monk')) return 'WIS';
    if (cls.contains('bard') || cls.contains('paladin') ||
        cls.contains('sorcerer') || cls.contains('warlock')) return 'CHA';
    return 'INT';
  }

  bool get alwaysPreparedClass {
    final cls = character?.dndClassName?.toLowerCase() ?? '';
    final sub = character?.subclassName?.toLowerCase() ?? '';
    // Eldritch Knight y Arcane Trickster son lanzadores basados en subclase:
    // NO preparan spells (conocen una lista fija)
    if (sub.contains('eldritch knight') || sub.contains('arcane trickster')) return true;
    return cls.contains('bard') || cls.contains('sorcerer') ||
        cls.contains('warlock') || cls.contains('ranger');
  }
}