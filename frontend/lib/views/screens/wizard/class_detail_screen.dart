import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';
import '../../../models/wizard/class_option.dart';
import '../../../viewmodels/wizard/character_creator_viewmodel.dart';
import 'class_options_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

final Map<String, IconData> kClassIcons = {
  'barbarian': MdiIcons.axeBattle,          // Hacha de batalla (¡esto es un bárbaro!)
  'bard':       MdiIcons.musicClefTreble,    
  'cleric':     MdiIcons.cross,              // Cruz clásica (o 'clover' para algo místico)
  'druid':      MdiIcons.leaf,               // Hoja natural
  'fighter':    MdiIcons.sword,              // ¡LA ESPADA! (por fin)
  'monk':       MdiIcons.yinYang,         
  'paladin':    MdiIcons.shieldSword,        // Escudo y espada combinados
  'ranger':     MdiIcons.bowArrow,           // Arco y flecha
  'rogue':      MdiIcons.knifeMilitary,      // Una daga militar (mucho más "pícaro")
  'sorcerer':   MdiIcons.fire,               // Poder innato de fuego
  'warlock':    MdiIcons.skull,              // Calavera (pacto oscuro)
  'wizard':     MdiIcons.autoFix,            // Varita mágica con destellos
};

IconData classIcon(String indexName) =>
    kClassIcons[indexName.toLowerCase()] ?? MdiIcons.diceD6;

/// Pantalla de detalle de una clase. Muestra toda la información de la clase
/// antes de que el usuario decida añadirla o cancelar.
class ClassDetailScreen extends StatefulWidget {
  final ClassOption classOption;
  final List<ClassFeature> features;
  final CharacterCreatorViewModel vm;

  const ClassDetailScreen({
    super.key,
    required this.classOption,
    required this.features,
    required this.vm,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  // Qué features están expandidas
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final cls = widget.classOption;
    final icon = classIcon(cls.indexName);

    // Agrupar features por nivel
    final Map<int, List<ClassFeature>> byLevel = {};
    for (final f in widget.features) {
      byLevel.putIfAbsent(f.level, () => []).add(f);
    }
    final sortedLevels = byLevel.keys.toList()..sort();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(cls.name,
            style: GoogleFonts.cinzel(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                  // Header con icono y datos básicos
                  _ClassHeader(cls: cls, icon: icon),
                  const SizedBox(height: 20),

                  // Descripción
                  if (cls.description.isNotEmpty) ...[
                    Text(cls.description,
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 20),
                  ],

                  // Proficiencies
                  if (cls.proficiencies.isNotEmpty) ...[
                    _SectionTitle('Proficiencies'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: cls.proficiencies
                          .map((p) => _Chip(p))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Features por nivel
                  _SectionTitle('Class Features (Levels 1–20)'),
                  const SizedBox(height: 8),
                  if (widget.features.isEmpty)
                    Text('No features loaded.',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 13))
                  else
                    ...sortedLevels.map((level) {
                      final levelFeatures = byLevel[level]!;
                      return _LevelSection(
                        level: level,
                        features: levelFeatures,
                        expanded: _expanded,
                        onToggle: (id) =>
                            setState(() => _expanded.contains(id)
                                ? _expanded.remove(id)
                                : _expanded.add(id)),
                      );
                    }),
                ],
              ),
            ),
          ),

          // Botones inferiores
          _BottomButtons(
            onCancel: () => Navigator.of(context).pop(),
            onAdd: () {
              widget.vm.selectClass(cls);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ClassOptionsScreen(
                    classOption: cls,
                    features: widget.features,
                    vm: widget.vm,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _ClassHeader extends StatelessWidget {
  final ClassOption cls;
  final IconData icon;
  const _ClassHeader({required this.cls, required this.icon});

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
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(icon, color: AppTheme.background, size: 26),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cls.name,
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(children: [
              _StatBadge(label: 'Hit Die', value: 'd${cls.hitDie}'),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: '$label: ',
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 12)),
            TextSpan(
                text: value,
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: GoogleFonts.cinzel(
          color: AppTheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold));
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: GoogleFonts.lato(
                color: AppTheme.textPrimary, fontSize: 11)),
      );
}

class _LevelSection extends StatelessWidget {
  final int level;
  final List<ClassFeature> features;
  final Set<int> expanded;
  final void Function(int id) onToggle;

  const _LevelSection({
    required this.level,
    required this.features,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Level $level',
                  style: GoogleFonts.cinzel(
                      color: AppTheme.background,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        ...features.map((f) => _FeatureTile(
              feature: f,
              isExpanded: expanded.contains(f.id),
              onToggle: () => onToggle(f.id),
            )),
      ],
    );
  }
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
            color:
                isExpanded ? AppTheme.primary.withOpacity(0.4) : AppTheme.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
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

class _BottomButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const _BottomButtons({required this.onCancel, required this.onAdd});

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
            onPressed: onAdd,
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
