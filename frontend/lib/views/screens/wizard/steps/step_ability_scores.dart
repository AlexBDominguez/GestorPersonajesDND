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
        const SizedBox(height: 12),

        // ── Mode toggle ─────────────────────────────────────────
        _ModeToggle(current: vm.scoreMethod, onChange: vm.setScoreMethod),
        const SizedBox(height: 16),

        if (vm.scoreMethod == AbilityScoreMethod.standardArray) ...[
          // ── Standard array helper chips ──────────────────────
          Text('Available values:',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: kStandardArray.map((val) {
              final isUsed = vm.standardArrayAssignments.values
                  .any((idx) => idx != null && kStandardArray[idx] == val);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isUsed
                      ? AppTheme.surfaceVariant.withValues(alpha: 0.4)
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
          const SizedBox(height: 20),
        ] else ...[
          Text(
            'Enter any value between 3 and 18 for each ability.',
            style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
        ],

        // ── Ability rows ────────────────────────────────────────
        ...kAbilityNames.map((ability) => vm.scoreMethod == AbilityScoreMethod.standardArray
            ? _StandardArrayRow(ability: ability, vm: vm)
            : _ManualRow(ability: ability, vm: vm)),

        // ── "All assigned" indicator (standard array only) ─────
        if (vm.scoreMethod == AbilityScoreMethod.standardArray && vm.allArrayValuesAssigned) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
            const SizedBox(width: 6),
            Text('All scores assigned!',
                style: GoogleFonts.lato(
                    color: AppTheme.primary,
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
        ],
      ]),
    );
  }
}

// ── Mode toggle ───────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final AbilityScoreMethod current;
  final ValueChanged<AbilityScoreMethod> onChange;
  const _ModeToggle({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(children: [
        _Tab(
          label: 'Standard Array',
          icon: Icons.view_list_outlined,
          selected: current == AbilityScoreMethod.standardArray,
          onTap: () => onChange(AbilityScoreMethod.standardArray),
        ),
        _Tab(
          label: 'Manual Entry',
          icon: Icons.edit_outlined,
          selected: current == AbilityScoreMethod.manual,
          onTap: () => onChange(AbilityScoreMethod.manual),
        ),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15,
                color: selected ? AppTheme.background : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.lato(
                  color: selected ? AppTheme.background : AppTheme.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.bold,
                )),
          ]),
        ),
      ),
    );
  }
}

// ── Standard Array row (dropdown) ─────────────────────────────────────────────

class _StandardArrayRow extends StatelessWidget {
  final String ability;
  final CharacterCreatorViewModel vm;
  const _StandardArrayRow({required this.ability, required this.vm});

  @override
  Widget build(BuildContext context) {
    final assignedIdx = vm.standardArrayAssignments[ability];
    final racialBonus = vm.racialBonuses[ability] ?? 0;
    final mod = vm.abilityModifier(ability);
    final modLabel = mod >= 0 ? '+$mod' : '$mod';
    final base = assignedIdx != null ? kStandardArray[assignedIdx] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Text(ability,
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: assignedIdx,
              dropdownColor: AppTheme.surface,
              hint: Text('Choose',
                  style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 20)),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('—', style: TextStyle(color: AppTheme.textSecondary, fontSize: 20)),
                ),
                ...List.generate(kStandardArray.length, (idx) {
                  final val = kStandardArray[idx];
                  final takenByOther = vm.standardArrayAssignments.entries
                      .any((e) => e.key != ability && e.value == idx);
                  return DropdownMenuItem<int?>(
                    value: idx,
                    enabled: !takenByOther,
                    child: Text('$val',
                        style: GoogleFonts.cinzel(
                          color: takenByOther ? AppTheme.textSecondary : AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
        if (racialBonus != 0) ...[
          const SizedBox(width: 6),
          Text('+$racialBonus',
              style: GoogleFonts.lato(
                  color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
        const Spacer(),
        Text(
          base != null ? modLabel : '—',
          style: GoogleFonts.cinzel(
              color: base != null
                  ? (mod >= 0 ? AppTheme.primary : AppTheme.accent)
                  : AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }
}

// ── Manual entry row (+/- buttons) ───────────────────────────────────────────

class _ManualRow extends StatelessWidget {
  final String ability;
  final CharacterCreatorViewModel vm;
  const _ManualRow({required this.ability, required this.vm});

  @override
  Widget build(BuildContext context) {
    final base = vm.abilityScores[ability] ?? 10;
    final racialBonus = vm.racialBonuses[ability] ?? 0;
    final mod = vm.abilityModifier(ability);
    final modLabel = mod >= 0 ? '+$mod' : '$mod';
    final atMin = base <= 3;
    final atMax = base >= 18;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        SizedBox(
          width: 44,
          child: Text(ability,
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),

        // ── Stepper ────────────────────────────────────────────
        IconButton(
          onPressed: atMin ? null : () => vm.setManualScore(ability, base - 1),
          icon: const Icon(Icons.remove_circle_outline, size: 22),
          color: atMin ? AppTheme.textSecondary : AppTheme.primary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(
          width: 40,
          child: Center(
            child: Text('$base',
                style: GoogleFonts.cinzel(
                    color: AppTheme.textPrimary,
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        IconButton(
          onPressed: atMax ? null : () => vm.setManualScore(ability, base + 1),
          icon: const Icon(Icons.add_circle_outline, size: 22),
          color: atMax ? AppTheme.textSecondary : AppTheme.primary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),

        // ── Racial bonus ───────────────────────────────────────
        if (racialBonus != 0) ...[
          const SizedBox(width: 6),
          Text('+$racialBonus',
              style: GoogleFonts.lato(
                  color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
        ],

        const Spacer(),

        // ── Modifier ──────────────────────────────────────────
        Text(modLabel,
            style: GoogleFonts.cinzel(
                color: mod >= 0 ? AppTheme.primary : AppTheme.accent,
                fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
