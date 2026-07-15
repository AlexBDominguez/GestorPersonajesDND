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
              style: GoogleFonts.libreBaskerville(
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
                  Text('All choices resolved!',
                    style: GoogleFonts.libreBaskerville(
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
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
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
                    style: GoogleFonts.libreBaskerville(
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
      case 'EXPERTISE':
        return _ExpertiseResolver(task: task, vm: vm);
      case 'TOOL_PROFICIENCY':
        return _OptionListResolver(
            task: task, vm: vm, options: kDwarfTools);
      case 'CHOOSE_SUBCLASS':
        return _SubclassResolver(task: task, vm: vm);
      case 'ASI_OR_FEAT':
        return _AsiOrFeatResolver(task: task, vm: vm);

      // Battle Master — multi-selección con límite (count en metadata)
      case 'MANEUVER_CHOICE':
        return _MultiPickOptionResolver(
            task: task, vm: vm, options: kBattleMasterManeuvers);

      // Rune Knight — multi-selección con límite (count en metadata), una tarea por hito de
      // nivel (3/7/10/15) igual que Battle Master Maneuvers. Ver #8.2 RESOURCE_POOL.
      case 'RUNE_CHOICE':
        return _MultiPickOptionResolver(
            task: task, vm: vm, options: kRuneOptions);

      // Totem Warrior — una opción por tarea
      case 'TOTEM_SPIRIT':
        return _OptionListResolver(task: task, vm: vm, options: kTotemSpirit);
      case 'TOTEM_ASPECT':
        return _OptionListResolver(task: task, vm: vm, options: kTotemAspect);
      case 'TOTEM_ATTUNEMENT':
        return _OptionListResolver(task: task, vm: vm, options: kTotemicAttunement);

      // Hunter Ranger — una opción por tarea
      case 'HUNTERS_PREY':
        return _OptionListResolver(task: task, vm: vm, options: kHuntersPrey);
      case 'DEFENSIVE_TACTICS':
        return _OptionListResolver(task: task, vm: vm, options: kDefensiveTactics);
      case 'HUNTER_MULTIATTACK':
        return _OptionListResolver(task: task, vm: vm, options: kHunterMultiattack);
      case 'SUPERIOR_HUNTERS_DEFENSE':
        return _OptionListResolver(task: task, vm: vm, options: kSuperiorHuntersDefense);

      // Four Elements Monk — multi-selección con límite (count en metadata)
      case 'ELEMENTAL_DISCIPLINE':
        return _MultiPickOptionResolver(
            task: task, vm: vm, options: kFourElementsDisciplines);

      // Circle of the Land Druid — single land type pick
      case 'LAND_TYPE_CHOICE':
        return _OptionListResolver(task: task, vm: vm, options: kLandTypes);

      // Knowledge Domain Cleric — multi-pick 2 skills with expertise
      case 'KNOWLEDGE_DOMAIN_SKILLS':
        return _MultiPickOptionResolver(
            task: task, vm: vm, options: kKnowledgeDomainSkills);

      // Nature Domain Cleric — pick 1 cantrip
      case 'NATURE_DOMAIN_CANTRIP':
        return _OptionListResolver(task: task, vm: vm, options: kNatureDomainCantrips);

      // College of Lore Bard — multi-pick 3 skills
      case 'LORE_BARD_SKILLS':
        return _MultiPickOptionResolver(task: task, vm: vm, options: kSkills);

      // Battle Master — pick 1 artisan's tool or language
      case 'BATTLE_MASTER_TOOL':
        return _OptionListResolver(task: task, vm: vm, options: kBattleMasterToolOrLanguage);

      // Blood Hunter Order of the Lycan — pick lycanthrope type
      case 'LYCAN_TYPE':
        return _OptionListResolver(task: task, vm: vm, options: kLycanTypes);

      // Blood Hunter Order of the Profane Soul — pick Warlock patron
      case 'PROFANE_SOUL_PATRON':
        return _OptionListResolver(task: task, vm: vm, options: kProfaneSoulPatrons);

      // MoTM flexible ASI — choose +2 to one ability and +1 to another
      case 'RACIAL_ASI_CHOICE':
        return _RacialAsiResolver(task: task, vm: vm);

      // Feat: Resilient — choose any ability for +1 and saving throw proficiency
      case 'RESILIENT_ABILITY':
        return _OptionListResolver(task: task, vm: vm, options: kAllAbilities);

      // Feat: ability +1 choice with options encoded in metadata (str/dex, str/con, int/wis…)
      case 'FEAT_ABILITY_CHOICE':
        return _FeatAbilityChoiceResolver(task: task, vm: vm);

      // Feat: Skilled — multi-pick 3 skills or tools
      case 'SKILLED_CHOICES':
        return _MultiPickOptionResolver(task: task, vm: vm, options: kSkills);

      // Feat: Weapon Master — multi-pick 4 weapons
      case 'WEAPON_MASTER_CHOICES':
        return _MultiPickOptionResolver(task: task, vm: vm, options: kWeaponProficiencies);

      // Feat: Magic Initiate / Ritual Caster / Spell Sniper — choose a spellcasting class
      case 'MAGIC_INITIATE':
      case 'RITUAL_CASTER_CLASS':
      case 'SPELL_SNIPER_CANTRIP':
        return _OptionListResolver(task: task, vm: vm, options: kSpellcastingClasses);

      // Feat: Martial Adept — choose a Battle Master maneuver
      case 'MARTIAL_ADEPT_MANEUVER':
        return _OptionListResolver(task: task, vm: vm, options: kBattleMasterManeuvers);

      // Feat: Elemental Adept — choose an element
      case 'ELEMENTAL_ADEPT_TYPE':
        return _OptionListResolver(task: task, vm: vm, options: kElementalAdeptTypes);

      // Blood Hunter — pick one Blood Curse
      case 'BLOOD_CURSE_CHOICE':
        return _OptionListResolver(task: task, vm: vm, options: kBloodCurses);

      // Gunslinger — pick one Trick Shot
      case 'TRICK_SHOT_CHOICE':
        return _OptionListResolver(task: task, vm: vm, options: kTrickShots);

      // Blood Hunter Order of the Mutant — pick N Mutagenic Formulas (count = INT mod, in metadata)
      case 'MUTAGEN_CHOICE':
        return _MultiPickOptionResolver(task: task, vm: vm, options: kMutagens);

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
                  style: GoogleFonts.libreBaskerville(
                      fontSize: 14, fontWeight: FontWeight.bold)),
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
                  style: GoogleFonts.libreBaskerville(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                      fontSize: 14,
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
                  style: GoogleFonts.libreBaskerville(fontSize: 14, fontWeight: FontWeight.bold)),
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
          fontSize: 14,
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
              fontSize: 14, fontWeight: FontWeight.bold)),
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
          // value = abreviatura ('STR'), no el nombre completo — PendingTaskService.java
          // espera 'ASI:STR:+2' / 'ASI:STR:+1+DEX:+1'; enviar el nombre completo
          // ("Strength") hacía que el backend insertara una clave inválida y la
          // mejora de característica nunca se aplicara.
          items: kAbilityScoreNames
              .where((a) => !exclude.contains(a.description))
              .map((a) => DropdownMenuItem<String>(
                    value: a.description,
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

//---- Resolver para FEAT_ABILITY_CHOICE: muestra las opciones de ability del metadata JSON
// Metadata format: {"options":["str","dex"],"count":1}
class _FeatAbilityChoiceResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _FeatAbilityChoiceResolver({required this.task, required this.vm});

  @override
  State<_FeatAbilityChoiceResolver> createState() => _FeatAbilityChoiceResolverState();
}

class _FeatAbilityChoiceResolverState extends State<_FeatAbilityChoiceResolver> {
  static const _allAbilities = [
    ('str', 'Strength'),
    ('dex', 'Dexterity'),
    ('con', 'Constitution'),
    ('int', 'Intelligence'),
    ('wis', 'Wisdom'),
    ('cha', 'Charisma'),
  ];

  String? _selected;
  bool _saving = false;

  List<(String, String)> get _options {
    try {
      final meta = widget.task.metadata;
      if (meta != null) {
        final match = RegExp(r'"options"\s*:\s*\[([^\]]+)\]').firstMatch(meta);
        if (match != null) {
          final keys = match.group(1)!
              .replaceAll('"', '')
              .split(',')
              .map((s) => s.trim())
              .toList();
          return _allAbilities.where((a) => keys.contains(a.$1)).toList();
        }
      }
    } catch (_) {}
    return _allAbilities.toList();
  }

  @override
  Widget build(BuildContext context) {
    final opts = _options;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Choose +1 to:', style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selected,
          dropdownColor: AppTheme.surface,
          style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.4)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          hint: Text('Choose ability', style: GoogleFonts.lato(color: AppTheme.textSecondary)),
          items: opts.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
          onChanged: (v) => setState(() => _selected = v),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selected != null && !_saving ? _confirm : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('Confirm', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      await widget.vm.resolveTask(widget.task.id, _selected!);
    } finally {
      if (mounted) setState(() => _saving = false);
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
                  style: GoogleFonts.libreBaskerville(
                      fontSize: 14, fontWeight: FontWeight.bold)),
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
                  style: GoogleFonts.libreBaskerville(
                      color: AppTheme.primary,
                      fontSize: 14,
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
                fontSize: 14,
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
                  style: GoogleFonts.libreBaskerville(
                      fontSize: 14, fontWeight: FontWeight.bold)),
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
                  fontSize: 14,
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
                      style: GoogleFonts.libreBaskerville(fontSize: 14, fontWeight: FontWeight.bold)),
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

// ── Multi-pick resolver — elige N opciones de una lista (Battle Master, Four Elements, etc.) ──

class _MultiPickOptionResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  final List<DndChoiceOption> options;
  const _MultiPickOptionResolver(
      {required this.task, required this.vm, required this.options});

  @override
  State<_MultiPickOptionResolver> createState() => _MultiPickOptionResolverState();
}

class _MultiPickOptionResolverState extends State<_MultiPickOptionResolver> {
  final Set<String> _selected = {};
  bool _saving = false;

  int get _maxPicks {
    try {
      final meta = widget.task.metadata;
      if (meta != null && meta.contains('"count"')) {
        final match = RegExp(r'"count"\s*:\s*(\d+)').firstMatch(meta);
        if (match != null) return int.parse(match.group(1)!);
      }
    } catch (_) {}
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final max = _maxPicks;
    final remaining = max - _selected.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Choose $max option${max == 1 ? '' : 's'}.${remaining > 0 ? '  ($remaining remaining)' : ''}',
        style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 14),
      ),
      const SizedBox(height: 10),
      ...widget.options.map((opt) {
        final isSelected = _selected.contains(opt.name);
        final isDisabled = !isSelected && remaining == 0;
        return GestureDetector(
          onTap: isDisabled
              ? null
              : () => setState(() {
                    if (isSelected) _selected.remove(opt.name);
                    else _selected.add(opt.name);
                  }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.12)
                  : isDisabled
                      ? AppTheme.surfaceVariant.withOpacity(0.2)
                      : AppTheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 16,
                color: isSelected
                    ? AppTheme.primary
                    : isDisabled
                        ? AppTheme.textSecondary.withOpacity(0.3)
                        : AppTheme.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(opt.name,
                      style: GoogleFonts.libreBaskerville(
                          color: isSelected
                              ? AppTheme.primary
                              : isDisabled
                                  ? AppTheme.textSecondary.withOpacity(0.4)
                                  : AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  if (opt.description.isNotEmpty)
                    Text(opt.description,
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary.withOpacity(0.7),
                            fontSize: 10,
                            height: 1.4)),
                ]),
              ),
            ]),
          ),
        );
      }),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selected.length < max || _saving ? null : () => _confirm(context),
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
                  remaining > 0
                      ? 'Select $remaining more'
                      : 'Confirm (${_selected.length})',
                  style: GoogleFonts.libreBaskerville(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  Future<void> _confirm(BuildContext context) async {
    setState(() => _saving = true);
    final choice = _selected.join(',');
    final ok = await widget.vm.resolveTask(widget.task.id, choice);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.task.displayName}: ${_selected.join(', ')} confirmed!'),
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

// ── Expertise resolver (multi-pick: 2 proficient skills) ──────────────────────

class _ExpertiseResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _ExpertiseResolver({required this.task, required this.vm});

  @override
  State<_ExpertiseResolver> createState() => _ExpertiseResolverState();
}

class _ExpertiseResolverState extends State<_ExpertiseResolver> {
  final Set<String> _selected = {};
  bool _saving = false;
  static const int _maxPicks = 2;

  List<DndChoiceOption> get _eligibleSkills => kSkills.where((opt) =>
      widget.vm.skillProficient(opt.name) &&
      !widget.vm.skillExpertise(opt.name)).toList();

  @override
  Widget build(BuildContext context) {
    final skills = _eligibleSkills;
    final remaining = _maxPicks - _selected.length;

    if (skills.isEmpty) {
      return Text(
        'No eligible skills found. You need proficiency in a skill before gaining expertise.',
        style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 14, fontStyle: FontStyle.italic),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Choose 2 skills you are proficient in to double your proficiency bonus.${
          remaining > 0 ? '  ($remaining remaining)' : ''}',
        style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 14),
      ),
      const SizedBox(height: 10),
      ...skills.map((opt) {
        final isSelected = _selected.contains(opt.name);
        final isDisabled = !isSelected && remaining == 0;
        return GestureDetector(
          onTap: isDisabled ? null : () => setState(() {
            if (isSelected) _selected.remove(opt.name);
            else _selected.add(opt.name);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.12)
                  : isDisabled
                      ? AppTheme.surfaceVariant.withOpacity(0.2)
                      : AppTheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: isSelected
                    ? AppTheme.primary
                    : isDisabled
                        ? AppTheme.textSecondary.withOpacity(0.3)
                        : AppTheme.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(opt.name,
                    style: GoogleFonts.lato(
                        color: isSelected
                            ? AppTheme.primary
                            : isDisabled
                                ? AppTheme.textSecondary.withOpacity(0.4)
                                : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
              Text(opt.description,
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary.withOpacity(0.6), fontSize: 10)),
            ]),
          ),
        );
      }),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selected.length < _maxPicks || _saving ? null : () => _confirm(context),
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
                  _selected.length < _maxPicks
                      ? 'Select ${remaining} more skill${remaining == 1 ? '' : 's'}'
                      : 'Confirm: ${_selected.join(', ')}',
                  style: GoogleFonts.libreBaskerville(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    ]);
  }

  Future<void> _confirm(BuildContext context) async {
    setState(() => _saving = true);
    final choice = _selected.join(',');
    final ok = await widget.vm.resolveTask(widget.task.id, choice);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Expertise granted: ${_selected.join(', ')}!'),
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

// ── MoTM Flexible ASI resolver ────────────────────────────────────────────────
// Player picks which ability gets +2 and which gets +1 (must be different).
class _RacialAsiResolver extends StatefulWidget {
  final PendingTask task;
  final CharacterSheetViewModel vm;
  const _RacialAsiResolver({required this.task, required this.vm});

  @override
  State<_RacialAsiResolver> createState() => _RacialAsiResolverState();
}

class _RacialAsiResolverState extends State<_RacialAsiResolver> {
  static const _abilities = [
    ('str', 'Strength'),
    ('dex', 'Dexterity'),
    ('con', 'Constitution'),
    ('int', 'Intelligence'),
    ('wis', 'Wisdom'),
    ('cha', 'Charisma'),
  ];

  String? _plus2;
  String? _plus1;
  bool _saving = false;

  bool get _valid => _plus2 != null && _plus1 != null && _plus2 != _plus1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Apply +2 to:', style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _plus2,
          dropdownColor: AppTheme.surface,
          style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.4)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          hint: Text('Choose ability', style: GoogleFonts.lato(color: AppTheme.textSecondary)),
          items: _abilities.map((e) => DropdownMenuItem(
            value: e.$1,
            child: Text(e.$2),
          )).toList(),
          onChanged: (v) => setState(() => _plus2 = v),
        ),
        const SizedBox(height: 16),
        Text('Apply +1 to:', style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _plus1,
          dropdownColor: AppTheme.surface,
          style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.4)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          hint: Text('Choose ability', style: GoogleFonts.lato(color: AppTheme.textSecondary)),
          items: _abilities
              .where((e) => e.$1 != _plus2)
              .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)))
              .toList(),
          onChanged: (v) => setState(() => _plus1 = v),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _valid && !_saving ? () => _confirm(context) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            disabledBackgroundColor: AppTheme.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _saving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _valid
                      ? 'Confirm: ${_abilityName(_plus2!)} +2, ${_abilityName(_plus1!)} +1'
                      : 'Select two different abilities',
                  style: GoogleFonts.libreBaskerville(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  String _abilityName(String key) =>
      _abilities.firstWhere((e) => e.$1 == key, orElse: () => (key, key)).$2;

  Future<void> _confirm(BuildContext context) async {
    setState(() => _saving = true);
    final choice = '${_plus2!}:2,${_plus1!}:1';
    final ok = await widget.vm.resolveTask(widget.task.id, choice);
    if (!context.mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_abilityName(_plus2!)} +2, ${_abilityName(_plus1!)} +1 applied!'),
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

