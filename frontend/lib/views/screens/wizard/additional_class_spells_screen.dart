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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CharacterCreatorViewModel>().prepareAdditionalClassSpellsStep();
    });
  }

  void _onCancel(CharacterCreatorViewModel vm) {
    // Descarta TODA la clase adicional (nivel, subclase, features ya elegidos incluidos)
    // -- ClassOptionsScreen ya no está en la pila de navegación para volver a ella, mismo
    // criterio que _onCancel() allí.
    vm.cancelDanglingAdditionalClass();
    Navigator.of(context).pop();
  }

  void _onConfirm(CharacterCreatorViewModel vm) {
    vm.confirmAdditionalClass();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();
    final className = vm.selectedClass?.name ?? 'Class';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('$className Spells',
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onCancel(vm),
        ),
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
    );
  }
}
