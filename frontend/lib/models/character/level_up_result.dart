import 'package:gestor_personajes_dnd/models/character/player_character.dart';

// Multiclase (Aurora_Fixes.md #17, fase 2a): respuesta de POST /level-up desde que dejó de
// ser un string plano — mensaje + avisos no bloqueantes (prerrequisitos/proficiencies de
// multiclase) + el personaje ya actualizado, para no necesitar un GET aparte.
class LevelUpResult {
  final String message;
  final List<String> warnings;
  final PlayerCharacter character;

  const LevelUpResult({
    required this.message,
    required this.warnings,
    required this.character,
  });

  factory LevelUpResult.fromJson(Map<String, dynamic> j) => LevelUpResult(
    message:  j['message'] as String? ?? '',
    warnings: (j['warnings'] as List<dynamic>? ?? []).cast<String>(),
    character: PlayerCharacter.fromJson(j['character'] as Map<String, dynamic>),
  );
}
