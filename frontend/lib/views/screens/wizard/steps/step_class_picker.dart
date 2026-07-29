import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../config/class_icons.dart';
import '../../../../models/character/character_class_entry.dart';
import '../../../../models/wizard/class_option.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';
import '../class_detail_screen.dart';

/// Multiclase (Aurora_Fixes.md #17, fase 2a): primer paso del wizard en modo level-up —
/// elegir a qué clase va el nuevo nivel (una que el personaje ya tiene, o una nueva).
class StepClassPicker extends StatelessWidget {
  const StepClassPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final existingClassIds = vm.characterClasses.map((c) => c.dndClassId).toSet();
    final newClassOptions =
        vm.classes.where((c) => !existingClassIds.contains(c.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text('Level Up', style: Theme.of(context).textTheme.displayMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Choose which class gains this new level.',
            style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final entry in vm.characterClasses)
                _ExistingClassCard(
                  entry: entry,
                  isSelected: vm.levelUpTargetClassId == entry.dndClassId,
                  onTap: () => vm.selectLevelUpTargetClass(entry),
                ),
              if (newClassOptions.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(2, 16, 2, 8),
                  child: Divider(color: AppTheme.surfaceVariant),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Take a new class',
                      style: GoogleFonts.libreBaskerville(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
                for (final cls in newClassOptions)
                  _NewClassCard(
                    cls: cls,
                    onTap: () => _openClassDetail(context, vm, cls),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openClassDetail(
      BuildContext context, CharacterCreatorViewModel vm, ClassOption cls) async {
    await vm.loadClassFeatures(cls.id);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassDetailScreen(
          classOption: cls,
          features: vm.classFeatures,
          vm: vm,
        ),
      ),
    );
  }
}

class _ExistingClassCard extends StatelessWidget {
  final CharacterClassEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExistingClassCard({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = classIcon(entry.dndClassName);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(icon,
                  color: isSelected ? AppTheme.background : AppTheme.primary, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level up as ${entry.dndClassName}',
                    style: GoogleFonts.libreBaskerville(
                        color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  entry.subclassName != null
                      ? 'Currently level ${entry.level} · ${entry.subclassName}'
                      : 'Currently level ${entry.level}',
                  style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
        ]),
      ),
    );
  }
}

class _NewClassCard extends StatelessWidget {
  final ClassOption cls;
  final VoidCallback onTap;

  const _NewClassCard({required this.cls, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = classIcon(cls.name);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: FaIcon(icon, color: AppTheme.primary, size: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(cls.name,
                style: GoogleFonts.libreBaskerville(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
        ]),
      ),
    );
  }
}
