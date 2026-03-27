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

          //- Progression
          Text('Progression system',
            style: GoogleFonts.cinzel(
              color: AppTheme.textPrimary,
              fontSize: 14, fontWeight: FontWeight.bold
            )),
          const SizedBox(height: 10),
          _OptionTile(
            title: 'Milestone',
            subtitle: 'Level up when the DM decides it.',
            icon: Icons.flag_outlined,
            selected: vm.useMilestone,
            onTap: () => vm.setMilestone(true),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            title: 'Experience Points (XP)',
            subtitle: 'Track XP and level up automatically.',
            icon: Icons.star_border,
            selected: !vm.useMilestone,
            onTap: () => vm.setMilestone(false),
          ),
          const SizedBox(height: 28),

          //- Encumbrance
          Text('Optional rules',
            style: GoogleFonts.cinzel(
              color: AppTheme.textPrimary,
              fontSize: 14, fontWeight: FontWeight.bold
            )),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceVariant),
            ),
            child: SwitchListTile(
              value: vm.useEncumbrance,
              onChanged: vm.setEncumbrance,
              activeThumbColor: AppTheme.primary,
              title: Text('Encumbrance',
                style: GoogleFonts.lato(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.bold
                )),
              subtitle: Text('Track carry weight based on STR.',
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 12
                )),
              secondary: const Icon(Icons.inventory_2_outlined,
                color: AppTheme.primary),
            ),
          ),
      ]),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title, required this.subtitle, required this.icon,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Icon(icon,
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
            size: 22),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.lato(
                color: selected ? AppTheme.primary : AppTheme.textPrimary,
                fontWeight: FontWeight.bold, fontSize: 14
              )),
              Text(subtitle, style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 12
              )),
            ])),
            if (selected)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
        ]),
      ),
    );
  }
}

