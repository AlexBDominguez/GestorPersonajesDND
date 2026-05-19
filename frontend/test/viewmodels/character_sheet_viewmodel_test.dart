import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/services/characters/character_service.dart';
import 'package:gestor_personajes_dnd/services/spells/spell_service.dart';
import 'package:gestor_personajes_dnd/services/wizard/wizard_reference_service.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/character_test_helpers.dart';

class MockCharacterService extends Mock implements CharacterService {}
class MockSpellService extends Mock implements SpellService {}
class MockWizardReferenceService extends Mock implements WizardReferenceService {}

void main() {
  late MockCharacterService mockService;
  late MockSpellService mockSpellService;
  late MockWizardReferenceService mockRefService;
  late CharacterSheetViewModel vm;

  const int kCharId = 42;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockService = MockCharacterService();
    mockSpellService = MockSpellService();
    mockRefService = MockWizardReferenceService();

    vm = CharacterSheetViewModel(
      characterId: kCharId,
      service: mockService,
      spellService: mockSpellService,
      refService: mockRefService,
    );
  });

  tearDown(() => vm.dispose());


  //Grupo: load()

  group('CharacterSheetViewModel.load()', () {
    test(
      'Succesful Api without cache -> '
      'character assigned, fromCache=false, isLoading=false',
      () async {
        final char = makeCharacter(id: kCharId);

        when(() => mockService.getCharacterById(kCharId))
          .thenAnswer((_) async => char);

        await vm.load();

        expect(vm.character, isNotNull);
        expect(vm.character!.id, kCharId);
        expect(vm.fromCache, isFalse);
        expect(vm.isLoading, isFalse);
        expect(vm.errorMessage, isNull);
      });

      test(
        'API fails with previous cache -> '
        'character is not null, fromCache=true, no errorMessage',
        () async {
          //Guardar en caché JSON válido para el personaje kCharId
          final cachedJson = '{"id":$kCharId,"name":"Cached Hero","level":3,'
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

          SharedPreferences.setMockInitialValues({
            'lc_char_$kCharId': cachedJson,
            'lc_ts_char_$kCharId': DateTime.now().toIso8601String(),
          });

          when(() => mockService.getCharacterById(kCharId))
            .thenThrow(Exception('No connection'));

          await vm.load();

          //Con caché disponible, character no debe ser null
          expect(vm.character, isNotNull);
          expect(vm.character!.name, 'Cached Hero');
          expect(vm.fromCache, isTrue);
          expect(vm.isLoading, isFalse);
          //No hay errorMessage cuando hay caché
          expect(vm.errorMessage, isNull);
      });

      test(
        'API fails without cache -> '
        'character null, errorMessage assigned',
        () async {
          when(()=> mockService.getCharacterById(kCharId))
            .thenThrow(Exception('404 Not Found'));

          await vm.load();

          expect(vm.character, isNull);
          expect(vm.errorMessage, isNotNull);
          expect(vm.isLoading, isFalse);
        });
      });

      // Grupo: castSpell() - Optimistic UI

      group('CharacterSheetViewModel.castSpell()', () {
        setUp(() {
          //Persona sin clase (para no disparar carga de features)
          vm.character = makeCharacter(
            id: kCharId,
            spellSlots: [
              makeSpellSlot(spellLevel: 1, maxSlots: 3, usedSlots: 0),
            ],
          );
        });

        test(
          'optimistic - usedSlots incremented BEFORE the API responds',
          () async {
            final completer = Completer<void>();
            when(() => mockService.useSpellSlot(
              characterId: kCharId, level: 1))
              .thenAnswer((_) => completer.future);

          //Iniciamos el cast pero NO esperamos aún
          final future = vm.castSpell(1);

          //En este punto la API sigue pendiente pero el slot ya debe estar marcado
          expect(vm.usedSlots(1), equals(1),
            reason: 'usedSlots should increment optimistically');
          expect(vm.availableSlots(1), equals(2));

          //Completamos la llamada
          completer.complete();
          final result = await future;

          expect(result, isTrue);
          expect(vm.usedSlots(1), equals(1));
        });

        test(
          'reverts in case of API failure - usedSlots go back to original value',
          () async {
            when(() => mockService.useSpellSlot(
              characterId: kCharId, level: 1))
              .thenThrow(Exception('Server Error'));

            final result = await vm.castSpell(1);

            expect(result, isFalse);
            expect(vm.usedSlots(1), equals(0),
              reason: 'usedSlots should revert if API call fails');
          });
          test('Without enough slots -> returns false inmediately, no API call', () async{
            //Sobreescribir con 0 slots
            vm.character = makeCharacter(
              id: kCharId,
              spellSlots: [makeSpellSlot(spellLevel: 1, maxSlots: 0)],
            );

            final result = await vm.castSpell(1);

            expect(result, isFalse);
            verifyNever(() => mockService.useSpellSlot(
              characterId: any(named: 'characterId'),
              level: any(named: 'level')));
          });

          test('level 0 (cantrip) -> always returns true without consuming slots', () async{
            final result = await vm.castSpell(0);

            expect(result, isTrue);
            verifyNever(() => mockService.useSpellSlot(
              characterId: any(named: 'characterId'),
              level: any(named: 'level')));
          });

          test('multiple slots - does not confuse slots of different levels', () async {
            vm.character = makeCharacter(
              id: kCharId,
              spellSlots: [
                makeSpellSlot(spellLevel: 1, maxSlots: 4),
                makeSpellSlot(spellLevel: 2, maxSlots: 2),
              ],
            );

            when(() => mockService.useSpellSlot(
              characterId: kCharId, level: 2))
              .thenAnswer((_) async {});

            await vm.castSpell(2);

            //Solo el nivel 2 debe cambiar
            expect(vm.usedSlots(1), equals(0));
            expect(vm.usedSlots(2), equals(1));
          });
        });

  //Grupo: restoreSpellSlot() - Optimistic UI
  group('CharacterSheetViewModel.restoreSpellSlot()', () {
    setUp(() async {
      //Iniciamos con 1 slot ya usado
      vm.character = makeCharacter(
        id: kCharId,
        spellSlots: [
          makeSpellSlot(spellLevel: 1, maxSlots: 3, usedSlots: 0)],
      );
      //Usamos uno para tener estado inicial usedSlots=1
      final completer = Completer<void>();
      when(() => mockService.useSpellSlot(
        characterId: kCharId, level: 1))
        .thenAnswer((_) => completer.future);
      final castFuture = vm.castSpell(1);
      completer.complete();
      await castFuture;
    });

    test(
      'optimistic - usedSlots decremented BEFORE the API responds',
      () async {
        final completer = Completer<void>();
        when(() => mockService.restoreSpellSlot(
          characterId: kCharId, 
          level: 1))
          .thenAnswer((_) => completer.future);

        final future = vm.restoreSpellSlot(1);

        //Optimistic: ya decrementado.
        expect(vm.usedSlots(1), equals(0));

        completer.complete();
        final result = await future;

        expect(result, isTrue);
      });

      test('reverts in case of API failure', () async {
        when(() => mockService.restoreSpellSlot(
          characterId: kCharId, 
          level: 1))
          .thenThrow(Exception('Error'));

        expect(vm.usedSlots(1), equals(1));
        await vm.restoreSpellSlot(1);
        expect(vm.usedSlots(1), equals(1),
          reason: 'should revert to original value if API call fails');
      });

      test(
        'without any used slots -> returns false, doesnt call the API',
        () async {
          vm.character = makeCharacter(
            id: kCharId,
            spellSlots: [makeSpellSlot(spellLevel: 2, maxSlots: 2, usedSlots: 0)],
          );

          final result = await vm.restoreSpellSlot(2);

          expect(result, isFalse);
          verifyNever(() => mockService.restoreSpellSlot(
            characterId: any(named: 'characterId'),
            level: any(named: 'level')));
        });
  });

  //Grupo: togglePrepareSpell() - límite de hechizos preparados

  group('CharacterSheetViewModel.togglePrepareSpell() - limit', () {
    test(
      'at maximum -> doesnt call the API and assigns errorMessage',
      () async {
      // 1 hechizo preparado, maxPreparedSpells=1, intentamos preparar otro
      vm.character = makeCharacter(
        id: kCharId,
        dndClassName: 'Cleric', //clase que prepara hechizos
        maxPreparedSpells: 1,
        characterSpells: [
          makeSpell(id: 1, spellId: 10, prepared: true),
          makeSpell(id: 2, spellId: 20, prepared: false),
        ],
      );
      await vm.togglePrepareSpell(20);

      expect(vm.errorMessage, isNotNull);
      expect(
        vm.errorMessage,
        contains('Prepared spell limit reached'),
        reason: 'must indicate that the limit has been reached');
      verifyNever(() => mockService.togglePrepareSpell(
        characterId: any(named: 'characterId'),
        spellId: any(named: 'spellId')));      
    });

    test(
      'under the maximum -> calls the API without mistakes',
      () async {
        vm.character = makeCharacter(
          id: kCharId,
          dndClassName: 'Cleric',
          maxPreparedSpells: 5,
          characterSpells: [
            makeSpell(id: 1, spellId: 10, prepared: true),
            makeSpell(id: 2, spellId: 20, prepared: false),
          ],
        );

        //silentRefresh llamará getCharacterById
        when(() => mockService.getCharacterById(kCharId))
          .thenAnswer((_) async => vm.character!);
        when(() => mockService.togglePrepareSpell(
          characterId: kCharId,
          spellId: 20))
          .thenAnswer((_) async {});
          
        await vm.togglePrepareSpell(20);

        expect(vm.errorMessage, isNull);
        verify(() => mockService.togglePrepareSpell(characterId: kCharId, spellId: 20)).called(1);
      });

      test(
        'cantrip doesnt count for the limit -> calls the API',
        () async {
          vm.character = makeCharacter(
            id: kCharId,
            dndClassName: 'Cleric',
            maxPreparedSpells: 1,
            characterSpells: [
              makeSpell(id: 1, spellId: 10, prepared: true),            // límite lleno
              makeSpell(id: 2, spellId: 99, prepared: false, level: 0), // cantrip
            ],
          );

          when(() => mockService.getCharacterById(kCharId))
            .thenAnswer((_) async => vm.character!);
          when(() => mockService.togglePrepareSpell(
            characterId: kCharId, spellId: 99))
            .thenAnswer((_) async {});

          await vm.togglePrepareSpell(99);

          //Cantrips no aplican límite -> sin error
          expect(vm.errorMessage, isNull);
          verify(() => mockService.togglePrepareSpell(
            characterId: kCharId, spellId: 99)).called(1);
        });

        test(
          'class alwaysPrepared (Bard) -> never applies limit',
          () async {
            vm.character = makeCharacter(
              id: kCharId,
              dndClassName: 'Bard',
              maxPreparedSpells: 1,
              characterSpells: [
                makeSpell(id: 1, spellId: 10, prepared: true),
                makeSpell(id: 2, spellId: 20, prepared: false),
              ],
            );

            when(() => mockService.getCharacterById(kCharId))
              .thenAnswer((_) async => vm.character!);
            when(() => mockService.togglePrepareSpell(
              characterId: kCharId, spellId: 20))
              .thenAnswer((_) async {});

            await vm.togglePrepareSpell(20);

            expect(vm.errorMessage, isNull);
            verify(() => mockService.togglePrepareSpell(
              characterId: kCharId, spellId: 20)).called(1);
          });      
  });


  //Grupo: featureMaxuses() - calculo puro (sin mocks)

  group('CharacterSheetViewModel.featureMaxUses()', () {
    ClassFeature makeFeature(String indexName) => ClassFeature(
      id: 0,
      name:indexName,
      indexName: indexName,
      description: '',
      level: 1,
    );

    test('feature desconocida → 0', () {
      vm.character = makeCharacter(level: 5);
      expect(vm.featureMaxUses(makeFeature('fly')), 0);
    });

    test('second-wind → siempre 1', () {
      vm.character = makeCharacter(level: 10);
      expect(vm.featureMaxUses(makeFeature('second-wind')), 1);
    });

    test('bardic-inspiration → CHA modifier (CHA=16 → mod=3)', () {
      vm.character = makeCharacter(
        level: 5,
        abilityScores: {'STR': 10, 'DEX': 10, 'CON': 10, 'INT': 10, 'WIS': 10, 'CHA': 16},
      );
      expect(vm.featureMaxUses(makeFeature('bardic-inspiration')), 3);
    });

    test('bardic-inspiration-d8 (variante) → CHA modifier', () {
      vm.character = makeCharacter(
        level: 5,
        abilityScores: {'STR': 10, 'DEX': 10, 'CON': 10, 'INT': 10, 'WIS': 10, 'CHA': 16},
      );
      // cubre el prefijo 'bardic-inspiration-*'
      expect(vm.featureMaxUses(makeFeature('bardic-inspiration-d8')), 3);
    });

    test('ki → igual al nivel del personaje', () {
      vm.character = makeCharacter(level: 7);
      expect(vm.featureMaxUses(makeFeature('ki')), 7);
    });

    test('lay-on-hands → nivel × 5', () {
      vm.character = makeCharacter(level: 4);
      expect(vm.featureMaxUses(makeFeature('lay-on-hands')), 20);
    });

    group('rage (Barbarian) — tabla PHB', () {
      test('nivel 1 → 2 rages', () {
        vm.character = makeCharacter(level: 1);
        expect(vm.featureMaxUses(makeFeature('rage')), 2);
      });
      test('nivel 3 → 3 rages', () {
        vm.character = makeCharacter(level: 3);
        expect(vm.featureMaxUses(makeFeature('rage')), 3);
      });
      test('nivel 6 → 4 rages', () {
        vm.character = makeCharacter(level: 6);
        expect(vm.featureMaxUses(makeFeature('rage')), 4);
      });
      test('nivel 12 → 5 rages', () {
        vm.character = makeCharacter(level: 12);
        expect(vm.featureMaxUses(makeFeature('rage')), 5);
      });
      test('nivel 17 → 6 rages', () {
        vm.character = makeCharacter(level: 17);
        expect(vm.featureMaxUses(makeFeature('rage')), 6);
      });
      test('nivel 20 → 6 rages (máximo)', () {
        vm.character = makeCharacter(level: 20);
        expect(vm.featureMaxUses(makeFeature('rage')), 6);
      });
    });

    group('superiority-dice (Battle Master) — tabla PHB', () {
      test('nivel 3 → 4 dados', () {
        vm.character = makeCharacter(level: 3);
        expect(vm.featureMaxUses(makeFeature('superiority-dice')), 4);
      });
      test('nivel 7 → 5 dados', () {
        vm.character = makeCharacter(level: 7);
        expect(vm.featureMaxUses(makeFeature('superiority-dice')), 5);
      });
      test('nivel 15 → 6 dados', () {
        vm.character = makeCharacter(level: 15);
        expect(vm.featureMaxUses(makeFeature('superiority-dice')), 6);
      });
    });
  });
  group('CharacterSheetViewModel feature tracking', () {
    late ClassFeature secondWind;

    setUp(() {
      vm.character = makeCharacter(level: 5);
      secondWind = ClassFeature(
          id: 0, name: 'Second Wind', indexName: 'second-wind',
          description: '', level: 1);
    });

    test('useFeature → decrece usesRemaining', () {
      expect(vm.featureUsesRemaining(secondWind), 1); // max=1
      vm.useFeature(secondWind);
      expect(vm.featureUsesRemaining(secondWind), 0);
    });

    test('useFeature en 0 → no baja de 0', () {
      vm.useFeature(secondWind);
      vm.useFeature(secondWind); // segundo intento cuando ya está en 0
      expect(vm.featureUsesRemaining(secondWind), 0);
    });

    test('restoreFeature → sube usesRemaining', () {
      vm.useFeature(secondWind);
      vm.restoreFeature(secondWind);
      expect(vm.featureUsesRemaining(secondWind), 1);
    });

    test('restoreFeature en max → no supera max', () {
      vm.restoreFeature(secondWind); // ya estaba en max
      expect(vm.featureUsesRemaining(secondWind), 1);
    });

    test('useFeatureN(2) sobre ki nivel 5 → remaining = 3', () {
      final ki = ClassFeature(
          id: 0, name: 'Ki', indexName: 'ki',
          description: '', level: 1);
      vm.character = makeCharacter(level: 5);
      vm.useFeatureN(ki, 2);
      expect(vm.featureUsesRemaining(ki), 3); // 5 - 2
    });
  });
}