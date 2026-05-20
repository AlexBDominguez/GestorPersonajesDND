// ============================================================================
// Tests de integración — Lista de personajes
// ============================================================================
//
// Capa mockeada: ApiClient (solo la red)
// Capa real:     CharacterService (parseo JSON) + CharacterListViewModel
//
// Diferencia respecto a los tests unitarios de CharacterListViewModel:
//   - Tests unitarios mockean CharacterService.getMyCharacters() devolviendo
//     objetos Dart ya construidos.
//   - Estos tests mockean ApiClient.get() devolviendo JSON en crudo,
//     por lo que CharacterService.fromJson() y PlayerCharacterSummary.fromJson()
//     se ejecutan de verdad, detectando errores de deserialización.
//
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_list_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}

// ── Datos de prueba ──────────────────────────────────────────────────────────

const _kListPath = '/api/characters';

// JSON que simula la respuesta real del endpoint GET /api/characters
const _kListJson =
    '[{"id":1,"name":"Thorin Escudo","level":5,'
    '"currentHp":38,"maxHp":40,"armorClass":16,"hasInspiration":false,'
    '"experiencePoints":6500,"raceName":"Enano","dndClassName":"Guerrero"},'
    '{"id":2,"name":"Gandalf el Gris","level":10,'
    '"currentHp":28,"maxHp":30,"armorClass":12,"hasInspiration":true,'
    '"experiencePoints":64000,"raceName":"Humano","dndClassName":"Mago"}]';

// ══════════════════════════════════════════════════════════════════════════════
void main() {
  late MockApiClient mockApi;
  late CharacterListViewModel vm;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApi = MockApiClient();
    // Servicio REAL con HTTP mockeado
    vm = CharacterListViewModel(service: CharacterService(apiClient: mockApi));
  });

  tearDown(() => vm.dispose());

  // ────────────────────────────────────────────────────────────────────────────
  group('CharacterListViewModel — integración HTTP → VM', () {

    // TEST 1: deserialización completa del JSON
    // Comprueba que PlayerCharacterSummary.fromJson() mapea correctamente
    // todos los campos que usa la UI (nombre, nivel, clase, raza...).
    test(
        'HTTP 200: JSON del backend → lista de personajes parseada correctamente',
        () async {
      when(() => mockApi.get(_kListPath))
          .thenAnswer((_) async => http.Response(_kListJson, 200));

      await vm.load();

      expect(vm.characters, hasLength(2));

      final thorin = vm.characters[0];
      expect(thorin.name,        'Thorin Escudo');
      expect(thorin.level,       5);
      expect(thorin.dndClassName,'Guerrero');
      expect(thorin.raceName,    'Enano');
      expect(thorin.currentHp,   38);
      expect(thorin.maxHp,       40);
      expect(thorin.armorClass,  16);

      final gandalf = vm.characters[1];
      expect(gandalf.name,       'Gandalf el Gris');
      expect(gandalf.level,      10);
      expect(gandalf.hasInspiration, isTrue);

      expect(vm.fromCache, isFalse);
      expect(vm.errorMessage, isNull);
    });

    // TEST 2: código HTTP de error → errorMessage incluye el código
    // CharacterService convierte códigos inesperados en mensajes legibles.
    // Valida que ese mensaje llega íntegro al VM (sin conversiones adicionales
    // que lo alteren).
    test(
        'HTTP 500 → errorMessage contiene el código de estado del servidor',
        () async {
      when(() => mockApi.get(_kListPath))
          .thenAnswer((_) async => http.Response('Internal Server Error', 500));

      await vm.load();

      expect(vm.characters, isEmpty);
      expect(vm.errorMessage, isNotNull);
      // CharacterService lanza Exception('Failed to load characters (500)')
      expect(vm.errorMessage, contains('500'));
      expect(vm.isLoading, isFalse);
    });

    // TEST 3: caché persistida entre cargas (LocalCacheService + SharedPreferences)
    // Primer load con API correcta → guarda en caché.
    // Segundo load (VM nuevo) con API caída → recupera datos del caché.
    // Prueba la integración completa de la capa de persistencia local.
    test(
        'HTTP 200 guarda en caché; segunda carga con API caída → datos desde caché',
        () async {
      // Primera carga: API disponible → datos guardados en SharedPreferences
      when(() => mockApi.get(_kListPath))
          .thenAnswer((_) async => http.Response(_kListJson, 200));
      await vm.load();

      expect(vm.characters, hasLength(2));
      expect(vm.fromCache, isFalse);

      // Segunda carga: API caída, misma SharedPreferences (misma sesión de test)
      when(() => mockApi.get(_kListPath))
          .thenThrow(Exception('Sin conexión'));

      final vm2 = CharacterListViewModel(
          service: CharacterService(apiClient: mockApi));
      await vm2.load();

      expect(vm2.characters, hasLength(2));
      expect(vm2.characters[0].name, 'Thorin Escudo');
      expect(vm2.characters[1].name, 'Gandalf el Gris');
      expect(vm2.fromCache, isTrue);
      // Con caché disponible NO se muestra error al usuario
      expect(vm2.errorMessage, isNull);

      vm2.dispose();
    });
  });
}
