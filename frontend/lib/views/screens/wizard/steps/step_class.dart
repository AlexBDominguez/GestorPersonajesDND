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
import '../class_options_screen.dart';
import '../manage_class_screen.dart';

class StepClass extends StatefulWidget {
  const StepClass({super.key});

  @override
  State<StepClass> createState() => _StepClassState();
}

class _StepClassState extends State<StepClass> {
  // Multiclase (fase 2b): alterna qué catálogo muestra la lista scrolleable de abajo --
  // la clase primaria (de siempre) o las candidatas a clase adicional. Vive aquí (estado
  // de UI puro, no del ViewModel) para reutilizar el ÚNICO área scrolleable existente
  // (Expanded+ListView) en vez de añadir una lista sin scroll propio que desborde la
  // pantalla al expandirse (el bug real de la captura del usuario).
  bool _addingAnotherClass = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    // Level-up mode: class is locked — show compact card + open ClassOptionsScreen
    // directly to configure the new level (which class this is was already chosen in the
    // classPicker step).
    if (vm.isLevelUpMode && vm.selectedClass != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text('Your Class',
                style: Theme.of(context).textTheme.displayMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Class is locked. You can change your level, subclass and feature choices below.',
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _SelectedClassBadge(
              cls: vm.selectedClass!,
              level: vm.selectedLevel,
              onClear: () {}, // locked in edit mode — no-op
              showClear: false,
              onEdit: () => _openClassEdit(context, vm),
            ),
          ),
        ],
      );
    }

    // Multiclase (Aurora_Fixes.md #17, fase 4c): "Edit Character" (edición pura, no
    // level-up) muestra TODAS las clases del personaje -- tocar una abre su gestión de
    // subclase + hechizos. El nivel no se toca aquí (solo desde "Level Up").
    if (vm.isEditMode && !vm.isLevelUpMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text('Your Classes',
                style: Theme.of(context).textTheme.displayMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Level is only changed from "Level Up" on the character sheet. Tap a class to manage its subclass and spells.',
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vm.characterClasses.length,
              itemBuilder: (_, i) {
                final entry = vm.characterClasses[i];
                return _ManagedClassCard(
                  entry: entry,
                  edited: vm.editedClassIds.contains(entry.dndClassId),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ManageClassScreen(entry: entry)),
                  ),
                );
              },
            ),
          ),
        ],
      );
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
            style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 14),
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
        // Multiclase (Aurora_Fixes.md #17, fase 2b): clases adicionales ya añadidas +
        // opción de añadir otra, dentro del propio wizard de creación. La lista de
        // candidatas (cuando _addingAnotherClass es true) se muestra reutilizando el
        // ÚNICO ListView scrolleable de más abajo, no aquí (ver ese Expanded).
        if (vm.selectedClass != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < vm.additionalClasses.length; i++)
                  _AdditionalClassBadge(
                    className: vm.additionalClasses[i].classOption.name,
                    level: vm.additionalClasses[i].level,
                    onRemove: () => vm.removeAdditionalClass(i),
                  ),
                GestureDetector(
                  onTap: () => setState(() => _addingAnotherClass = !_addingAnotherClass),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Icon(
                          _addingAnotherClass
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline,
                          color: AppTheme.primary,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(
                          _addingAnotherClass
                              ? 'Cancel adding a class'
                              : 'Add another class (multiclass)',
                          style: GoogleFonts.libreBaskerville(
                              color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _addingAnotherClass
              ? _AdditionalClassCatalog(
                  vm: vm,
                  onPicked: (cls) async {
                    await _addAnotherClass(context, vm, cls);
                    if (mounted) setState(() => _addingAnotherClass = false);
                  },
                )
              : ListView.builder(
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

  /// Multiclase (fase 2b): arranca la configuración de una clase adicional (snapshot de
  /// la primaria + campos en blanco), abre el mismo ClassDetailScreen/ClassOptionsScreen
  /// de siempre para configurarla, y limpia el estado si el usuario vuelve atrás sin
  /// confirmar ni cancelar explícitamente (p.ej. la flecha de retroceso de
  /// ClassDetailScreen, que no toca el ViewModel).
  Future<void> _addAnotherClass(
      BuildContext context, CharacterCreatorViewModel vm, ClassOption cls) async {
    vm.startConfiguringAdditionalClass();
    await vm.loadClassFeatures(cls.id);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassDetailScreen(
          classOption: cls,
          features: vm.classFeatures,
          vm: vm,
        ),
      ),
    );
    // ClassDetailScreen.onAdd hace pushReplacement (no push) hacia ClassOptionsScreen --
    // eso completa este await INMEDIATAMENTE al reemplazar la ruta, no cuando
    // ClassOptionsScreen se cierra de verdad (semántica de Navigator.pushReplacement).
    // Por eso NO se puede usar solo isConfiguringAdditionalClass para detectar "volvió
    // atrás sin elegir clase": selectClass(cls) ya se habrá llamado (dentro de ese mismo
    // onAdd, justo antes del pushReplacement) en el caso normal de haber avanzado, así
    // que solo limpiamos si selectedClass sigue null -- señal fiable de que el usuario
    // volvió atrás desde ClassDetailScreen (flecha o "Cancel") sin llegar a elegir nada.
    if (vm.isConfiguringAdditionalClass && vm.selectedClass == null) {
      vm.cancelDanglingAdditionalClass();
    }
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

/// Multiclase (Aurora_Fixes.md #17, fase 4c): fila de una clase existente del personaje en
/// "Edit Character" (edición pura) -- tocar abre ManageClassScreen para esa clase.
class _ManagedClassCard extends StatelessWidget {
  final CharacterClassEntry entry;
  final bool edited;
  final VoidCallback onTap;

  const _ManagedClassCard({
    required this.entry,
    required this.edited,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.dndClassName,
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  entry.subclassName != null
                      ? 'Level ${entry.level} · ${entry.subclassName}'
                      : 'Level ${entry.level}',
                  style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (edited) ...[
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
        ]),
      ),
    );
  }
}

class _SelectedClassBadge extends StatelessWidget {
  final ClassOption cls;
  final int level;
  final VoidCallback onClear;
  final VoidCallback? onEdit;
  final bool showClear;

  const _SelectedClassBadge({
    required this.cls,
    required this.level,
    required this.onClear,
    this.onEdit,
    this.showClear = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
      child: Row(children: [
        FaIcon(classIcon(cls.name),
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
                    style: GoogleFonts.libreBaskerville(
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
        if (showClear) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
          ),
        ],
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
    final icon = classIcon(cls.name);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.12)
              : isDisabled
                  ? AppTheme.surface.withValues(alpha: 0.4)
                  : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : isDisabled
                    ? AppTheme.surfaceVariant.withValues(alpha: 0.4)
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
                      style: GoogleFonts.libreBaskerville(
                          color: isSelected
                              ? AppTheme.primary
                              : isDisabled
                                  ? AppTheme.textSecondary.withValues(alpha: 0.4)
                                  : AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  if (cls.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(cls.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 14)),
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

/// Multiclase (fase 2b): badge de una clase adicional ya confirmada, con opción de quitarla.
class _AdditionalClassBadge extends StatelessWidget {
  final String className;
  final int level;
  final VoidCallback onRemove;

  const _AdditionalClassBadge({
    required this.className,
    required this.level,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
      child: Row(children: [
        FaIcon(classIcon(className), color: AppTheme.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
              children: [
                TextSpan(
                    text: className,
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.primary, fontWeight: FontWeight.bold)),
                TextSpan(text: '  ·  Level $level'),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
        ),
      ]),
    );
  }
}

/// Multiclase (fase 2b): catálogo de clases candidatas a clase adicional (todas menos la
/// primaria y las ya añadidas), mostrado en el mismo ListView scrolleable que el catálogo
/// normal — evita el overflow de tener una lista sin scroll propio fuera de él.
class _AdditionalClassCatalog extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  final ValueChanged<ClassOption> onPicked;

  const _AdditionalClassCatalog({required this.vm, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    final usedIds = <int>{
      if (vm.selectedClass != null) vm.selectedClass!.id,
      ...vm.additionalClasses.map((c) => c.classOption.id),
    };
    final available = vm.classes.where((c) => !usedIds.contains(c.id)).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: available.length,
      itemBuilder: (_, i) {
        final cls = available[i];
        return _ClassCard(
          cls: cls,
          isSelected: false,
          onTap: () => onPicked(cls),
        );
      },
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
              ? AppTheme.primary.withValues(alpha: 0.2)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
        ),
        child: Text('d$hitDie',
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      );
}
