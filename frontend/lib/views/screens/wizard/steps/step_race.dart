import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';

class StepRace extends StatelessWidget {
  const StepRace({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (vm.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppTheme.accent, size: 48),
          const SizedBox(height: 12),
          Text(vm.error!, style: GoogleFonts.lato(color: AppTheme.accent)),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text('Choose your Race',
              style: Theme.of(context).textTheme.displayMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text('Your race determines your innate abilities and traits.',
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.races.length,
            itemBuilder: (_, i) {
              final race = vm.races[i];
              final isSelected = vm.selectedRace?.id == race.id;
              return GestureDetector(
                onTap: () => vm.selectRace(race),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.15)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      // Icon / check
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.surfaceVariant,
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.shield_outlined,
                          color: isSelected ? AppTheme.background : AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(race.name,
                              style: GoogleFonts.cinzel(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(children: [
                            _Tag('Speed ${race.speed}ft'),
                            const SizedBox(width: 6),
                            _Tag(race.size),
                          ]),
                          if (race.abilityBonuses.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(race.bonusText,
                                style: GoogleFonts.lato(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                          if (race.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(race.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(
                                    color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ]),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}