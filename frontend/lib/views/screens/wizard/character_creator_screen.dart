import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'steps/step_race.dart';
import 'steps/step_class.dart';
import 'steps/step_ability_scores.dart';
import 'steps/step_background.dart';
import 'steps/step_preferences.dart';

class CharacterCreatorScreen extends StatelessWidget {
  const CharacterCreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // El ViewModel nuevo carga datos paso a paso via _loadStepData()
      create: (_) => CharacterCreatorViewModel(),
      child: const _WizardBody(),
    );
  }
}

class _WizardBody extends StatelessWidget {
  const _WizardBody();

  static const _stepTitles = [
    'Prefs', 'Class', 'Background', 'Race', 'Stats'
  ];
  static const _stepIcons = [
    Icons.settings_outlined,
    Icons.auto_fix_high_outlined,
    Icons.menu_book_outlined,
    Icons.shield_outlined,
    Icons.bar_chart,
  ];
  static const _steps = [
    StepPreferences(),
    StepClass(),
    StepBackground(),
    StepRace(),
    StepAbilityScores(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    
    if (vm.saveSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(true);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Character'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmDiscard(context),
        ),
      ),
      body: Column(children: [
        // ── Progress indicator ─────────────────────────────────────
        _StepIndicator(
          current: vm.currentStepIndex, 
          titles: _stepTitles,
          icons: _stepIcons,
        ),
        const Divider(height: 1),

        // ── Step content ───────────────────────────────────────────
        Expanded(child: _steps[vm.currentStepIndex]),

        // ── Error banner ───────────────────────────────────────────
        if (vm.error != null) 
          Container(
            width: double.infinity,
            color: AppTheme.accent.withOpacity(0.15),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              const Icon(Icons.error_outline, color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(vm.error!,
                    style: GoogleFonts.lato(color: AppTheme.accent, fontSize: 13)),
              ),
            ]),
          ),

        // ── Navigation buttons ─────────────────────────────────────
        _NavButtons(vm: vm),
      ]),
    );
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Discard character?',
            style: GoogleFonts.cinzel(color: AppTheme.primary)),
        content: Text('Your progress will be lost.',
            style: GoogleFonts.lato(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep editing',
                style: GoogleFonts.lato(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) Navigator.of(context).pop();
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final List<String> titles;
  final List<IconData> icons;
  const _StepIndicator({required this.current, required this.titles, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(titles.length, (i) => _StepDot(
          index: i, title: titles[i], icon: icons[i],
          isDone: i < current, isCurrent: i == current,
        )),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool isDone;
  final bool isCurrent;
  const _StepDot({required this.index, required this.title, required this.icon,
      required this.isDone, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final color = isDone || isCurrent ? AppTheme.primary : AppTheme.textSecondary;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCurrent ? AppTheme.primary
              : isDone ? AppTheme.primary.withOpacity(0.25)
              : AppTheme.background,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(isDone ? Icons.check : icon,
            color: isCurrent ? AppTheme.background : color, size: 18),
      ),
      const SizedBox(height: 4),
      Text(title, style: GoogleFonts.lato(
          color: color, fontSize: 10,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
    ]);
  }
}

// ── Navigation buttons ────────────────────────────────────────────────────────

class _NavButtons extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  const _NavButtons({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isLast = vm.isLastStep; 

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(children: [
        if (!vm.isFirstStep) ...[ 
          Expanded(
            child: OutlinedButton.icon(
              onPressed: vm.previousStep,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.surfaceVariant),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            
            onPressed: (vm.canProceedCurrentStep && !vm.isSaving)
                ? () => isLast ? vm.submit() : vm.nextStep()
                : null,
            icon: vm.isSaving
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.background))
                : Icon(isLast ? Icons.check : Icons.arrow_forward, size: 16),
            label: Text(isLast ? 'Create Character' : 'Next'),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ]),
    );
  }
}