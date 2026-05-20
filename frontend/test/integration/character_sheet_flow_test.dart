// ============================================================================
// Tests de integración — Ficha de personaje
// ============================================================================
//
// ¿Qué diferencia a estos tests de los unitarios y de widget?
//
//  Nivel       │ Qué se mockea             │ Qué es real
//  ────────────┼───────────────────────────┼──────────────────────────────
//  Unitario    │ CharacterService (todo)   │ CharacterSheetViewModel solo
//  Widget      │ CharacterService (todo)   │ VM + CharacterSheetScreen
//  Integración │ ApiClient (solo la red)   │ CharacterService (parseo JSON)
//              │                           │ + InventoryService + VM + Screen
//
// Al mockear en ApiClient en lugar de en CharacterService, los tests de
// integración validan también que:
//   1. El JSON real del backend se deserializa correctamente en los modelos.
//   2. CharacterService transforma los códigos HTTP en excepciones correctas.
//   3. Todo ese resultado llega bien al VM y a la UI.
//
// Capa: MockApiClient → CharacterService → InventoryService
//     → CharacterSheetViewModel → CharacterSheetScreen
//
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';
import 'package:gestor_personajes_dnd/services/inventory/inventory_service.dart';
import 'package:gestor_personajes_dnd/services/spells/spell_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/character_sheet_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mockeamos ApiClient (la red), el resto de la cadena es REAL.
class MockApiClient extends Mock implements ApiClient {}

// ── Datos de prueba ──────────────────────────────────────────────────────────

const _kCharId = 1;
// Paths exactos que usan los servicios (ApiConfig.charactersPath = '/api/characters')
const _kCharPath = '/api/characters/$_kCharId';
const _kInvPath  = '/api/characters/$_kCharId/inventory';

// JSON que simula la respuesta real del backend para un guerrero nivel 5
const _kWarriorJson =
    '{"id":1,"name":"Thorin Escudo","level":5,'
    '"currentHp":38,"maxHp":40,"temporaryHp":0,"proficiencyBonus":3,'
    '"armorClass":16,"initiativeModifier":1,"currentSpeed":25,'
    '"deathSaveSuccesses":0,"deathSaveFailures":0,"hasInspiration":false,'
    '"dying":false,"stable":false,"dead":false,"conscious":true,'
    '"experiencePoints":6500,"experienceToNextLevel":14000,"availableHitDice":5,'
    '"passivePerception":12,"passiveInvestigation":10,"passiveInsight":12,'
    '"meleeAttackBonus":5,"rangedAttackBonus":3,"finesseAttackBonus":5,'
    '"spellSaveDC":10,"spellAttackBonus":0,"maxPreparedSpells":0,'
    '"copperPieces":10,"silverPieces":5,"electrumPieces":0,'
    '"goldPieces":50,"platinumPieces":2,'
    '"abilityScores":{"STR":18,"DEX":12,"CON":14,"INT":10,"WIS":12,"CHA":8},'
    '"spellSlots":[],"skills":[],"savingThrows":[],"characterSpells":[]}';

// JSON con spellSlots para un mago nivel 5 — lo que dispara la pestaña Spells
const _kMageJson =
    '{"id":1,"name":"Gandalf el Gris","level":5,'
    '"currentHp":28,"maxHp":30,"temporaryHp":0,"proficiencyBonus":3,'
    '"armorClass":12,"initiativeModifier":2,"currentSpeed":30,'
    '"deathSaveSuccesses":0,"deathSaveFailures":0,"hasInspiration":false,'
    '"dying":false,"stable":false,"dead":false,"conscious":true,'
    '"experiencePoints":6500,"experienceToNextLevel":14000,"availableHitDice":5,'
    '"passivePerception":14,"passiveInvestigation":16,"passiveInsight":14,'
    '"meleeAttackBonus":2,"rangedAttackBonus":2,"finesseAttackBonus":2,'
    '"spellSaveDC":14,"spellAttackBonus":6,"maxPreparedSpells":8,'
    '"copperPieces":0,"silverPieces":0,"electrumPieces":0,'
    '"goldPieces":100,"platinumPieces":0,'
    '"abilityScores":{"STR":8,"DEX":14,"CON":12,"INT":18,"WIS":14,"CHA":10},'
    '"spellSlots":['
      '{"spellLevel":1,"maxSlots":4,"usedSlots":0},'
      '{"spellLevel":2,"maxSlots":3,"usedSlots":0},'
      '{"spellLevel":3,"maxSlots":2,"usedSlots":0}'
    '],'
    '"skills":[],"savingThrows":[],"characterSpells":[]}';

// Helpers para construir respuestas HTTP sin verbosidad
http.Response _ok(String body)  => http.Response(body, 200);
http.Response _noContent()      => http.Response('', 204);
http.Response _notFound()       => http.Response('', 404);

// ══════════════════════════════════════════════════════════════════════════════
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late MockApiClient mockApi;
  late CharacterSheetViewModel vm;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApi = MockApiClient();

    // Stub del inventario: siempre vacío (no es lo que se está probando aquí)
    when(() => mockApi.get(_kInvPath)).thenAnswer((_) async => _ok('[]'));

    // Servicios REALES que usan el ApiClient mockeado
    vm = CharacterSheetViewModel(
      characterId: _kCharId,
      service:          CharacterService(apiClient: mockApi),
      inventoryService: InventoryService(apiClient: mockApi),
      spellService:     SpellService(apiClient: mockApi),
      refService:       WizardReferenceService(apiClient: mockApi),
    );
  });

  tearDown(() => vm.dispose());

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterSheetScreen(characterId: _kCharId, testVm: vm),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  group('CharacterSheetScreen — integración HTTP → UI', () {

    // TEST 1: flujo nominal completo
    // Valida que el JSON del backend se parsea correctamente y llega a la UI.
    // Los tests unitarios y de widget nunca comprueban que el campo "name" del
    // JSON se mapee bien al modelo — aquí sí se comprueba.
    testWidgets(
        'HTTP 200: JSON del backend → nombre del personaje visible en pantalla',
        (tester) async {
      when(() => mockApi.get(_kCharPath)).thenAnswer((_) async => _ok(_kWarriorJson));

      await vm.load(); // CharacterService parsea el JSON real

      await pumpScreen(tester);
      await tester.pump();

      // El nombre viene del JSON, pasa por PlayerCharacter.fromJson()
      // y llega al widget _NavBar que lo renderiza como Text
      expect(find.text('Thorin Escudo'), findsWidgets);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // TEST 2: personaje con hechizos → pestaña Spells
    // El campo "spellSlots" en el JSON activa la pestaña dinámica.
    // Esto prueba la integración entre SpellSlot.fromJson(), el estado del VM
    // (_showSpells) y el TabController de _SheetBodyState.
    testWidgets(
        'JSON con spellSlots → pestaña Spells aparece en el TabBar',
        (tester) async {
      when(() => mockApi.get(_kCharPath)).thenAnswer((_) async => _ok(_kMageJson));

      await vm.load(); // character.spellSlots tiene 3 entradas

      await pumpScreen(tester);
      // notifyListeners() dispara _onVmChanged en _SheetBodyState,
      // que hace setState({ _showSpells = true }) y actualiza el TabController
      vm.notifyListeners();
      await tester.pump(); // procesa el setState

      expect(find.text('Spells'), findsOneWidget);
      expect(find.text('Gandalf el Gris'), findsWidgets);
    });

    // TEST 3: error HTTP → mensaje de CharacterService en pantalla
    // Valida que CharacterService convierte el código 404 en la excepción
    // correcta ('Character not found'), que el VM la captura como errorMessage
    // y que la UI la muestra. Ningún test previo cubría esta cadena completa.
    testWidgets(
        'HTTP 404 → CharacterService lanza excepción, pantalla muestra el mensaje',
        (tester) async {
      when(() => mockApi.get(_kCharPath)).thenAnswer((_) async => _notFound());

      await vm.load();

      await pumpScreen(tester);
      await tester.pump();

      // CharacterService convierte 404 → Exception('Character not found')
      // El VM asigna errorMessage y la pantalla lo muestra.
      // Nota: el VM hace replaceFirst('Exception', '') → ': Character not found'
      expect(find.textContaining('Character not found'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(TabBar), findsNothing);
    });

    // TEST 4: cast spell — pipeline real desde HTTP hasta estado del VM
    // Verifica que el flujo completo funciona:
    //   InventoryService parsea la lista de slots del JSON de carga →
    //   VM registra los slots → vm.castSpell() llama a CharacterService.useSpellSlot()
    //   → CharacterService llama a ApiClient.post() → 204 → slot marcado como usado.
    testWidgets(
        'castSpell(): HTTP 204 en el endpoint de slot → VM registra el slot como usado',
        (tester) async {
      when(() => mockApi.get(_kCharPath)).thenAnswer((_) async => _ok(_kMageJson));
      // Stub para POST /api/characters/1/spell-slots/1/use → 204 No Content
      when(() => mockApi.post(any())).thenAnswer((_) async => _noContent());

      await vm.load();

      // Antes de castear: nivel 1 tiene 4 slots, ninguno usado
      expect(vm.usedSlots(1), equals(0));
      expect(vm.availableSlots(1), equals(4));

      // castSpell usa CharacterService.useSpellSlot() que llama a MockApiClient
      final success = await vm.castSpell(1);

      expect(success, isTrue);
      // El slot de nivel 1 ahora tiene 1 uso — parseo JSON + VM + servicio intactos
      expect(vm.usedSlots(1), equals(1));
      expect(vm.availableSlots(1), equals(3));
      // Los slots de otros niveles no se alteran
      expect(vm.usedSlots(2), equals(0));
    });
  });
}
