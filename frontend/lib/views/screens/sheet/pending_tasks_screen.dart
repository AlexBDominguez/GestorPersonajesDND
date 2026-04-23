import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/config/dnd_choice_options.dart';
import 'package:gestor_personajes_dnd/models/character/pending_task.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';


// ---- Entry Point
class PendingTasksScreen extends StatelessWidget {
  final CharacterSheetViewModel vm;
  const PendingTasksScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
          backgroundColor: AppTheme.background,
          leading: const BackButton(color: AppTheme.textPrimary),
          title: Text('Pending Choices',
              style: GoogleFonts.cinzel(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
          centerTitle: true
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (_, __) {
            final tasks = vm.pendingTasks;
            if (tasks.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_outline,
                    color: AppTheme.primary, size: 52),
                  const SizedBox(height: 16),
                  Text('All chocies resolved!',
                    style: GoogleFonts.cinzel(
                      color: AppTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Your character sheet is complete.',
                    style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 13)),
                ]),
        );
      }
      return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _TaskCard(task: tasks[i], vm: vm),
          );
        },
      ),
    );
  }
}

// ---- Task card
class _TaskCard extends StatelessWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _TaskCard({required this.task, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),              
            ),
            child: Row(children: [
              Text(task.icon,
                style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task.displayName,
                    style: GoogleFonts.cinzel(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
                  Text('Level ${task.relatedLevel}',
                    style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 10)),
                ]),
              ),
            ]),
          ),
          //Description
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
            child: _TaskResolver(task: task, vm: vm),
          ),
        ]),
    );
  }
}

//--Resolver por tipo
class _TaskResolver extends StatelessWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _TaskResolver({required this.task, required this.vm});

  @override
  Widget build(BuildContext context) {
    switch (task.taskType) {
      case 'FIGHTING_STYLE':
        return _OptionListResolver(
            task: task, vm: vm, options: kFightingStyles);
      case 'FAVORED_ENEMY':
        return _OptionListResolver(
            task: task, vm: vm, options: kFavoredEnemies);
      case 'FAVORED_TERRAIN':
        return _OptionListResolver(
            task: task, vm: vm, options: kFavoredTerrains);
      case 'DRACONIC_ANCESTRY':
        return _OptionListResolver(
            task: task, vm: vm, options: kDraconicAncestries);
      case 'ASI_OR_FEAT':
        return _AsiOrFeatResolver(task: task, vm: vm);
      default:
        // Fallback: campo de texto libre para tipos no mapeados todavía
        return _FreeTextResolver(task: task, vm: vm);
    }
  }
}

//--Resolver con lista de opciones
class _OptionListResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  final List<DndChoiceOption> options;
  const _OptionListResolver(
      {required this.task, required this.vm, required this.options});

  @override
  State<_OptionListResolver> createState() => _OptionListResolverState();
}

class _OptionListResolverState extends State<_OptionListResolver> {
  String? _selected;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...widget.options.map((opt) => _OptionTile(
            label: opt.name,
            description: opt.description,
            selected: _selected == opt.name,
            onTap: () => setState(() => _selected = opt.name),
          )),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selected == null || _saving
              ? null
              : () => _confirm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.surfaceVariant,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _saving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(_selected == null ? 'Select an option above' : 'Confirm: $_selected',
                  style: GoogleFonts.cinzel(
                      fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  Future<void> _confirm(BuildContext context) async {
    setState(() => _saving = true);
    final ok = await widget.vm.resolveTask(widget.task.id, _selected!);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.task.displayName}: $_selected confirmed!'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Error saving choice. Try again.'),
        backgroundColor: AppTheme.accent,
      ));
    }
  }
}


// --- Tile de opción individual
class _OptionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                width: 2,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.cinzel(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(description,
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      height: 1.4)),
            ]),
          ),
        ]),
      ),
    );
  }
}


// ---- Resolver ASI o Feat
class _AsiOrFeatResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _AsiOrFeatResolver({required this.task, required this.vm});

  @override
  State<_AsiOrFeatResolver> createState() => _AsiOrFeatResolverState();
}

class _AsiOrFeatResolverState extends State<_AsiOrFeatResolver> {
  String? _choice; // "ASI" or "FEAT"
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _OptionTile(
        label: 'Ability Score Improvement',
        description: '+2 to one ability score, or +1 to two different ability scores.',
        selected: _choice == 'ASI',
        onTap: () => setState(() => _choice = 'ASI'),
      ),
      _OptionTile(
        label: 'Take a Feat',
        description: 'Choose a feat from the available list (feat selection coming soon).',
        selected: _choice == 'FEAT',
        onTap: () => setState(() => _choice = 'FEAT'),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _choice == null || _saving
              ? null
              : () => _confirm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.surfaceVariant,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _saving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text('Confirm: $_choice',
                  style: GoogleFonts.cinzel(
                      fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
      if (_choice == 'ASI')
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline,
                  color: AppTheme.textSecondary, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You can apply the +2 / +1+1 bonus in the Abilities tab. The choice will be recorded.',
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ]),
          ),
        ),
    ]);
  }

  Future<void> _confirm(BuildContext context) async {
    setState(() => _saving = true);
    final ok = await widget.vm.resolveTask(widget.task.id, _choice!);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.task.displayName}: $_choice confirmed!'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ));
    }
  }
}

//---- Resolver texto libre (fallback)
class _FreeTextResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _FreeTextResolver({required this.task, required this.vm});

  @override
  State<_FreeTextResolver> createState() => _FreeTextResolverState();
}

class _FreeTextResolverState extends State<_FreeTextResolver> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: _ctrl,
        style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Enter your choice...',
          hintStyle: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 13),
          filled: true,
          fillColor: AppTheme.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saving ? null : () => _confirm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _saving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text('Confirm',
                  style: GoogleFonts.cinzel(
                      fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  Future<void> _confirm(BuildContext context) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    final ok = await widget.vm.resolveTask(widget.task.id, text);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.task.displayName}: confirmed!'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ));
    }
  }
}


