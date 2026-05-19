
//Crea un PlayerCharacter de prueba
//Solo hay que sobreescribir los campos relevantes para cada test.
import 'package:gestor_personajes_dnd/models/character/character_saving_throw.dart';
import 'package:gestor_personajes_dnd/models/character/character_skill.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/models/character/spell_slot.dart';

PlayerCharacter makeCharacter({
  int id = 1,
  String name = 'Test Hero',
  int level = 5,
  int? dndClassId,
  String? dndClassName, //null -> no carga features, no es spellcaster conocido
  int? subclassId,
  String? subclassName,
  int? raceId,
  int maxHp = 40,
  int currentHp = 40,
  int temporaryHp = 0,
  int maxPreparedSpells = 5,
  List<SpellSlot> spellSlots = const [],
  List<CharacterSpell> characterSpells = const [],
  Map<String, int>? abilityScores,
}) {
  return PlayerCharacter(
    id: id,
    name: name,
    level: level,
    dndClassId: dndClassId,
    dndClassName: dndClassName,
    subclassId: subclassId,
    subclassName: subclassName,
    raceId: raceId,
    abilityScores: abilityScores ?? {
      'STR': 10,
      'DEX': 10,
      'CON': 10,
      'INT': 10,
      'WIS': 10,
      'CHA': 10,
    },
    maxHp: maxHp,
    currentHp: currentHp,
    temporaryHp: temporaryHp,
    proficiencyBonus: 3,
    armorClass: 14,
    initiativeModifier: 0,
    currentSpeed: 30,
    deathSaveSuccesses: 0,
    deathSaveFailures: 0,
    hasInspiration: false,
    isDying: false,
    isStable: false,
    isDead: false,
    isConscious: true,
    experiencePoints: 0,
    experienceToNextLevel: 6500,
    availableHitDice: level,
    passivePerception: 12,
    passiveInvestigation: 10,
    passiveInsight: 12,
    meleeAttackBonus: 3,
    rangedAttackBonus: 3,
    finesseAttackBonus: 3,
    spellSaveDC: 14,
    spellAttackBonus: 6,
    maxPreparedSpells: maxPreparedSpells,
    copperPieces: 0,
    silverPieces: 0,
    electrumPieces: 0,
    goldPieces: 0,
    platinumPieces: 0,
    spellSlots: spellSlots,
    characterSpells: characterSpells,
    skills: const <CharacterSkill>[],
    savingThrows: const <CharacterSavingThrow>[],    
  );
}

// Crea un SpellSlot de prueba
SpellSlot makeSpellSlot({
  required int spellLevel,
  required int maxSlots,
  int usedSlots = 0,
}) =>
    SpellSlot(spellLevel: spellLevel, maxSlots: maxSlots, usedSlots: usedSlots);

// Crea un CharacterSpell de prueba
// Usa level = 0 para cantrips (isCantrip es un getter derivado de level == 0).
CharacterSpell makeSpell({
  int id = 1,
  required int spellId,
  int level = 1,
  bool prepared = false,
  bool learned = true,
  String name = 'Test Spell',
}) =>
    CharacterSpell(
      id: id,
      spellId: spellId,
      name: name,
      level: level,
      prepared: prepared,
      learned: learned,
    );

// Crea un [PlayerCharacterSummary] de prueba.
PlayerCharacterSummary makeSummary({
  int id = 1,
  String name = 'Test Hero',
  int level = 3,
  String? raceName = 'Human',
  String? dndClassName = 'Fighter',
}) =>
    PlayerCharacterSummary(
      id: id,
      name: name,
      level: level,
      raceName: raceName,
      dndClassName: dndClassName,
      currentHp: 25,
      maxHp: 30,
      armorClass: 16,
    );