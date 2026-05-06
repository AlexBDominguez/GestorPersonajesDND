import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/viewmodels/wizard/character_creator_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StepPreferences extends StatelessWidget{
  const StepPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text('Character Basics',
        style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text('Give your character a name and set some preferences.',
          style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 28),

          //- Nombre
          TextFormField(
          initialValue: vm.characterName,
          decoration: const InputDecoration(
            labelText: 'Character name *',
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.primary),
          ),
          style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 16),
          onChanged: vm.setName,
        ),
        const SizedBox(height: 28),

          // [DISABLED] Progression system (XP vs Milestone) — omitido by design.
          // Siempre se usa Milestone. Para reactivar, descomentar este bloque.
          /*
          Text('Progression system', ...),
          _OptionTile(title: 'Milestone', ...),
          _OptionTile(title: 'Experience Points (XP)', ...),
          const SizedBox(height: 28),
          */

          // [DISABLED] Encumbrance — omitido by design.
          // Para reactivar, descomentar este bloque y restaurar _OptionTile.
          /*
          Text('Optional rules', ...),
          SwitchListTile(value: vm.useEncumbrance, onChanged: vm.setEncumbrance),
          */
      ]),
    );
  }
}

