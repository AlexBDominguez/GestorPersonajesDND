import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import '../sheet/character_sheet_screen.dart';
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
      create: (_) => CharacterCreatorViewModel(),
      child: const _WizardBody(),
    );
  }
}

class _WizardBody extends StatelessWidget {
  const _WizardBody();

  static const _stepTitles = [
    'Prefs', 'Class', 'Background', 'Race', 'Stats',
  ];
  static const _stepIcons = [
    Icons.settings_outlined, // Prefs -> settings icon
    Icons.security_outlined, // Class -> shield icon
    Icons.menu_book_outlined, // Background -> book icon
    Icons.emoji_people_outlined, // Race -> person icon
    Icons.bar_chart, // Stats -> bar chart icon
    //Icons.fix_high_outlined, // Spells -> magic wand icon (no se usa por ahora)
  ];
  static const _stepWidgets = [
    StepPreferences(),
    StepClass(),
    StepBackground(),
    StepRace(),
    StepAbilityScores(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    //Cuando se crea con éxito, navegar a la ficha
    if (vm.createdCharacterId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Reemplazamos el wizard por la ficha (no volvemos al dashboard con pop)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CharacterSheetScreen(
                characterId: vm.createdCharacterId!),
          ),
        );
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
        // Step indicator (pulsable)
        _StepIndicator(
          steps:    WizardStep.values,
          titles:   _stepTitles,
          icons:    _stepIcons,
          current:  vm.currentStepIndex,
          isCompleted: (step) => vm.isStepCompleted(step),
          isPartial:   (step) => vm.isStepPartial(step),
          onTap: (step) => vm.goToStep(step),
        ),
        const Divider(height: 1),

        // Step content
        Expanded(child: _stepWidgets[vm.currentStepIndex]),

        // Error banner
        if (vm.error != null)
          Container(
            width: double.infinity,
            color: AppTheme.accent.withOpacity(0.15),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              const Icon(Icons.error_outline,
                  color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(vm.error!,
                    style: GoogleFonts.lato(
                        color: AppTheme.accent, fontSize: 13)),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: AppTheme.accent, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: vm.clearError,
              ),
            ]),
          ),

        // Navigation buttons
        _NavButtons(vm: vm),
      ]),
    );
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Discard character?',
            style: GoogleFonts.cinzel(color: AppTheme.primary)),
        content: Text('Your progress will be lost.',
            style: GoogleFonts.lato(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep editing',
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) Navigator.of(context).pop();
  }
}

// Step indicator

class _StepIndicator extends StatelessWidget {
  final List<WizardStep> steps;
  final List<String> titles;
  final List<IconData> icons;
  final int current;
  final bool Function(WizardStep) isCompleted;
  final bool Function(WizardStep) isPartial;
  final void Function(WizardStep) onTap;

  const _StepIndicator({
    required this.steps,
    required this.titles,
    required this.icons,
    required this.current,
    required this.isCompleted,
    required this.isPartial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final done = isCompleted(step);
          final partial = isPartial(step);
          final isCurrent = i == current;

          return _StepDot(
            title:     titles[i],
            icon:      icons[i],
            isDone:    done,
            isPartial: partial,
            isCurrent: isCurrent,
            onTap:     () => onTap(step),
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDone;
  final bool isPartial;
  final bool isCurrent;
  final VoidCallback onTap;

  const _StepDot({
    required this.title,
    required this.icon,
    required this.isDone,
    required this.isPartial,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // isCurrent tiene prioridad máxima: siempre muestra el icono original
    final Color dotColor;
    final Color borderColor;
    final Color bgColor;
    final IconData dotIcon;
    final Color labelColor;

    if (isCurrent) {
      dotColor    = AppTheme.background;
      borderColor = AppTheme.primary;
      bgColor     = AppTheme.primary;
      dotIcon     = icon;
      labelColor  = AppTheme.primary;
    } else if (isDone) {
      // Tick original: fondo semi-transparente, check en dorado
      dotColor    = AppTheme.primary;
      borderColor = AppTheme.primary;
      bgColor     = AppTheme.primary.withOpacity(0.25);
      dotIcon     = Icons.check;
      labelColor  = AppTheme.primary;
    } else if (isPartial) {
      // Warning solo cuando hay cambios sin completar Y no es la tab actual
      dotColor    = Colors.amber;
      borderColor = Colors.amber;
      bgColor     = Colors.amber.withOpacity(0.15);
      dotIcon     = Icons.warning_amber_rounded;
      labelColor  = Colors.amber;
    } else {
      dotColor    = AppTheme.textSecondary;
      borderColor = AppTheme.textSecondary;
      bgColor     = AppTheme.background;
      dotIcon     = icon;
      labelColor  = AppTheme.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Icon(dotIcon, color: dotColor, size: 18),
        ),
        const SizedBox(height: 4),
        Text(title,
          style: GoogleFonts.lato(
            color: labelColor,
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}

// Navigation buttons

class _NavButtons extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  const _NavButtons({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isLast = vm.isLastStep;
    final canProceed = vm.canProceedCurrentStep && !vm.isSaving;

    // Estilo base compartido por Back y Next 
    final sharedShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10));
    const sharedPadding = EdgeInsets.symmetric(vertical: 14);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(children: [
        // Back
        if (!vm.isFirstStep) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: vm.previousStep,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.surfaceVariant),
                shape: sharedShape,
                padding: sharedPadding,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Next / Create Character 
        Expanded(
          flex: 2,
          child: Tooltip(
            // Tooltip solo visible cuando está deshabilitado 
            message: canProceed ? '' : 'Some steps are incomplete',
            child: ElevatedButton.icon(
              onPressed: canProceed
                  ? () => isLast ? vm.submit() : vm.nextStep()
                  : null,
              icon: vm.isSaving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.background))
                  : Icon(isLast ? Icons.check : Icons.arrow_forward,
                      size: 16),
              label: Text(isLast ? 'Create Character' : 'Next'),
              style: ElevatedButton.styleFrom(
                shape: sharedShape,
                padding: sharedPadding,
                // Deshabilitado más visible
                disabledBackgroundColor:
                    AppTheme.surfaceVariant,
                disabledForegroundColor:
                    AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}