import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../models/wizard/class_option.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'class_detail_screen.dart' show classIcon;

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
    // Guardar tiradas de HP en el ViewModel
    widget.vm.setHpRolls({...?(_level > 1 ? _hpRolls : null)});
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onCancel() {
    // Desseleccionar clase y volver a la lista
    widget.vm.clearClass();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final icon = classIcon(cls.indexName);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Configure ${cls.name}',
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

                  // Features ─────────────────────────────────────────
                  _SectionHeader('Class Features'),
                  const SizedBox(height: 8),
                  ..._featuresUpToLevel.map((f) => _FeatureTile(
                        feature: f,
                        isExpanded: _expandedFeatures.contains(f.id),
                        onToggle: () => setState(() =>
                            _expandedFeatures.contains(f.id)
                                ? _expandedFeatures.remove(f.id)
                                : _expandedFeatures.add(f.id)),
                      )),

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
            canConfirm: _hpComplete,
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

  const _FeatureTile({
    required this.feature,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isExpanded
              ? AppTheme.primary.withOpacity(0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isExpanded
                ? AppTheme.primary.withOpacity(0.4)
                : AppTheme.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                // Badge de nivel
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ]),
            ),
            if (isExpanded && feature.description.isNotEmpty) ...[
              const Divider(height: 1, color: AppTheme.divider),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Text(feature.description,
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
            ],
          ],
        ),
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

class _BottomButtons extends StatelessWidget {
  final bool canConfirm;
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
            child: Text('Add',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }
}
