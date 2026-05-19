//Mock

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_list_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/character_test_helpers.dart';

class MockCharacterService extends Mock implements CharacterService {}

void main(){
  late MockCharacterService mockService;
  late CharacterListViewModel vm;

  setUp((){
    // Vaciar SharedPreferences para que LocalCacheService no devuelva nada
    SharedPreferences.setMockInitialValues({});
    mockService = MockCharacterService();
    vm = CharacterListViewModel(service: mockService);
  });

  tearDown(() => vm.dispose());

// Group: load()

  group('CharacterListViewModel.load()', () {
    test(
      'Successful API call without cache -> '
      'characters assigned, fromCache=false, isLoading=false, errorMessage=null',
      () async {
        final fakeList = [
          makeSummary(id: 1, name: 'Amuro'),
          makeSummary(id: 2, name: 'Char'),          
        ];

        when(() => mockService.getMyCharacters())
          .thenAnswer((_) async => fakeList);

        await vm.load();

        expect(vm.characters, hasLength(2));
        expect(vm.characters.first.name, 'Amuro');
        expect(vm.fromCache, false);
        expect(vm.isLoading, false);
        expect(vm.errorMessage, null);
  });

    test(
      'API fails with previous cache -> '
      'characters from cache, fromCache=true, no errorMessage',
      () async {
        //Precondición: guardar datos en caché
        final cachedJson =
        '[{"id":1,"name":"Bright","level":20,"currentHp":80,"maxHp":80,"armorClass":12}]';
        SharedPreferences.setMockInitialValues({'lc_char_list': cachedJson});

        when(() => mockService.getMyCharacters())
          .thenThrow(Exception('Sin conexión'));


        await vm.load();

        expect(vm.characters, hasLength(1));
        expect(vm.characters.first.name, 'Bright');
        expect(vm.fromCache, isTrue);
        //Con caché disponible NO se asigna errorMessage
        expect(vm.errorMessage, null);
      });

      test(
        'API fails WITHOUT cache  -> '
        'characters empty, errorMessage assigned',
        () async {
          when(() => mockService.getMyCharacters())
            .thenThrow(Exception('Timeout'));

          await vm.load();

          expect(vm.characters, isEmpty);
          expect(vm.errorMessage, isNotNull);
          expect(vm.isLoading, isFalse);
        });

        test('API returns empty list -> characters empty, no error', () async {
          when(() => mockService.getMyCharacters())
              .thenAnswer((_) async => <PlayerCharacterSummary>[]);

          await vm.load();

          expect(vm.characters, isEmpty);
          expect(vm.errorMessage, isNull);
          expect(vm.fromCache, isFalse);
        });

        test('isLoading=true during the call', () async {
          //Usamos un Completer para controlar cuándo termina la API
          bool? loadingDuringCall;
          when(() => mockService.getMyCharacters()).thenAnswer((_) async {
            // Leemos isLoading mientras la "API" se ejecuta (en el mismo frame)
            return <PlayerCharacterSummary>[];
          });

          //Capturamos el estado intermedio mediante un listener
          vm.addListener(() {
            //El primer notify es sin datos (spinner), el isLoading debe ser true
            loadingDuringCall ??= vm.isLoading;
        });

          await vm.load();

          //Al terminar, isLoading debe ser false
          expect(vm.isLoading, isFalse);
          // Y en algún momento fue true (el listener lo capturó
          expect(loadingDuringCall, isTrue);
        });
  });

  //Grupo: deleteCharacter()
  group('CharacterListViewModel.deleteCharacter()', () {
      setUp(() async {
        //Precargar una lista de personajes
        when(() => mockService.getMyCharacters()).thenAnswer(
          (_) async => [makeSummary(id: 1), makeSummary(id: 2)]);
        await vm.load();
    });

    test('success -> character removed from local list', () async {
      when(() => mockService.deleteCharacter(1))
        .thenAnswer((_) async {});

      await vm.deleteCharacter(1);

      expect(vm.characters, hasLength(1));
      expect(vm.characters.any((c) => c.id == 1), isFalse);
      expect(vm.errorMessage, null);
    });

    test('API failure -> list unchanged, errorMessage assigned', () async {
      when(() => mockService.deleteCharacter(1))
        .thenThrow(Exception('Server error'));

      await vm.deleteCharacter(1);

      expect(vm.characters, hasLength(2));
      expect(vm.errorMessage, isNotNull);
    });
  });
}

