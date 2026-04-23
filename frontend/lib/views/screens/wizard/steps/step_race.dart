import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/models/wizard/race_option.dart';
import 'package:gestor_personajes_dnd/models/wizard/subrace_option.dart';
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

        // Si hay subraza seleccionada, muestra el selector expandido
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16),
              itemCount: vm.races.length,
              itemBuilder: (_, i) {
                final race = vm.races[i];
                final isSelected = vm.selectedRace?.id == race.id;
                return Column(
                  children: [
                    _RaceCard(
                      race: race,
                      isSelected: isSelected,
                      onTap: () => vm.selectRace(race),
                    ),
                    if (isSelected && (vm.subraces.isNotEmpty || vm.isLoadingSubraces))
                      _SubraceSelector(vm: vm),
                    if (isSelected && vm.raceFeatureChoices.isNotEmpty)
                      _RaceChoiceSection(vm: vm),
                  ],
                );
              },
            ),
          ),
      ]);
  }
}

class _RaceCard extends StatelessWidget {
  final RaceOption race;
  final bool isSelected;
  final VoidCallback onTap;
  const _RaceCard(
      {required this.race, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context){ 
    return GestureDetector(
      onTap: onTap,
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
                color: 
                    isSelected ? AppTheme.background : AppTheme.primary,
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
                    _Tag('Speed ${race.speed} ft.'),
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
                        color: AppTheme.textSecondary,
                        fontSize: 12)),
                  ],
                ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SubraceSelector extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  const _SubraceSelector({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingSubraces) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.primary),
          ),
        ),
      );
    }
    if (vm.subraces.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Choose a subrace (required)',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
          ...vm.subraces.map((sub) => _SubraceChip(
                subrace: sub,
                isSelected: vm.selectedSubrace?.id == sub.id,
                onTap: () => vm.selectSubrace(sub),
              )),
        ],
      ),
    );
  }
}

class _SubraceChip extends StatelessWidget {
  final SubraceOption subrace;
  final bool isSelected;
  final VoidCallback onTap;
  const _SubraceChip(
      {required this.subrace,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
                width: 1.5,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check,
                    color: AppTheme.background, size: 12)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subrace.name,
                      style: GoogleFonts.cinzel(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  if (subrace.bonusText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subrace.bonusText,
                        style: GoogleFonts.lato(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                  if (subrace.traits.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subrace.traits.join(' · '),
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ]),
          ),
        ]),
      ),
    );
  }
}

// ── Race feature choices ─────────────────────────────────────────────────────────────────

class _RaceChoiceSection extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  const _RaceChoiceSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
      child: Column(
        children: vm.raceFeatureChoices
            .map((c) => _RaceChoiceBlock(
                  config: c,
                  selected: vm.featureChoices[c.key],
                  onSelect: (val) => vm.setFeatureChoice(c.key, val),
                ))
            .toList(),
      ),
    );
  }
}

class _RaceChoiceBlock extends StatelessWidget {
  final WizardChoiceConfig config;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _RaceChoiceBlock({
    required this.config,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final done = selected != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: done
              ? AppTheme.primary.withOpacity(0.6)
              : AppTheme.accent.withOpacity(0.4),
          width: done ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: BoxDecoration(
              color: done
                  ? AppTheme.primary.withOpacity(0.10)
                  : AppTheme.accent.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(children: [
              Icon(
                done
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                color: done ? AppTheme.primary : AppTheme.accent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(config.label,
                    style: GoogleFonts.cinzel(
                        color: done ? AppTheme.primary : AppTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              if (done)
                Text(selected!,
                    style: GoogleFonts.lato(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontStyle: FontStyle.italic)),
            ]),
          ),
          // Options
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: config.options
                  .map((opt) => _RaceOptionTile(
                        label: opt.name,
                        description: opt.description,
                        selected: selected == opt.name,
                        onTap: () => onSelect(opt.name),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RaceOptionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  const _RaceOptionTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 16, height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 10)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.cinzel(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 1),
                Text(description,
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        height: 1.3)),
              ],
            ),
          ),
        ]),
      ),
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