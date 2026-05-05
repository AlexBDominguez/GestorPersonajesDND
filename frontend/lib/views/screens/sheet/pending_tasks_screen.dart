import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/config/dnd_choice_options.dart';
import 'package:gestor_personajes_dnd/models/character/pending_task.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
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
      case 'EXTRA_LANGUAGE':
        return _OptionListResolver(
            task: task, vm: vm, options: kLanguages);
      case 'HIGH_ELF_CANTRIP':
        return _OptionListResolver(
            task: task, vm: vm, options: kWizardCantrips);
      case 'SKILL_VERSATILITY_1':
      case 'SKILL_VERSATILITY_2':
        return _SkillVersatilityResolver(task: task, vm: vm);
      case 'TOOL_PROFICIENCY':
        return _OptionListResolver(
            task: task, vm: vm, options: kDwarfTools);
      case 'CHOOSE_SUBCLASS':
        return _SubclassResolver(task: task, vm: vm);
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
  // Stage 1: top-level choice
  String? _topChoice; // 'ASI' or 'FEAT'

  // Stage 2a – ASI sub-option
  String? _asiMode; // '+2' or '+1+1'
  String? _asiAbility1;
  String? _asiAbility2;

  // Stage 2b – Feat selection
  String? _selectedFeat;

  bool _saving = false;

  String? get _confirmValue {
    if (_topChoice == 'ASI') {
      if (_asiMode == '+2' && _asiAbility1 != null) {
        return 'ASI:$_asiAbility1:+2';
      }
      if (_asiMode == '+1+1' && _asiAbility1 != null && _asiAbility2 != null && _asiAbility1 != _asiAbility2) {
        return 'ASI:$_asiAbility1:+1+$_asiAbility2:+1';
      }
      return null;
    }
    if (_topChoice == 'FEAT' && _selectedFeat != null) {
      return 'FEAT:$_selectedFeat';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Top-level choice ─────────────────────────────────────────
      _OptionTile(
        label: 'Ability Score Improvement',
        description: '+2 to one ability score, or +1 to two different ability scores.',
        selected: _topChoice == 'ASI',
        onTap: () => setState(() { _topChoice = 'ASI'; _selectedFeat = null; }),
      ),
      _OptionTile(
        label: 'Take a Feat',
        description: 'Choose a feat from the available list.',
        selected: _topChoice == 'FEAT',
        onTap: () => setState(() { _topChoice = 'FEAT'; _asiMode = null; _asiAbility1 = null; _asiAbility2 = null; }),
      ),

      // ── ASI sub-pickers ──────────────────────────────────────────
      if (_topChoice == 'ASI') ...[
        const SizedBox(height: 10),
        _SubSectionLabel('How to apply the +2?'),
        const SizedBox(height: 6),
        _AsiModeChip(label: '+2 to one ability', selected: _asiMode == '+2',
            onTap: () => setState(() { _asiMode = '+2'; _asiAbility2 = null; })),
        const SizedBox(height: 4),
        _AsiModeChip(label: '+1 to two different abilities', selected: _asiMode == '+1+1',
            onTap: () => setState(() => _asiMode = '+1+1')),
        if (_asiMode != null) ...[
          const SizedBox(height: 10),
          _SubSectionLabel(_asiMode == '+2' ? 'Choose ability (+2):' : 'First ability (+1):'),
          const SizedBox(height: 6),
          _AbilityDropdown(
            value: _asiAbility1,
            onChanged: (v) => setState(() => _asiAbility1 = v),
            exclude: _asiMode == '+1+1' ? {_asiAbility2} : {},
          ),
          if (_asiMode == '+1+1') ...[
            const SizedBox(height: 8),
            _SubSectionLabel('Second ability (+1):'),
            const SizedBox(height: 6),
            _AbilityDropdown(
              value: _asiAbility2,
              onChanged: (v) => setState(() => _asiAbility2 = v),
              exclude: {_asiAbility1},
            ),
          ],
        ],
      ],

      // ── Feat list ────────────────────────────────────────────────
      if (_topChoice == 'FEAT') ...[
        const SizedBox(height: 10),
        _SubSectionLabel('Choose a feat:'),
        const SizedBox(height: 6),
        ...kFeats.map((f) => _OptionTile(
              label: f.name,
              description: f.description,
              selected: _selectedFeat == f.name,
              onTap: () => setState(() => _selectedFeat = f.name),
            )),
      ],

      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _confirmValue == null || _saving ? null : () => _confirm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.surfaceVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _saving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _confirmValue == null ? 'Complete your selection above' : 'Confirm',
                  style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  Future<void> _confirm(BuildContext context) async {
    setState(() => _saving = true);
    final ok = await widget.vm.resolveTask(widget.task.id, _confirmValue!);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.task.displayName}: confirmed!'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving choice. Try again.'),
        backgroundColor: AppTheme.accent,
      ));
    }
  }
}

// ── Small sub-section label ────────────────────────────────────────────────────
class _SubSectionLabel extends StatelessWidget {
  final String text;
  const _SubSectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.lato(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold));
}

// ── ASI mode chip ─────────────────────────────────────────────────────────────
class _AsiModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AsiModeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? AppTheme.primary : Colors.transparent, width: 1.5),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 16, height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.textSecondary, width: 2),
            ),
            child: selected ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.lato(
              color: selected ? AppTheme.primary : AppTheme.textPrimary,
              fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

// ── Ability dropdown ──────────────────────────────────────────────────────────
class _AbilityDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final Set<String?> exclude;
  const _AbilityDropdown({required this.value, required this.onChanged, this.exclude = const {}});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          value: value,
          hint: Text('Select ability…',
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
          items: kAbilityScoreNames
              .where((a) => !exclude.contains(a.name))
              .map((a) => DropdownMenuItem<String>(
                    value: a.name,
                    child: Text(a.name,
                        style: GoogleFonts.lato(
                            color: AppTheme.textPrimary, fontSize: 13)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
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

// ── Skill Versatility resolver — filters out already-proficient skills ─────────

class _SkillVersatilityResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _SkillVersatilityResolver({required this.task, required this.vm});

  @override
  State<_SkillVersatilityResolver> createState() =>
      _SkillVersatilityResolverState();
}

class _SkillVersatilityResolverState
    extends State<_SkillVersatilityResolver> {
  String? _selected;
  bool _saving = false;
  bool _collapsed = false;

  List<DndChoiceOption> get _availableSkills {
    return kSkills.where((opt) {
      // Exclude skills already proficient (including background) and those with expertise
      final already = widget.vm.skillProficient(opt.name) ||
          widget.vm.skillExpertise(opt.name);
      return !already;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final skills = _availableSkills;

    if (_collapsed && _selected != null) {
      // Show selected chip only
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_selected!,
                  style: GoogleFonts.cinzel(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () => setState(() { _collapsed = false; }),
              child: const Icon(Icons.edit, color: AppTheme.textSecondary, size: 14),
            ),
          ]),
        ),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (skills.isEmpty)
        Text('All skills are already proficient.',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontStyle: FontStyle.italic))
      else
        ...skills.map((opt) => _OptionTile(
              label: opt.name,
              description: opt.description,
              selected: _selected == opt.name,
              onTap: () => setState(() {
                _selected = opt.name;
                _collapsed = true;
              }),
            )),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selected == null || _saving ? null : () => _confirm(context),
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
              : Text(_selected == null ? 'Select a skill above' : 'Confirm: $_selected',
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving choice. Try again.'),
        backgroundColor: AppTheme.accent,
      ));
    }
  }
}

// ── Subclass resolver ─────────────────────────────────────────────────────────

class _SubclassResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _SubclassResolver({required this.task, required this.vm});

  @override
  State<_SubclassResolver> createState() => _SubclassResolverState();
}

class _SubclassResolverState extends State<_SubclassResolver> {
  late Future<List<SubclassOption>> _future;
  String? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = widget.vm.loadSubclassOptions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubclassOption>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }
        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return Text('Could not load subclasses. Try again later.',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic));
        }
        final subclasses = snap.data!;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...subclasses.map((sc) => _OptionTile(
                label: sc.name,
                description: sc.description.isNotEmpty ? sc.description : sc.flavor,
                selected: _selected == sc.name,
                onTap: () => setState(() => _selected = sc.name),
              )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected == null || _saving ? null : () => _confirm(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.surfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _selected == null ? 'Select a subclass above' : 'Confirm: $_selected',
                      style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ]);
      },
    );
  }

  Future<void> _confirm(BuildContext context) async {
    setState(() => _saving = true);
    final ok = await widget.vm.resolveTask(widget.task.id, _selected!);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Subclass chosen: $_selected!'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 2),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error saving choice. Try again.'),
        backgroundColor: AppTheme.accent,
      ));
    }
  }
}
