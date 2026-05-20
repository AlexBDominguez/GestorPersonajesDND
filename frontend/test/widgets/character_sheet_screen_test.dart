// ============================================================================
// Widget tests para CharacterSheetScreen
// ============================================================================
//
// ¿QUÉ son los tests de widget?
// ---------------------------------
// Los tests unitarios comprueban la LÓGICA del ViewModel en aislamiento
// (sin UI). Los tests de widget comprueban que la INTERFAZ de usuario
// reacciona correctamente a los cambios de estado del ViewModel.
//
// Herramienta principal: WidgetTester (parámetro `tester` de cada test)
//   - tester.pumpWidget(...)  → construye el árbol de widgets en un entorno
//                               de test (pantalla virtual sin GPU real)
//   - tester.pump()           → procesa fotogramas y microtasks pendientes
//                               (provoca rebuilds si hubo notifyListeners())
//   - tester.pumpAndSettle()  → repite pump() hasta que no haya más cambios
//                               (útil para animaciones)
//
// Buscadores (Finders):
//   - find.byType(Widget)       → busca por tipo de widget
//   - find.text('texto')        → busca un Text con ese contenido exacto
//   - find.textContaining('x')  → busca un Text que contenga 'x'
//
// Matchers:
//   - findsOneWidget   → exactamente 1
//   - findsNothing     → ninguno
//   - findsWidgets     → 1 o más
//
// Patrón general de cada test:
//   1. Configurar estado del VM (sin llamar a load())
//   2. pumpWidget → primer render con ese estado
//   3. pump()     → procesa cualquier microtask generada por el primer build
//   4. expect(...)
//
// ¿Por qué NO llamamos a vm.load() en la mayoría de tests?
//   Porque load() hace peticiones HTTP. En los tests controlamos
//   el estado del VM directamente (vm.character = makeCharacter(...)) y
//   así nos ahorramos mockear todos los servicios.
//
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/inventory/inventory_service.dart';
import 'package:gestor_personajes_dnd/services/spells/spell_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/character_sheet_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/character_test_helpers.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
// mocktail genera implementaciones falsas de las interfaces en tiempo de
// compilación. Sólo necesitamos declarar la clase y heredar de Mock.

class MockCharacterService extends Mock implements CharacterService {}
class MockSpellService extends Mock implements SpellService {}
class MockWizardReferenceService extends Mock implements WizardReferenceService {}
class MockInventoryService extends Mock implements InventoryService {}

// ── JSON de caché reutilizable ─────────────────────────────────────────────────
// Mismo formato que usa la API, que es el que LocalCacheService almacena y
// PlayerCharacter.fromJson() sabe parsear.
const String _kCachedCharJson =
    '{"id":1,"name":"Cached Hero","level":3,'
    '"currentHp":20,"maxHp":20,"temporaryHp":0,"proficiencyBonus":2,'
    '"armorClass":12,"initiativeModifier":0,"currentSpeed":30,'
    '"deathSaveSuccesses":0,"deathSaveFailures":0,"hasInspiration":false,'
    '"dying":false,"stable":false,"dead":false,"conscious":true,'
    '"experiencePoints":0,"experienceToNextLevel":900,"availableHitDice":3,'
    '"passivePerception":10,"passiveInvestigation":10,"passiveInsight":10,'
    '"meleeAttackBonus":2,"rangedAttackBonus":2,"finesseAttackBonus":2,'
    '"spellSaveDC":10,"spellAttackBonus":2,"maxPreparedSpells":0,'
    '"copperPieces":0,"silverPieces":0,"electrumPieces":0,'
    '"goldPieces":0,"platinumPieces":0,'
    '"abilityScores":{"STR":10,"DEX":10,"CON":10,"INT":10,"WIS":10,"CHA":10},'
    '"spellSlots":[],"skills":[],"savingThrows":[],"characterSpells":[]}';

// ══════════════════════════════════════════════════════════════════════════════
void main() {
  // Deshabilitar descarga de fuentes en tests (GoogleFonts las usaría en red)
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockCharacterService mockService;
  late MockSpellService mockSpellService;
  late MockWizardReferenceService mockRefService;
  late MockInventoryService mockInventoryService;
  late CharacterSheetViewModel vm;

  setUp(() {
    // Cada test parte con SharedPreferences vacío (sin caché)
    SharedPreferences.setMockInitialValues({});

    mockService = MockCharacterService();
    mockSpellService = MockSpellService();
    mockRefService = MockWizardReferenceService();
    mockInventoryService = MockInventoryService();

    // Stub por defecto: el inventario devuelve lista vacía
    when(() => mockInventoryService.getInventory(any()))
        .thenAnswer((_) async => []);

    // VM con todos los servicios inyectados (ninguno hace HTTP real)
    vm = CharacterSheetViewModel(
      characterId: 1,
      service: mockService,
      spellService: mockSpellService,
      refService: mockRefService,
      inventoryService: mockInventoryService,
    );
  });

  tearDown(() {
    // Liberamos el VM al acabar el test (igual que haría el Provider)
    vm.dispose();
  });

  // Helper: monta CharacterSheetScreen inyectando nuestro VM de test.
  // Al usar testVm, el screen usa ChangeNotifierProvider.value (que NO
  // dispone el VM al desmontar), dejando al test el control del ciclo de vida.
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterSheetScreen(characterId: 1, testVm: vm),
      ),
    );
  }

  // ── Grupo 1: Estado de carga ─────────────────────────────────────────────────
  group('Estado de carga', () {
    // CONCEPTO: usamos un Completer para "congelar" una llamada async.
    // unawaited(vm.load()) arranca load() pero no espera su resolución.
    // Dart ejecuta load() de forma síncrona hasta el primer await (la lectura
    // de SharedPreferences), y ahí se suspende. Al llegar al await del API,
    // queda bloqueado por el Completer → isLoading sigue siendo true.
    testWidgets(
        'muestra CircularProgressIndicator mientras carga sin personaje previo',
        (tester) async {
      final apiCompleter = Completer<PlayerCharacter>();
      when(() => mockService.getCharacterById(1))
          .thenAnswer((_) => apiCompleter.future);

      // Arranca load() SIN esperarlo → VM queda en isLoading=true, character=null
      unawaited(vm.load());

      // pumpWidget construye el árbol y procesa microtasks pendientes
      // (incluyendo el read de SharedPreferences, que resuelve rápido).
      // Después el VM queda esperando el API → spinner visible.
      await pumpScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);

      // Limpieza: resolución del completer para no dejar futures colgados
      apiCompleter.completeError(Exception('cleanup'));
    });
  });

  // ── Grupo 2: Estado de error ──────────────────────────────────────────────────
  group('Estado de error', () {
    // CONCEPTO: la condición del screen es `vm.error != null || vm.character == null`.
    // Un VM recién creado tiene character=null e isLoading=false → muestra error.
    testWidgets(
        'muestra "Character not found" y botón Retry con VM vacío (sin caché, sin load())',
        (tester) async {
      // Estado inicial del VM: isLoading=false, character=null, errorMessage=null
      // El screen evalúa `character == null` → rama error
      await pumpScreen(tester);
      await tester.pump();

      expect(find.text('Character not found'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets(
        'muestra el mensaje de error devuelto por la API cuando no hay caché',
        (tester) async {
      // Aquí sí llamamos a load() y lo esperamos para capturar el estado final
      when(() => mockService.getCharacterById(1))
          .thenThrow(Exception('No connection'));

      // await load() completa: character sigue null, errorMessage asignado
      await vm.load();

      await pumpScreen(tester);
      await tester.pump();

      // La pantalla muestra vm.error (no el texto genérico)
      expect(find.text('Character not found'), findsNothing);
      expect(find.textContaining('No connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  // ── Grupo 3: Personaje cargado ────────────────────────────────────────────────
  group('Personaje cargado', () {
    // CONCEPTO: asignamos vm.character ANTES de llamar a pumpWidget.
    // Cuando _SheetBody.build() ejecuta `context.watch<CharacterSheetViewModel>()`
    // lee el estado ACTUAL del VM → character ya está presente → renderiza la ficha.
    // No necesitamos notifyListeners() porque el primer build ya ve el dato.
    testWidgets('muestra el nombre del personaje en la barra de navegación',
        (tester) async {
      vm.character = makeCharacter(id: 1, name: 'Gandalf');

      await pumpScreen(tester);
      await tester.pump();

      // _NavBar renderiza character.name en un widget Text
      expect(find.text('Gandalf'), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('muestra el TabBar con las pestañas base cuando hay personaje',
        (tester) async {
      vm.character = makeCharacter(id: 1);

      await pumpScreen(tester);
      await tester.pump();

      expect(find.byType(TabBar), findsOneWidget);
      // makeCharacter sin spellSlots → no aparece la pestaña Spells
      expect(find.text('Abilities'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('Spells'), findsNothing);
    });
  });

  // ── Grupo 4: Banner de caché ──────────────────────────────────────────────────
  group('Banner de caché (CachedDataBanner)', () {
    // CONCEPTO: aquí sí usamos load() porque la única forma de poner fromCache=true
    // es a través del mecanismo de caché del VM.
    // Patrón: seeding de SharedPreferences + API que falla → VM usa el caché.
    testWidgets('CachedDataBanner es visible cuando fromCache=true', (tester) async {
      // Sembrar SharedPreferences con datos cacheados válidos
      SharedPreferences.setMockInitialValues({
        'lc_char_1': _kCachedCharJson,
        'lc_ts_char_1': DateTime.now().toIso8601String(),
      });

      // La API falla → load() no actualiza character desde la red → fromCache=true
      when(() => mockService.getCharacterById(1))
          .thenThrow(Exception('Sin conexión'));

      await vm.load(); // carga desde caché (fromCache=true), API falla silenciosamente

      await pumpScreen(tester);
      await tester.pump();

      // El widget CachedDataBanner debe estar en el árbol
      expect(find.byType(CachedDataBanner), findsOneWidget);
      expect(find.textContaining('Datos en caché'), findsOneWidget);
    });

    testWidgets('CachedDataBanner NO aparece cuando character viene de la API',
        (tester) async {
      // Asignamos character directamente (fromCache=false por defecto)
      vm.character = makeCharacter(id: 1, name: 'Live Hero');

      await pumpScreen(tester);
      await tester.pump();

      expect(find.byType(CachedDataBanner), findsNothing);
    });
  });

  // ── Grupo 5: Banner de agonía ─────────────────────────────────────────────────
  group('DyingBanner', () {
    // La condición en el screen: `if (c.currentHp <= 0 || c.isDying)`
    testWidgets('DyingBanner es visible cuando currentHp es 0', (tester) async {
      vm.character = makeCharacter(id: 1, currentHp: 0, maxHp: 40);

      await pumpScreen(tester);
      await tester.pump();

      // El DyingBanner muestra 'DYING' cuando isStable=false
      expect(find.textContaining('DYING'), findsOneWidget);
    });

    testWidgets('DyingBanner NO aparece cuando currentHp > 0', (tester) async {
      vm.character = makeCharacter(id: 1, currentHp: 20, maxHp: 40);

      await pumpScreen(tester);
      await tester.pump();

      expect(find.textContaining('DYING'), findsNothing);
      expect(find.text('STABLE'), findsNothing);
    });
  });
}
