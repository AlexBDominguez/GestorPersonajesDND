import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/character/player_character.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'character_creator_screen.dart';

/// Entry point for editing an existing character.
///
/// Creates [CharacterCreatorViewModel] in edit mode pre-filled with the
/// character's data, kicks off loading, and delegates UI to [CharacterWizardBody].
class EditCharacterScreen extends StatelessWidget {
  final PlayerCharacter character;

  const EditCharacterScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = CharacterCreatorViewModel.forEdit(character);
        // Load reference lists and auto-select existing class/background/race
        vm.loadEditData();
        return vm;
      },
      child: const CharacterWizardBody(),
    );
  }
}
