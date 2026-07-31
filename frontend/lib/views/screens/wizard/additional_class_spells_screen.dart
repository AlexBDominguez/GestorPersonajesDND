import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'steps/step_spells.dart';

/// Multiclase (Aurora_Fixes.md #17, fase 4b): paso de hechizos para una clase ADICIONAL
/// configurada durante la creación. `ClassOptionsScreen._onConfirm()` navega aquí (en vez
/// de cerrar directamente) cuando la clase adicional recién configurada es lanzadora.
///
/// Reutiliza `StepSpells` tal cual -- ya está parametrizado por `selectedClass`/
/// `selectedLevel`/`selectedSubclass`, que en este punto siguen apuntando a la clase
/// adicional gracias al snapshot/restore de `startConfiguringAdditionalClass()`, así que
/// no hace falta ninguna lógica nueva de cálculo de hechizos conocidos/preparados.
class AdditionalClassSpellsScreen extends StatefulWidget {
  const AdditionalClassSpellsScreen({super.key});

  @override
  State<AdditionalClassSpellsScreen> createState() =>
      _AdditionalClassSpellsScreenState();
}

class _AdditionalClassSpellsScreenState
    extends State<AdditionalClassSpellsScreen> {
  // Mismo motivo que ManageClassScreen (fase 4c): distingue un pop por "Add Class" (ya
  // limpiado por confirmAdditionalClass()) de cualquier otra forma de salir de la pantalla.
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CharacterCreatorViewModel>().prepareAdditionalClassSpellsStep();
    });
  }

  void _onConfirm(CharacterCreatorViewModel vm) {
    _confirmed = true;
    vm.confirmAdditionalClass();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();
    final className = vm.selectedClass?.name ?? 'Class';

    // Multiclase (Aurora_Fixes.md #17, mantenimiento): captura CUALQUIER forma de salir de
    // esta pantalla sin pulsar "Add Class" -- flecha, gesto de retroceso o botón físico
    // incluidos -- para descartar TODA la clase adicional (nivel, subclase y features ya
    // elegidos incluidos). Antes solo la flecha de la AppBar limpiaba la sesión; salir por
    // el gesto del sistema dejaba isConfiguringAdditionalClass atascado en true.
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop || _confirmed) return;
        vm.cancelDanglingAdditionalClass();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text('$className Spells',
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.primary, fontWeight: FontWeight.bold)),
        ),
        body: const StepSpells(),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onConfirm(vm),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text('Add Class',
                    style: GoogleFonts.libreBaskerville(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
