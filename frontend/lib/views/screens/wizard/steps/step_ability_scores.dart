import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';

class StepAbilityScores extends StatelessWidget {
  const StepAbilityScores({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assign Ability Scores',
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Assign each value from the standard array to an ability.\nStandard array: 15, 14, 13, 12, 10, 8',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Available pool
          Wrap(
            spacing: 8,
            children: CharacterCreatorViewModel.standardArray.map((v) {
              final used = !vm.availableScores.contains(v) ||
                  vm.availableScores.where((s) => s == v).length <
                      CharacterCreatorViewModel.standardArray
                          .where((s) => s == v)
                          .length;
              return Chip(
                label: Text('$v',
                    style: GoogleFonts.cinzel(
                        color: used
                            ? AppTheme.textSecondary
                            : AppTheme.background,
                        fontWeight: FontWeight.bold)),
                backgroundColor:
                    used ? AppTheme.surfaceVariant : AppTheme.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Assignment rows
          ...CharacterCreatorViewModel.abilityNames.map((ability) {
            final current = vm.abilityAssignments[ability];
            final options = [
              null,
              ...vm.availableScores,
              if (current != null) current,
            ]..sort((a, b) {
                if (a == null) return -1;
                if (b == null) return 1;
                return b.compareTo(a);
              });
            // Remove duplicates while preserving order
            final unique = options.toSet().toList()
              ..sort((a, b) {
                if (a == null) return -1;
                if (b == null) return 1;
                return b.compareTo(a);
              });

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                // Ability label
                SizedBox(
                  width: 50,
                  child: Text(ability,
                      style: GoogleFonts.cinzel(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                // Modifier display
                SizedBox(
                  width: 36,
                  child: Text(
                    current != null
                        ? vm.modifierLabel(current)
                        : '—',
                    style: GoogleFonts.cinzel(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                // Dropdown
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: current,
                    dropdownColor: AppTheme.surface,
                    style: GoogleFonts.lato(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppTheme.surfaceVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppTheme.primary, width: 2),
                      ),
                    ),
                    hint: Text('Select',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary)),
                    items: unique.map((v) {
                      return DropdownMenuItem<int?>(
                        value: v,
                        child: Text(v?.toString() ?? '— Unassign',
                            style: GoogleFonts.lato(
                                color: v == null
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (v) => vm.assignScore(ability, v),
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}