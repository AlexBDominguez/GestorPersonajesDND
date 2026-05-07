import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/character/player_character.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'character_creator_screen.dart';

/// Entry point for leveling up an existing character.
///
/// Creates [CharacterCreatorViewModel] in level-up mode pre-filled with the
/// character's data and next level, then delegates UI to [CharacterWizardBody].
class LevelUpScreen extends StatelessWidget {
  final PlayerCharacter character;

  const LevelUpScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = CharacterCreatorViewModel.forLevelUp(character);
        vm.loadLevelUpData();
        return vm;
      },
      child: const CharacterWizardBody(),
    );
  }
}
