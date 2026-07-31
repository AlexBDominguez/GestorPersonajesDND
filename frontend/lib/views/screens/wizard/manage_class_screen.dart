import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../models/character/character_class_entry.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'class_options_screen.dart' show SubclassSelectorSection;
import 'steps/step_spells.dart';

/// Multiclase (Aurora_Fixes.md #17, fase 4c): gestionar (subclase + hechizos) una clase
/// EXISTENTE del personaje desde "Edit Character" -- primaria o secundaria. El nivel se
/// muestra de solo lectura: solo se sube desde "Level Up" (decisión confirmada con el
/// usuario, evita duplicar ahí la lógica de tiradas de HP/features por nivel).
///
/// Reutiliza `SubclassSelectorSection` (de `class_options_screen.dart`) y `StepSpells` tal
/// cual -- ambos ya parametrizados por `selectedClass`/`selectedSubclass`/`selectedLevel`,
/// que en este punto apuntan a la clase en gestión gracias al snapshot/restore de
/// `startManagingExistingClass()`.
class ManageClassScreen extends StatefulWidget {
  final CharacterClassEntry entry;

  const ManageClassScreen({super.key, required this.entry});

  @override
  State<ManageClassScreen> createState() => _ManageClassScreenState();
}

class _ManageClassScreenState extends State<ManageClassScreen> {
  // Si el usuario confirma ("Save"), la limpieza de la sesión ya la hizo
  // confirmManagingExistingClass() -- este flag evita que el PopScope de abajo la deshaga
  // otra vez tratando ese pop como una cancelación.
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CharacterCreatorViewModel>().startManagingExistingClass(widget.entry);
    });
  }

  void _onConfirm(CharacterCreatorViewModel vm) {
    _confirmed = true;
    vm.confirmManagingExistingClass();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    // Multiclase (Aurora_Fixes.md #17, fase 4c): captura CUALQUIER forma de salir de esta
    // pantalla sin pulsar "Save" -- flecha de la AppBar, gesto de retroceso o botón físico
    // "atrás" incluidos -- para descartar la sesión de gestión (restaurar la clase primaria
    // en los campos compartidos). Sin esto, salir por el gesto del sistema (en vez de la
    // flecha) dejaría isManagingExistingClass atascado en true.
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop || _confirmed) return;
        vm.cancelManagingExistingClass();
      },
      child: _buildScaffold(context, vm),
    );
  }

  Widget _buildScaffold(BuildContext context, CharacterCreatorViewModel vm) {
    // Todavía no ha corrido startManagingExistingClass() (primer frame) o está cargando el
    // catálogo de clases/subclases.
    if (!vm.isManagingExistingClass || vm.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: Text(widget.entry.dndClassName)),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final showSpells = vm.isSpellcaster;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.entry.dndClassName,
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.surfaceVariant),
              ),
              child: Row(children: [
                Text('Level',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(width: 8),
                Text('${widget.entry.level}',
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('Level up from the sheet to raise this',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
              ]),
            ),
            const SizedBox(height: 20),
            SubclassSelectorSection(vm: vm, currentLevel: widget.entry.level),
            if (showSpells) ...[
              Text('Spells',
                  style: GoogleFonts.libreBaskerville(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // StepSpells trae su propio scroll interno -- se limita en altura para poder
              // convivir con el resto del contenido dentro de este SingleChildScrollView.
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: const StepSpells(),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _onConfirm(vm),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text('Save', style: GoogleFonts.libreBaskerville(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
