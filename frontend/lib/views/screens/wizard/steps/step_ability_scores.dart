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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        Text('Ability Scores', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text(
          'Assign each value from the standard array [15,14,13,12,10,8] to an ability.',
          style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Valores disponibles (tachados si ya están usados)
        Text('Available values:',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: kStandardArray.map((val) {
            // Un valor está usado si aparece en algún assignment
            final isUsed = vm.standardArrayAssignments.values
                .any((idx) => idx != null && kStandardArray[idx] == val);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isUsed
                    ? AppTheme.surfaceVariant.withOpacity(0.4)
                    : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isUsed ? AppTheme.divider : AppTheme.primary,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text('$val',
                    style: GoogleFonts.cinzel(
                      color: isUsed ? AppTheme.textSecondary : AppTheme.primary,
                      fontSize: 16, fontWeight: FontWeight.bold,
                    )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Tabla de abilities
        ...kAbilityNames.map((ability) {
          final assignedIdx = vm.standardArrayAssignments[ability];

          final racialBonus = vm.racialBonuses[ability] ?? 0;
          final total = vm.finalScore(ability); // base + racial (o 10 si no asignado)
          final mod = vm.abilityModifier(ability);
          final modLabel = mod >= 0 ? '+$mod' : '$mod';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: assignedIdx != null
                    ? AppTheme.primary.withOpacity(0.5)
                    : AppTheme.surfaceVariant,
              ),
            ),
            child: Row(children: [
              // Ability name
              SizedBox(
                width: 44,
                child: Text(ability,
                    style: GoogleFonts.cinzel(
                        color: AppTheme.primary,
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),

              // Dropdown — elige qué índice del array asignar
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: assignedIdx,
                    dropdownColor: AppTheme.surface,
                    hint: Text('Choose',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('—',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                      ...List.generate(kStandardArray.length, (idx) {
                        final val = kStandardArray[idx];
                        // Disponible si no está asignado a OTRA ability
                        final takenByOther = vm.standardArrayAssignments.entries
                            .any((e) => e.key != ability && e.value == idx);
                        // Siempre usamos el idx real como value para evitar
                        // valores null duplicados que causan Assertion Failed.
                        // La deshabilitación visual la maneja `enabled`.
                        return DropdownMenuItem<int?>(
                          value: idx,
                          enabled: !takenByOther,
                          child: Text('$val',
                              style: GoogleFonts.lato(
                                color: takenByOther
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                                fontSize: 14,
                              )),
                        );
                      }),
                    ],
                    
                    onChanged: (idx) {
                      if (idx == null) {
                          vm.clearStandardArrayAssignment(ability);
                      } else {
                        vm.assignStandardArrayValue(ability, idx);
                      }
                    },
                  ),
                ),
              ),

              // Racial bonus badge
              if (racialBonus != 0) ...[
                const SizedBox(width: 8),
                Text('+$racialBonus',
                    style: GoogleFonts.lato(
                        color: AppTheme.primary,
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ],

              const SizedBox(width: 8),

              // Total + modifier
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  assignedIdx != null ? '$total' : '—',
                  style: GoogleFonts.cinzel(
                      color: assignedIdx != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  assignedIdx != null ? modLabel : '',
                  style: GoogleFonts.lato(
                      color: mod >= 0 ? AppTheme.primary : AppTheme.accent,
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ]),
            ]),
          );
        }),

        if (vm.allArrayValuesAssigned)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
              const SizedBox(width: 6),
              Text('All scores assigned!',
                  style: GoogleFonts.lato(
                      color: AppTheme.primary,
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ]),
          ),
      ]),
    );
  }
}