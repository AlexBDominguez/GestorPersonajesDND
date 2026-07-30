import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/views/screens/wizard/steps/step_equipment.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../services/characters/character_service.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'level_up_screen.dart';
import 'steps/step_race.dart';
import 'steps/step_class.dart';
import 'steps/step_class_picker.dart';
import 'steps/step_ability_scores.dart';
import 'steps/step_background.dart';
import 'steps/step_preferences.dart';
import 'steps/step_spells.dart';

class CharacterCreatorScreen extends StatelessWidget {
  const CharacterCreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterCreatorViewModel(),
      child: const CharacterWizardBody(),
    );
  }
}

/// Public wizard body widget — reusable by [EditCharacterScreen].
class CharacterWizardBody extends StatelessWidget {
  const CharacterWizardBody({super.key});

  // Metadatos por paso: título e icono
  static const _meta = <WizardStep, ({String title, IconData icon})>{
    WizardStep.preferences:   (title: 'Prefs',    icon: Icons.settings_outlined),
    WizardStep.dndClass:      (title: 'Class',    icon: Icons.security_outlined),
    WizardStep.background:    (title: 'BG',       icon: Icons.menu_book_outlined),
    WizardStep.race:          (title: 'Race',     icon: Icons.emoji_people_outlined),
    WizardStep.abilityScores: (title: 'Stats',    icon: Icons.bar_chart),
    WizardStep.spells:        (title: 'Spells',   icon: Icons.auto_fix_high_outlined),
    WizardStep.equipment:     (title: 'Items',    icon: Icons.backpack_outlined),
    WizardStep.classPicker:   (title: 'Level Up', icon: Icons.upgrade_outlined),
  };

  String _stepTitle(BuildContext context, WizardStep step) {
    return switch (step) {
      WizardStep.preferences => 'Prefs',
      WizardStep.dndClass => 'Class',
      WizardStep.background => 'BG',
      WizardStep.race => 'Race',
      WizardStep.abilityScores => 'Stats',
      WizardStep.spells => 'Spells',
      WizardStep.equipment => 'Items',
      WizardStep.classPicker => 'Level Up',
    };
  }

  Widget _stepWidget(WizardStep step) {
    switch (step) {
      case WizardStep.preferences:   return const StepPreferences();
      case WizardStep.dndClass:      return const StepClass();
      case WizardStep.background:    return const StepBackground();
      case WizardStep.race:          return const StepRace();
      case WizardStep.abilityScores: return const StepAbilityScores();
      case WizardStep.spells:        return const StepSpells();
      case WizardStep.equipment:     return const StepEquipment();
      case WizardStep.classPicker:   return const StepClassPicker();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    // When saved successfully, go back — pass new character ID on create, true on edit.
    // Multiclase (Aurora_Fixes.md #17, fase 2a): si el level-up devolvió avisos no
    // bloqueantes (prerrequisitos/proficiencies), se muestran antes de volver.
    if (vm.saveSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        final warnings = vm.lastLevelUpWarnings;
        if (warnings.isNotEmpty) {
          await showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppTheme.surface,
              title: Text('Heads up', style: GoogleFonts.libreBaskerville(color: AppTheme.primary)),
              content: Text(warnings.join('\n\n'),
                  style: GoogleFonts.lato(color: AppTheme.textPrimary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }

        // Multiclase (Aurora_Fixes.md #17, fase 2b): tras crear el personaje (no en
        // edición/level-up), ofrecer encadenar directamente el selector de clase de la
        // fase 2a para añadir una segunda clase sin volver a la ficha primero.
        if (!vm.isEditMode && vm.createdCharacterId != null) {
          if (!context.mounted) return;
          final addAnother = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppTheme.surface,
              title: Text('Character created',
                  style: GoogleFonts.libreBaskerville(color: AppTheme.primary)),
              content: Text('Add a second class now (multiclass)?',
                  style: GoogleFonts.lato(color: AppTheme.textPrimary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Not now'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Add a class'),
                ),
              ],
            ),
          );
          if (addAnother == true) {
            if (!context.mounted) return;
            try {
              final character =
                  await CharacterService().getCharacterById(vm.createdCharacterId!);
              if (!context.mounted) return;
              // push (no pushReplacement): esta ruta de creación la abrió dashboard_screen.dart
              // con Navigator.push<int>(...), esperando el id del personaje al cerrarse. El
              // wizard de level-up (misma CharacterWizardBody) se cierra con pop(true) (bool,
              // vm.isEditMode=true en level-up) -- sustituir la ruta pasaría ese bool a resolver
              // el Future<int?> original. Apilando en vez de sustituir, esta ruta sigue siendo
              // la que cierra el push<int> original, con el tipo correcto, cuando la de abajo termine.
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LevelUpScreen(character: character)),
              );
            } catch (_) {
              // Si falla cargar el personaje recién creado, no bloquear: caer al pop normal.
            }
          }
        }

        if (!context.mounted) return;
        Navigator.of(context).pop(vm.isEditMode ? true : vm.createdCharacterId);
      });
    }

    final activeSteps = vm.activeSteps;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: Text(vm.isLevelUpMode
          ? 'Level Up'
          : vm.isEditMode
            ? 'Edit Character'
            : 'New Character'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmDiscard(context, vm.isEditMode),
        ),
      ),
      body: Column(children: [
        // Step indicator (pulsable, dinámico)
        _StepIndicator(
          steps:       activeSteps,
          current:     vm.currentStepIndex,
          meta:        {
            for (final e in _meta.entries)
              e.key: (title: _stepTitle(context, e.key), icon: e.value.icon),
          },
          isCompleted: (step) => vm.isStepCompleted(step),
          isPartial:   (step) => vm.isStepPartial(step),
          onTap:       (step) => vm.goToStep(step),
        ),
        const Divider(height: 1),

        // Step content
        Expanded(child: _stepWidget(vm.currentStep)),

        // Error banner
        if (vm.error != null)
          Container(
            width: double.infinity,
            color: AppTheme.accent.withValues(alpha: 0.15),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              const Icon(Icons.error_outline, color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(vm.error!,
                    style: GoogleFonts.lato(color: AppTheme.accent, fontSize: 13)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.accent, size: 16),
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

  Future<void> _confirmDiscard(BuildContext context, bool isEditMode) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEditMode
              ? 'Discard changes?'
              : 'Discard character?',
          style: GoogleFonts.libreBaskerville(color: AppTheme.primary),
        ),
        content: Text(
          isEditMode
              ? 'Your changes will not be saved.'
              : 'Your progress will be lost.',
          style: GoogleFonts.lato(color: AppTheme.textPrimary),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.surfaceVariant, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(
                      'Cancel',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Discard'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) Navigator.of(context).pop();
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final List<WizardStep> steps;
  final int current;
  final Map<WizardStep, ({String title, IconData icon})> meta;
  final bool Function(WizardStep) isCompleted;
  final bool Function(WizardStep) isPartial;
  final void Function(WizardStep) onTap;

  const _StepIndicator({
    required this.steps,
    required this.current,
    required this.meta,
    required this.isCompleted,
    required this.isPartial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(builder: (context, constraints) {
        // If each step has less than ~52 px we switch to compact (smaller) mode
        final perStep = constraints.maxWidth / steps.length;
        final compact = perStep < 56;
        return Row(
          children: List.generate(steps.length, (i) {
            final step = steps[i];
            return Expanded(
              child: Center(
                child: _StepDot(
                  title:     meta[step]!.title,
                  icon:      meta[step]!.icon,
                  isDone:    isCompleted(step),
                  isPartial: isPartial(step),
                  isCurrent: i == current,
                  compact:   compact,
                  onTap:     () => onTap(step),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ── Step Dot ──────────────────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDone;
  final bool isPartial;
  final bool isCurrent;
  final bool compact;
  final VoidCallback onTap;

  const _StepDot({
    required this.title,
    required this.icon,
    required this.isDone,
    required this.isPartial,
    required this.isCurrent,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
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
      dotColor    = AppTheme.primary;
      borderColor = AppTheme.primary;
      bgColor     = AppTheme.primary.withValues(alpha: 0.25);
      dotIcon     = Icons.check;
      labelColor  = AppTheme.primary;
    } else if (isPartial) {
      dotColor    = Colors.amber;
      borderColor = Colors.amber;
      bgColor     = Colors.amber.withValues(alpha: 0.15);
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
          width:  compact ? 26 : 34,
          height: compact ? 26 : 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Icon(dotIcon, color: dotColor, size: compact ? 13 : 17),
        ),
        const SizedBox(height: 3),
        Text(title,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            color: labelColor,
            fontSize: compact ? 8 : 9,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          )),
      ]),
    );
  }
}

// ── Nav Buttons ───────────────────────────────────────────────────────────────

class _NavButtons extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  const _NavButtons({required this.vm});

  @override
  Widget build(BuildContext context) {
    final isLast     = vm.isLastStep;
    final canProceed = vm.canProceedCurrentStep && !vm.isSaving;
    final bottom     = MediaQuery.of(context).padding.bottom;
    // Plain edit mode (not level-up: that still has to walk new-level choices in order)
    // can save from any step — the step dots above already allow jumping freely.
    final canSaveEarly = vm.isEditMode && !vm.isLevelUpMode;

    final sharedShape   = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    const sharedPadding = EdgeInsets.symmetric(vertical: 12);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottom > 0 ? bottom + 12 : 16),
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

        // Next / Save Changes / Create Character
        Expanded(
          flex: 2,
          child: Tooltip(
            message: canProceed ? '' : 'Some steps are incomplete',
            child: ElevatedButton.icon(
              onPressed: canProceed
                  ? () => (isLast || canSaveEarly) ? vm.submit() : vm.nextStep()
                  : null,
              icon: vm.isSaving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.background))
                  : Icon((isLast || canSaveEarly) ? Icons.check : Icons.arrow_forward, size: 16),
              label: Text(vm.isSaving
                  ? (vm.isLevelUpMode
                    ? 'Leveling Up…'
                    : vm.isEditMode
                      ? 'Saving...'
                      : 'Creating…')
                  : canSaveEarly
                    ? 'Save Changes'
                    : isLast
                      ? (vm.isLevelUpMode
                        ? 'Level Up'
                        : vm.isEditMode
                          ? 'Save Changes'
                          : 'Create Character')
                      : 'Next'),
              style: ElevatedButton.styleFrom(
                shape: sharedShape,
                padding: sharedPadding,
                disabledBackgroundColor: AppTheme.surfaceVariant,
                disabledForegroundColor: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}