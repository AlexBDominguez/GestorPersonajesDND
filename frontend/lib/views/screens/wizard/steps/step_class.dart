import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../models/wizard/class_option.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';
import '../class_detail_screen.dart';
import '../class_options_screen.dart';

class StepClass extends StatelessWidget {
  const StepClass({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text('Choose your Class',
              style: Theme.of(context).textTheme.displayMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Your class is the primary definition of what your character does. Tap a class to see all details.',
            style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
        // Badge con la clase seleccionada (si hay una)
        if (vm.selectedClass != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _SelectedClassBadge(
              cls: vm.selectedClass!,
              level: vm.selectedLevel,
              onClear: vm.clearClass,
              onEdit: () => _openClassEdit(context, vm),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.classes.length,
            itemBuilder: (_, i) {
              final cls = vm.classes[i];
              final isSelected = vm.selectedClass?.id == cls.id;
              final otherSelected = vm.selectedClass != null && !isSelected;
              return _ClassCard(
                cls: cls,
                isSelected: isSelected,
                isDisabled: otherSelected,
                onTap: otherSelected ? null : () => _openClassDetail(context, vm, cls),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openClassDetail(
      BuildContext context, CharacterCreatorViewModel vm, ClassOption cls) async {
    // Cargar features si aún no se han cargado para esta clase
    List<ClassFeature> features = vm.classFeatures;
    if (vm.selectedClass?.id != cls.id || features.isEmpty) {
      await vm.loadClassFeatures(cls.id);
      features = vm.classFeatures;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassDetailScreen(
          classOption: cls,
          features: features,
          vm: vm,
        ),
      ),
    );
  }

  /// Opens ClassOptionsScreen directly for editing an already-selected class.
  Future<void> _openClassEdit(
      BuildContext context, CharacterCreatorViewModel vm) async {
    final cls = vm.selectedClass!;
    List<ClassFeature> features = vm.classFeatures;
    if (features.isEmpty) {
      await vm.loadClassFeatures(cls.id);
      features = vm.classFeatures;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassOptionsScreen(
          classOption: cls,
          features: features,
          vm: vm,
          isEditing: true,
        ),
      ),
    );
  }
}

class _SelectedClassBadge extends StatelessWidget {
  final ClassOption cls;
  final int level;
  final VoidCallback onClear;
  final VoidCallback? onEdit;

  const _SelectedClassBadge({
    required this.cls,
    required this.level,
    required this.onClear,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
      child: Row(children: [
        FaIcon(classIcon(cls.indexName),
            color: AppTheme.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.lato(
                  color: AppTheme.textPrimary, fontSize: 13),
              children: [
                TextSpan(
                    text: cls.name,
                    style: GoogleFonts.cinzel(
                        color: AppTheme.primary, fontWeight: FontWeight.bold)),
                TextSpan(text: '  ·  Level $level'),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          child: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 18),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onClear,
          child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
        ),
      ]),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final ClassOption cls;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _ClassCard({
    required this.cls,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = classIcon(cls.indexName);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.12)
              : isDisabled
                  ? AppTheme.surface.withOpacity(0.4)
                  : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : isDisabled
                    ? AppTheme.surfaceVariant.withOpacity(0.4)
                    : AppTheme.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            // Icono temático de la clase
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: isSelected ? AppTheme.background : AppTheme.primary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cls.name,
                      style: GoogleFonts.cinzel(
                          color: isSelected
                              ? AppTheme.primary
                              : isDisabled
                                  ? AppTheme.textSecondary.withOpacity(0.4)
                                  : AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  if (cls.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(cls.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Hit die badge en la parte derecha
            _HitDieBadge(hitDie: cls.hitDie, selected: isSelected),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 18),
          ]),
        ),
      ),
    );
  }
}

class _HitDieBadge extends StatelessWidget {
  final int hitDie;
  final bool selected;
  const _HitDieBadge({required this.hitDie, required this.selected});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.2)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
        ),
        child: Text('d$hitDie',
            style: GoogleFonts.cinzel(
                color: AppTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}