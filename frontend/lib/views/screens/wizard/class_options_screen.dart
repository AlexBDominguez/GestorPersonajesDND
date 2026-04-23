import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../models/wizard/class_option.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'class_detail_screen.dart' show classIcon;

/// Returns the matching [WizardChoiceConfig] for a feature, or null if
/// this feature does not require a wizard choice.
WizardChoiceConfig? _choiceForFeature(
    ClassFeature feature, CharacterCreatorViewModel vm) {
  final name = feature.name.toLowerCase();
  for (final c in vm.classFeatureChoices) {
    if (c.level != feature.level) continue;
    final matches = switch (c.type) {
      'FIGHTING_STYLE'   => name.contains('fighting style'),
      'FAVORED_ENEMY'    => name.contains('favored enemy'),
      'FAVORED_TERRAIN'  => name.contains('natural explorer') ||
                            name.contains('favored terrain'),
      'DRACONIC_ANCESTRY'=> name.contains('draconic ancestry'),
      _                  => false,
    };
    if (matches) return c;
  }
  return null;
}

/// Pantalla donde el usuario configura su clase elegida:
///  - Elige el nivel del personaje
///  - Ve las features que gana hasta ese nivel
///  - Elige la subclase (si procede)
///  - Introduce las tiradas de HP por nivel
class ClassOptionsScreen extends StatefulWidget {
  final ClassOption classOption;
  final List<ClassFeature> features;
  final CharacterCreatorViewModel vm;

  const ClassOptionsScreen({
    super.key,
    required this.classOption,
    required this.features,
    required this.vm,
  });

  @override
  State<ClassOptionsScreen> createState() => _ClassOptionsScreenState();
}

class _ClassOptionsScreenState extends State<ClassOptionsScreen> {
  late int _level;
  // Tiradas de HP por nivel (key = nivel, level 1 no se pide)
  final Map<int, int?> _hpRolls = {};
  // Features expandidas (para ver descripción)
  final Set<int> _expandedFeatures = {};

  ClassOption get cls => widget.classOption;

  @override
  void initState() {
    super.initState();
    _level = widget.vm.selectedLevel;
    _initHpRolls(_level);
    widget.vm.addListener(_onVmChanged);
  }

  void _onVmChanged() => setState(() {});

  @override
  void dispose() {
    widget.vm.removeListener(_onVmChanged);
    super.dispose();
  }

  void _initHpRolls(int level) {
    for (int l = 2; l <= level; l++) {
      _hpRolls.putIfAbsent(l, () => null);
    }
    // Eliminar niveles que quedan por encima del nuevo nivel
    _hpRolls.removeWhere((k, _) => k > level);
  }

  List<ClassFeature> get _featuresUpToLevel =>
      widget.features.where((f) => f.level <= _level).toList()
        ..sort((a, b) => a.level.compareTo(b.level));

  bool get _hpComplete =>
      _level == 1 ||
      _hpRolls.values.every((v) => v != null);

  void _onLevelChanged(int newLevel) {
    setState(() {
      _level = newLevel;
      widget.vm.setLevel(newLevel);
      _initHpRolls(newLevel);
    });
  }

  void _onConfirm() {
    widget.vm.setLevel(_level);
    widget.vm.setHpRolls({...?(_level > 1 ? _hpRolls : null)});
    Navigator.of(context).pop();
  }

  void _onCancel() {
    widget.vm.clearClass();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final icon = classIcon(cls.indexName);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Customize ${cls.name}',
            style: GoogleFonts.cinzel(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onCancel,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de nivel
                  _LevelSelector(
                    cls: cls,
                    icon: icon,
                    level: _level,
                    onChanged: _onLevelChanged,
                  ),
                  const SizedBox(height: 20),

                  // Subclass selector ────────────────────────────────
                  _SubclassSelectorSection(
                    vm: widget.vm,
                    currentLevel: _level,
                  ),

                  // Features ─────────────────────────────────────────
                  _SectionHeader('Class Features'),
                  const SizedBox(height: 8),
                  ..._featuresUpToLevel.map((f) {
                    final choice = _choiceForFeature(f, widget.vm);
                    return _FeatureTile(
                      feature: f,
                      isExpanded: _expandedFeatures.contains(f.id),
                      onToggle: () => setState(() =>
                          _expandedFeatures.contains(f.id)
                              ? _expandedFeatures.remove(f.id)
                              : _expandedFeatures.add(f.id)),
                      choice: choice,
                      currentChoice: choice != null
                          ? widget.vm.featureChoices[choice.key]
                          : null,
                      onChoiceSelected: choice != null
                          ? (value) => widget.vm.setFeatureChoice(choice.key, value)
                          : null,
                    );
                  }),

                  // Subclass features (once subclass selected) ────────
                  if (widget.vm.selectedSubclass != null &&
                      widget.vm.subclassFeatures.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionHeader('${widget.vm.selectedSubclass!.name} Features'),
                    const SizedBox(height: 8),
                    ...widget.vm.subclassFeatures
                        .where((f) => f.level <= _level)
                        .map((f) => _FeatureTile(
                              feature: f,
                              isExpanded: _expandedFeatures.contains(f.id),
                              onToggle: () => setState(() =>
                                  _expandedFeatures.contains(f.id)
                                      ? _expandedFeatures.remove(f.id)
                                      : _expandedFeatures.add(f.id)),
                            )),
                  ],

                  const SizedBox(height: 20),

                  // HP por nivel ─────────────────────────────────────
                  _SectionHeader('Manage HP'),
                  const SizedBox(height: 4),
                  Text(
                    'Level 1 HP is always maximum (${cls.hitDie} + CON modifier).',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  // Level 1 (fijo, solo informativo)
                  _HpRow(
                    level: 1,
                    hitDie: cls.hitDie,
                    value: cls.hitDie,
                    readOnly: true,
                  ),
                  // Niveles 2+
                  if (_level > 1)
                    ...List.generate(_level - 1, (i) {
                      final lvl = i + 2;
                      return _HpRow(
                        level: lvl,
                        hitDie: cls.hitDie,
                        value: _hpRolls[lvl],
                        readOnly: false,
                        onChanged: (v) =>
                            setState(() => _hpRolls[lvl] = v),
                      );
                    }),
                ],
              ),
            ),
          ),

          // Botones
          _BottomButtons(
            canConfirm: _hpComplete && widget.vm.classFeatureChoicesDone,
            onCancel: _onCancel,
            onConfirm: _onConfirm,
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _LevelSelector extends StatelessWidget {
  final ClassOption cls;
  final IconData icon;
  final int level;
  final ValueChanged<int> onChanged;

  const _LevelSelector({
    required this.cls,
    required this.icon,
    required this.level,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary, width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(icon, color: AppTheme.background, size: 22),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cls.name,
                  style: GoogleFonts.cinzel(
                      color: AppTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Hit Die: d${cls.hitDie}',
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Level',
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 11)),
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: level,
                dropdownColor: AppTheme.surface,
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                items: List.generate(
                  20,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1}'),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.cinzel(
          color: AppTheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold));
}

class _FeatureTile extends StatelessWidget {
  final ClassFeature feature;
  final bool isExpanded;
  final VoidCallback onToggle;
  final WizardChoiceConfig? choice;
  final String? currentChoice;
  final ValueChanged<String>? onChoiceSelected;

  const _FeatureTile({
    required this.feature,
    required this.isExpanded,
    required this.onToggle,
    this.choice,
    this.currentChoice,
    this.onChoiceSelected,
  });

  bool get _needsChoice => choice != null;
  bool get _choiceDone  => choice != null && currentChoice != null;

  @override
  Widget build(BuildContext context) {
    final borderColor = _needsChoice && !_choiceDone
        ? AppTheme.accent.withOpacity(0.5)
        : isExpanded
            ? AppTheme.primary.withOpacity(0.4)
            : AppTheme.divider;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isExpanded
            ? AppTheme.primary.withOpacity(0.08)
            : (_needsChoice && !_choiceDone
                ? AppTheme.accent.withOpacity(0.04)
                : AppTheme.surface),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — tappable
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Lv${feature.level}',
                      style: GoogleFonts.cinzel(
                          color: AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(feature.name,
                      style: GoogleFonts.cinzel(
                          color: isExpanded
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ),
                if (_needsChoice) ...[  
                  if (_choiceDone)
                    _ChoiceBadgeDone(text: currentChoice!)
                  else
                    const _ChoiceBadgePending(),
                  const SizedBox(width: 6),
                ],
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ]),
            ),
          ),
          // Expanded content
          if (isExpanded) ...[  
            const Divider(height: 1, color: AppTheme.divider),
            if (_needsChoice)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  children: choice!.options
                      .map((opt) => _InlineOptionTile(
                            label: opt.name,
                            description: opt.description,
                            selected: currentChoice == opt.name,
                            onTap: () => onChoiceSelected?.call(opt.name),
                          ))
                      .toList(),
                ),
              )
            else if (feature.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Text(feature.description,
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceBadgeDone extends StatelessWidget {
  final String text;
  const _ChoiceBadgeDone({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: GoogleFonts.lato(
                color: AppTheme.primary, fontSize: 10)),
      );
}

class _ChoiceBadgePending extends StatelessWidget {
  const _ChoiceBadgePending();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('Choose!',
            style: GoogleFonts.lato(
                color: AppTheme.accent,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      );
}

class _InlineOptionTile extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _InlineOptionTile({
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _HpRow extends StatelessWidget {
  final int level;
  final int hitDie;
  final int? value;
  final bool readOnly;
  final ValueChanged<int?>? onChanged;

  const _HpRow({
    required this.level,
    required this.hitDie,
    required this.value,
    required this.readOnly,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (!readOnly && value == null)
              ? AppTheme.accent.withOpacity(0.5)
              : AppTheme.divider,
        ),
      ),
      child: Row(children: [
        // Badge nivel
        Container(
          width: 60,
          child: Text('Level $level',
              style: GoogleFonts.cinzel(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        // Campo de entrada (o valor fijo)
        Expanded(
          child: readOnly
              ? Row(children: [
                  Text('$value',
                      style: GoogleFonts.cinzel(
                          color: AppTheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Text('(maximum)',
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ])
              : _HpInput(
                  hitDie: hitDie,
                  value: value,
                  onChanged: onChanged,
                ),
        ),
        // Hint del dado
        Text('d$hitDie',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    );
  }
}

class _HpInput extends StatefulWidget {
  final int hitDie;
  final int? value;
  final ValueChanged<int?>? onChanged;

  const _HpInput({
    required this.hitDie,
    required this.value,
    this.onChanged,
  });

  @override
  State<_HpInput> createState() => _HpInputState();
}

class _HpInputState extends State<_HpInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.value != null ? '${widget.value}' : '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: GoogleFonts.cinzel(
            color: AppTheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: '1–${widget.hitDie}',
          hintStyle: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 12),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppTheme.primary),
          ),
        ),
        onChanged: (s) {
          final parsed = int.tryParse(s);
          if (parsed == null) {
            widget.onChanged?.call(null);
          } else {
            final clamped = parsed.clamp(1, widget.hitDie);
            widget.onChanged?.call(clamped);
            if (clamped != parsed) {
              _ctrl.text = '$clamped';
              _ctrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: _ctrl.text.length));
            }
          }
        },
      ),
    );
  }
}

// ── Subclass selector (inline en ClassOptionsScreen) ─────────────────────────

class _SubclassSelectorSection extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  final int currentLevel;

  const _SubclassSelectorSection({
    required this.vm,
    required this.currentLevel,
  });

  // La mayoría de clases reciben subclase a nivel 3 (PHB 2014).
  // Cleric, Druid, Sorcerer, Warlock: nivel 1.
  int get _subclassMinLevel {
    final name = vm.selectedClass?.indexName.toLowerCase() ?? '';
    if (name == 'cleric' || name == 'druid' ||
        name == 'sorcerer' || name == 'warlock') return 1;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    // No muestres si no hay subclases todavía
    if (vm.subclasses.isEmpty) return const SizedBox.shrink();

    final meetsLevel = currentLevel >= _subclassMinLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Subclass (optional)'),
        const SizedBox(height: 6),
        if (!meetsLevel)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'You will be able to choose a subclass at level $_subclassMinLevel.',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Choosing a subclass is optional — you can assign one later.',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
          ...vm.subclasses.map((sub) => _SubclassChip(
                subclass: sub,
                isSelected: vm.selectedSubclass?.id == sub.id,
                onTap: () {
                  if (vm.selectedSubclass?.id == sub.id) {
                    vm.clearSubclass();
                  } else {
                    vm.selectSubclass(sub);
                  }
                },
              )),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _SubclassChip extends StatelessWidget {
  final SubclassOption subclass;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubclassChip({
    required this.subclass,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                width: 1.5,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: AppTheme.background, size: 12)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subclass.name,
                    style: GoogleFonts.cinzel(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                if (subclass.flavor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subclass.flavor,
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _BottomButtons extends StatelessWidget {  final bool canConfirm;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _BottomButtons({
    required this.canConfirm,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.surfaceVariant),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('Cancel',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: canConfirm ? onConfirm : null,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: Text('Add Class',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}
