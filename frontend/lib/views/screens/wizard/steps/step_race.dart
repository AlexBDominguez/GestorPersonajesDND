import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../models/wizard/race_option.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';

class StepRace extends StatelessWidget {
  const StepRace({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Character Name ─────────────────────────────────────
          Text('Character Name',
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: vm.characterName,
            decoration: const InputDecoration(
              hintText: 'Enter your character\'s name',
              prefixIcon:
                  Icon(Icons.edit_outlined, color: AppTheme.textSecondary),
            ),
            onChanged: (v) {
              vm.characterName = v;
              // ignore: invalid_use_of_protected_member
              vm.notifyListeners();
            },
          ),
          const SizedBox(height: 24),

          // ── Race selection ─────────────────────────────────────
          Text('Choose a Race',
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (vm.loadingRefs)
            const Center(
                child: CircularProgressIndicator(color: AppTheme.primary))
          else if (vm.refsError != null)
            _ErrorRetry(
                message: vm.refsError!, onRetry: vm.loadReferenceData)
          else
            _RaceGrid(races: vm.races, selected: vm.selectedRace,
                onSelect: vm.selectRace),
        ],
      ),
    );
  }
}

class _RaceGrid extends StatelessWidget {
  final List<RaceOption> races;
  final RaceOption? selected;
  final ValueChanged<RaceOption> onSelect;

  const _RaceGrid(
      {required this.races, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 2.8, crossAxisSpacing: 8,
          mainAxisSpacing: 8),
      itemCount: races.length,
      itemBuilder: (_, i) {
        final race = races[i];
        final isSelected = selected?.id == race.id;
        return GestureDetector(
          onTap: () => onSelect(race),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
                  width: isSelected ? 2 : 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Icon(Icons.shield_outlined,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(race.name,
                    style: GoogleFonts.cinzel(
                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(message,
            style: GoogleFonts.lato(color: AppTheme.accent, fontSize: 13)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry')),
      ]);
}