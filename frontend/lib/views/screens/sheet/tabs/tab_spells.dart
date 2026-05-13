import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/l10n/app_strings.dart';
import 'package:gestor_personajes_dnd/l10n/dnd_terms.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

// Column widths shared between level header and spell rows
const double _kHitDcW  = 62.0;
const double _kDmgW    = 80.0;
const double _kColGap  =  8.0;
const double _kCastPad = 10.0;
const double _kCastW   = 78.0;

String _tr(BuildContext context, {required String en, required String es, required String gl}) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'es') return es;
  if (code == 'gl') return gl;
  return en;
}

String _spellLevelName(BuildContext context, int level) {
  if (level == 0) {
    return _tr(context, en: 'Cantrips', es: 'Trucos', gl: 'Trucos');
  }
  final ord = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th'];
  final idx = level - 1;
  if (idx >= 0 && idx < ord.length) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'es') return '${idx + 1}o Nivel';
    if (code == 'gl') return '${idx + 1}o Nivel';
    return '${ord[idx]} Level';
  }
  return _tr(context, en: 'Level $level', es: 'Nivel $level', gl: 'Nivel $level');
}

String _spellDetailLabel(BuildContext context, String key) {
  switch (key) {
    case 'castingTime':
      return _tr(context, en: 'Casting Time', es: 'Tiempo de lanzamiento', gl: 'Tempo de lanzamento');
    case 'range':
      return _tr(context, en: 'Range', es: 'Alcance', gl: 'Alcance');
    case 'duration':
      return _tr(context, en: 'Duration', es: 'Duracion', gl: 'Duracion');
    case 'components':
      return _tr(context, en: 'Components', es: 'Componentes', gl: 'Componentes');
    case 'status':
      return _tr(context, en: 'Status', es: 'Estado', gl: 'Estado');
    case 'description':
      return _tr(context, en: 'Description', es: 'Descripcion', gl: 'Descricion');
    default:
      return key;
  }
}

String _spellSourceLabel(BuildContext context, String? source) {
  switch (source?.toUpperCase()) {
    case 'RACE':
      return _tr(context, en: 'Racial', es: 'Racial', gl: 'Racial');
    case 'FEAT':
      return _tr(context, en: 'Feat', es: 'Dote', gl: 'Dote');
    case 'SUBCLASS':
      return _tr(context, en: 'Subclass', es: 'Subclase', gl: 'Subclase');
    default:
      return _tr(context, en: 'Class', es: 'Clase', gl: 'Clase');
  }
}

class TabSpells extends StatelessWidget{
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabSpells({super.key, required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    final spells = character.characterSpells;

    //Agrupa spells por nivel
    final Map<int, List<CharacterSpell>> byLevel = {};
    for (final s in spells) {
      byLevel.putIfAbsent(s.level, () => []).add(s);
    }
    final sortedLevels = byLevel.keys.toList()..sort();

    return Column(children: [
      // - 1. Spell Stats Header
      _SpellStatsHeader(character: character, vm: vm),

      // - 2. Botón Manage Spells
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ManageSpellsScreen(
                character: character,
                vm: vm,
              ),
            )),
            icon: const Icon(Icons.library_books_outlined, size: 16),
            label: Text(AppStrings.of(context).manageSpells),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      const SizedBox(height: 1),
      
      // - 3. Lista por nivel
      Expanded(
        child: spells.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: sortedLevels.length,
              itemBuilder: (_, i) {
                final level = sortedLevels[i];
                final levelSpells = byLevel[level]!;
                return _SpellLevelSection(
                  level: level,
                  spells: levelSpells,
                  vm: vm,
                );
              },
          ),
      ),
    ]);
  }
}

// - 1. Spell Stats Header
class _SpellStatsHeader extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const _SpellStatsHeader({required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    final c = character;

    return Container(
      color: AppTheme.surfaceVariant.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatPill(
            label: AppStrings.of(context).saveDC,
            value: '${c.spellSaveDC}',
          ),
          _VertDivider(),
          _StatPill(
            label: AppStrings.of(context).attack,
            value: vm.signedInt(c.spellAttackBonus),
          ),
          if (!vm.alwaysPreparedClass) ...[
            _VertDivider(),
            _StatPill(
              label: AppStrings.of(context).prepared,
              value: '${c.characterSpells.where((s) => s.prepared && !s.isCantrip).length}/${c.maxPreparedSpells}',
            ),
          ],
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
        ],
      );
}

// 3. Sección por nivel
class _SpellLevelSection extends StatelessWidget {
  final int level;
  final List<CharacterSpell> spells;
  final CharacterSheetViewModel vm;
  const _SpellLevelSection({
    required this.level,
    required this.spells,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final maxSl = vm.maxSlots(level);
    final usedSl = vm.usedSlots(level);
    final isCantrip = level == 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 12),

      // A. Level name + slot tracker + divider (separate from column headers to prevent overflow)
      Row(children: [
        Text(_spellLevelName(context, level),
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        if (!isCantrip && maxSl > 0) ...[
          const SizedBox(width: 8),
          _SlotTracker(used: usedSl, max: maxSl, level: level, vm: vm),
        ],
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
      ]),

      // B. Column headers row (aligned with spell row columns, no slot tracker competition)
      if (!isCantrip) ...[
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(children: [
            const Expanded(child: SizedBox.shrink()),
            const SizedBox(width: _kColGap),
            SizedBox(
              width: _kHitDcW,
              child: Text('HIT / DC',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: _kColGap),
            SizedBox(
              width: _kDmgW,
              child: Text(_tr(context, en: 'DAMAGE', es: 'DAÑO', gl: 'DANO'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: _kCastPad + _kCastW),
          ]),
        ),
      ],
      const SizedBox(height: 4),

      // C. Filas de hechizos
      ...spells.map((spell) => _SpellRow(
            spell: spell,
            vm: vm,
            level: level,            
      )),
      const SizedBox(height: 4),
    ]);
  }
}

// Slot Tracker (interactivo: si haces tap cambia de lleno (usado) a vacío (disponible))
class _SlotTracker extends StatelessWidget {
  final int used;
  final int max;
  final int level;
  final CharacterSheetViewModel vm;
  const _SlotTracker({
    required this.used,
    required this.max,
    required this.level,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(max, (i) {
      final isFull = i < used;
      return GestureDetector(
        onTap: () async {
          if (isFull) {
            await vm.restoreSpellSlot(level);
          } else {
            await vm.castSpell(level);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Icon(
            isFull ? Icons.check_box : Icons.check_box_outline_blank,
            color: isFull ? AppTheme.accent : AppTheme.textSecondary,
            size: 16,
          ),
        ),
      );
    }),
  );
}


// - Spell Row
class _SpellRow extends StatelessWidget {
  final CharacterSpell spell;
  final CharacterSheetViewModel vm;
  final int level;
  const _SpellRow({
    required this.spell,
    required this.vm,
    required this.level,
  });

  String _shortTime(BuildContext context, String? ct) {
    if (ct == null) return '';
    final l = ct.toLowerCase();
    if (l.contains('bonus')) return _tr(context, en: 'Bonus', es: 'Adicional', gl: 'Adicional');
    if (l.contains('reaction')) return _tr(context, en: 'Reaction', es: 'Reaccion', gl: 'Reaccion');
    if (l.contains('1 action') || l == 'action') return _tr(context, en: 'Action', es: 'Accion', gl: 'Accion');
    if (l.contains('minute')) {
      final m = RegExp(r'(\d+)').firstMatch(l)?.group(1) ?? '1';
      return '${m} min';
    }
    return ct;
  }

  String _shortRange(String? r) {
    if (r == null) return '';
    return r.replaceAll(' feet', 'ft').replaceAll(' foot', 'ft');
  }

  @override
  Widget build(BuildContext context) {
    final isCantrip = spell.isCantrip;
    final hasSlots = vm.availableSlots(level) > 0;
    final canCast = isCantrip || hasSlots;

    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF2A2A4A), width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name + stats (fills available space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spell.name,
                    style: GoogleFonts.lato(
                      color: canCast ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _StatsLine(
                    time: _shortTime(context, spell.castingTime),
                    range: _shortRange(spell.range),
                    school: spell.school != null ? localizeSpellSchool(context, spell.school!) : null,
                  ),
                ],
              ),
            ),
            // Aligned data columns + CAST button for leveled spells
            if (!isCantrip) ...[
              const SizedBox(width: _kColGap),
              SizedBox(
                width: _kHitDcW,
                child: _HitDcCell(spell: spell, vm: vm),
              ),
              const SizedBox(width: _kColGap),
              SizedBox(
                width: _kDmgW,
                child: _DamageCell(spell: spell),
              ),
              const SizedBox(width: _kCastPad),
              _CastButton(
                canCast: canCast,
                onCast: () async {
                  final ok = await vm.castSpell(level);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(_tr(context, en: 'No spell slots available for level $level', es: 'No hay espacios de hechizo para nivel $level', gl: 'Non hai espazos de feitizo para nivel $level')),
                      backgroundColor: AppTheme.accent,
                      duration: const Duration(seconds: 2),
                    ));
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListenableBuilder(
        listenable: vm,
        builder: (ctx, __) {
          final maxSl2 = vm.maxSlots(spell.level);
          final usedSl2 = vm.usedSlots(spell.level);
          final hasSlots2 = vm.availableSlots(spell.level) > 0;
          final canCast2 = spell.isCantrip || hasSlots2;
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.92,
            builder: (_, ctrl) => SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                // Title + CAST button
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(spell.name,
                          style: GoogleFonts.libreBaskerville(
                              color: AppTheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${_spellLevelName(context, spell.level)}'
                        '${spell.school != null ? ' · ${localizeSpellSchool(context, spell.school!)}' : ''}'
                        ' · ${_spellSourceLabel(context, spell.spellSource)}',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ]),
                  ),
                  if (!spell.isCantrip) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 72, height: 38,
                      child: OutlinedButton(
                        onPressed: canCast2 ? () async {
                          final ok = await vm.castSpell(spell.level);
                          if (!ok && ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text(_tr(ctx, en: 'No slots for level ${spell.level}', es: 'No hay espacios para nivel ${spell.level}', gl: 'Non hai espazos para nivel ${spell.level}')),
                              backgroundColor: AppTheme.accent,
                              duration: const Duration(seconds: 2)));
                          }
                        } : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: AppTheme.primary,
                          disabledForegroundColor: AppTheme.divider,
                          side: BorderSide(color: canCast2 ? AppTheme.primary : AppTheme.divider),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text(AppStrings.of(context).castButton, style: GoogleFonts.libreBaskerville(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ]),
                // Interactive slot tracker
                if (!spell.isCantrip && maxSl2 > 0) ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Text('${_tr(context, en: 'Slots Lv.', es: 'Espacios Nv.', gl: 'Espazos Nv.')} ${spell.level}',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4)),
                    const SizedBox(width: 10),
                    ...List.generate(maxSl2, (i) {
                      final isFull = i < usedSl2;
                      return GestureDetector(
                        onTap: () async {
                          if (isFull) {
                            await vm.restoreSpellSlot(spell.level);
                          } else {
                            await vm.castSpell(spell.level);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            isFull ? Icons.check_box : Icons.check_box_outline_blank,
                            color: isFull ? AppTheme.accent : AppTheme.textSecondary,
                            size: 20)),
                      );
                    }),
                  ]),
                ],
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (spell.castingTime != null)
                  _DetailRow(_spellDetailLabel(context, 'castingTime'), spell.castingTime!),
                if (spell.range != null)
                  _DetailRow(_spellDetailLabel(context, 'range'), spell.range!),
                if (spell.duration != null)
                  _DetailRow(_spellDetailLabel(context, 'duration'), spell.duration!),
                if (spell.components != null)
                  _DetailRow(_spellDetailLabel(context, 'components'), spell.components!),
                if (!spell.isCantrip)
                  _DetailRow(
                    _spellDetailLabel(context, 'status'),
                    spell.prepared
                        ? _tr(context, en: 'Prepared ✓', es: 'Preparado ✓', gl: 'Preparado ✓')
                        : _tr(context, en: 'Learned', es: 'Aprendido', gl: 'Aprendido'),
                  ),
                if (spell.description != null && spell.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(_spellDetailLabel(context, 'description'),
                      style: GoogleFonts.libreBaskerville(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(spell.description!,
                      style: GoogleFonts.lato(
                          color: AppTheme.textPrimary, fontSize: 13, height: 1.6)),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ── Stat chips second line ───────────────────────────────────────────────────
class _StatsLine extends StatelessWidget {
  final String time;
  final String range;
  final String? school;
  const _StatsLine({
    required this.time,
    required this.range,
    this.school,
  });

  @override
  Widget build(BuildContext context) {
    const Color _sep = Color(0xFF3A3A5A);
    const Color _dim = Color(0xFF9E9282);

    final spans = <InlineSpan>[];

    void add(String v, Color color) {
      if (v.isEmpty) return;
      if (spans.isNotEmpty) {
        spans.add(const TextSpan(
          text: '  ·  ',
          style: TextStyle(color: _sep, fontSize: 11, height: 1.4),
        ));
      }
      spans.add(TextSpan(
        text: v,
        style: TextStyle(color: color, fontSize: 11, height: 1.4,
            fontFamily: 'Lato'),
      ));
    }

    add(time, _dim);
    add(range, _dim);

    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: school ?? '—',
        style: const TextStyle(color: _dim, fontSize: 11, height: 1.4,
            fontFamily: 'Lato'),
      ));
    }

    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}

// ── Cast button ───────────────────────────────────────────────────────────────
class _CastButton extends StatelessWidget {
  final bool canCast;
  final Future<void> Function() onCast;
  const _CastButton({required this.canCast, required this.onCast});

  @override
  Widget build(BuildContext context) {
    final label = AppStrings.of(context).castButton;
    final width = label.length > 5 ? 78.0 : 62.0;
    return SizedBox(
      width: width,
      height: 32,
      child: OutlinedButton(
        onPressed: canCast ? () => onCast() : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: AppTheme.primary,
          disabledForegroundColor: AppTheme.divider,
          side: BorderSide(
            color: canCast ? AppTheme.primary : AppTheme.divider,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.libreBaskerville(
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Damage cell: dice above, type below (same size, uppercase) ────────────────
class _DamageCell extends StatelessWidget {
  final CharacterSpell spell;
  const _DamageCell({required this.spell});

  static const _kColor = Color(0xFFCB7A48);

  @override
  Widget build(BuildContext context) {
    final base = spell.damageBase;
    final type = spell.damageType;
    if (base == null || base.isEmpty) {
      return Text('—', textAlign: TextAlign.center, style: GoogleFonts.lato(color: _kColor, fontSize: 11, fontWeight: FontWeight.w600));
    }
    if (type == null || type.isEmpty) {
      return Text(base, textAlign: TextAlign.center, style: GoogleFonts.lato(color: _kColor, fontSize: 11, fontWeight: FontWeight.w600));
    }
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(base, textAlign: TextAlign.center, style: GoogleFonts.lato(color: _kColor, fontSize: 11, fontWeight: FontWeight.w600)),
      Text(localizeDamageType(context, type).toUpperCase(), textAlign: TextAlign.center, style: GoogleFonts.lato(color: _kColor, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ── HIT/DC cell: attack bonus as single line; DC attr above + value below ────
class _HitDcCell extends StatelessWidget {
  final CharacterSpell spell;
  final CharacterSheetViewModel vm;
  const _HitDcCell({required this.spell, required this.vm});

  static const _kColor = Color(0xFFC8A45A);

  @override
  Widget build(BuildContext context) {
    if (spell.attackType != null && spell.attackType!.isNotEmpty) {
      return Text(
        vm.signedInt(vm.character?.spellAttackBonus ?? 0),
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(color: _kColor, fontSize: 11, fontWeight: FontWeight.w600),
      );
    }
    if (spell.dcType != null && spell.dcType!.isNotEmpty) {
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(spell.dcType!.toUpperCase(), textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: _kColor, fontSize: 11, fontWeight: FontWeight.w600)),
        Text('DC ${vm.character?.spellSaveDC ?? 0}', textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: _kColor, fontSize: 11, fontWeight: FontWeight.w600)),
      ]);
    }
    return Text('—', textAlign: TextAlign.center,
        style: GoogleFonts.lato(color: _kColor, fontSize: 11, fontWeight: FontWeight.w600));
  }
}

// - Manage Spells Screen
class ManageSpellsScreen extends StatefulWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const ManageSpellsScreen(
    {super.key, required this.character, required this.vm});

    @override
    State<ManageSpellsScreen> createState() => _ManageSpellsScreenState();
}

class _ManageSpellsScreenState extends State<ManageSpellsScreen>
        with SingleTickerProviderStateMixin{
      late TabController _tabCtrl;
      final _searchCtrl = TextEditingController();
      String _query = '';

      @override
      void initState() {
        super.initState();
        _tabCtrl = TabController(length: 2, vsync: this);
        widget.vm.addListener(_onVmChanged);
    }

    void _onVmChanged() {
      if (!mounted) return;
      final msg = widget.vm.errorMessage;
      if (msg != null && msg.isNotEmpty) {
        widget.vm.clearError();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg,
                style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: AppTheme.accent,
              duration: const Duration(seconds: 3),
            ));
          }
        });
      }
      setState(() {});
    }

    @override
    void dispose() {
      widget.vm.removeListener(_onVmChanged);
      _tabCtrl.dispose();
      _searchCtrl.dispose();
      super.dispose();
    }

    List<CharacterSpell> get _filteredSpells {
    final q = _query.toLowerCase();
    return widget.vm.character!.characterSpells.where((s) {
      return q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          (s.school?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
  
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(AppStrings.of(context).manageSpells,
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: [
            Tab(child: Text(AppStrings.of(context).mySpells, style: GoogleFonts.libreBaskerville(fontSize: 12))),
            Tab(child: Text(AppStrings.of(context).learnNew, style: GoogleFonts.libreBaskerville(fontSize: 12))),
          ],
        ),
      ),
      body: Column(children: [
        // Buscador global
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: _tr(
                context,
                en: 'Search by name or school…',
                es: 'Buscar por nombre o escuela…',
                gl: 'Buscar por nome ou escola…',
              ),
              hintStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
              prefixIcon:
                  const Icon(Icons.search, color: AppTheme.primary, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      })
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              // Tab 1: Mis hechizos (preparar / borrar)
              _MySpellsTab(
                spells: _filteredSpells,
                vm: widget.vm,
                alwaysPrepared: widget.vm.alwaysPreparedClass,
              ),
              // Tab 2: Aprender nuevos (coming soon — placeholder)
              _LearnNewTab(
                vm: widget.vm,
                query: _query,
          ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Tab: My Spells ────────────────────────────────────────────────────────────

class _MySpellsTab extends StatelessWidget {
  final List<CharacterSpell> spells;
  final CharacterSheetViewModel vm;
  final bool alwaysPrepared;
  const _MySpellsTab({
    required this.spells,
    required this.vm,
    required this.alwaysPrepared,
  });

  @override
  Widget build(BuildContext context) {
    if (spells.isEmpty) {
      return Center(
          child: Text(_tr(
                context,
                en: 'No spells match your search.',
                es: 'Ningun hechizo coincide con tu busqueda.',
                gl: 'Ningun feitizo coincide coa busca.',
              ),
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 13)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: spells.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) => _ManageSpellTile(
      spell: spells[i],
      alwaysPrepared: alwaysPrepared,
      onDelete: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.surface,
            scrollable: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(AppStrings.of(context).removeSpellTitle,
                style: GoogleFonts.libreBaskerville(color: AppTheme.primary)),
            content: Text(
                AppStrings.of(context).removeSpellContent(spells[i].name),
                style: GoogleFonts.lato(color: AppTheme.textPrimary)),
            actions: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.surfaceVariant, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(0, 40),
                        ),
                        child: Text(AppStrings.of(context).cancel, style: GoogleFonts.lato(color: AppTheme.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text(AppStrings.of(context).removeButton),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await vm.removeSpell(spells[i].spellId);
          // Stay on Manage Spells — the viewmodel reload will update the list
        }
      },
      onTogglePrepare: (_) async {
        await vm.togglePrepareSpell(spells[i].spellId);
      },
    ),
  );        
  }   
}

class _ManageSpellTile extends StatelessWidget {
  final CharacterSpell spell;
  final bool alwaysPrepared;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTogglePrepare;
  const _ManageSpellTile({
    required this.spell,
    required this.alwaysPrepared,
    required this.onDelete,
    required this.onTogglePrepare,
  });

  @override
  Widget build(BuildContext context) {
    final isCantrip = spell.isCantrip;
    // Los cantrips y clases "always prepared" no tienen switch
    final showSwitch = !isCantrip && !alwaysPrepared;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Row(children: [
        // Nivel badge
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              isCantrip ? '∞' : '${spell.level}',
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.primary,
                  fontSize: isCantrip ? 16 : 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spell.name,
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(children: [
                  if (spell.school != null)
                    Text(spell.school!,
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  if (isCantrip) ...[
                    const SizedBox(width: 4),
                    Text(_tr(context, en: '· At Will', es: '· A voluntad', gl: '· A vontade'),
                        style: GoogleFonts.lato(
                            color: AppTheme.primary, fontSize: 11)),
                  ] else if (alwaysPrepared) ...[
                    const SizedBox(width: 4),
                    Text(_tr(context, en: '· Always Prepared', es: '· Siempre preparado', gl: '· Sempre preparado'),
                        style: GoogleFonts.lato(
                            color: AppTheme.primary, fontSize: 11)),
                  ],
                ]),
              ]),
        ),

        // Preparar switch (solo para clases de preparación y no cantrips)
        if (showSwitch)
          Switch(
            value: spell.prepared,
            onChanged: onTogglePrepare,
            activeColor: AppTheme.primary,
          )
        else
          const SizedBox(width: 8),

        // Botón eliminar
        IconButton(
          icon: const Icon(Icons.delete_outline,
              color: AppTheme.accent, size: 20),
          tooltip: AppStrings.of(context).removeSpellTitle,
          onPressed: onDelete,
        ),
      ]),
    );
  }
}

// ── Tab: Learn New ────────────────────────────────────────────────────────────

class _LearnNewTab extends StatefulWidget {
  final CharacterSheetViewModel vm;
  final String query;
  const _LearnNewTab({required this.vm, required this.query});

  @override
  State<_LearnNewTab> createState() => _LearnNewTabState();
}

class _LearnNewTabState extends State<_LearnNewTab> {
  // Carga al entrar en la tab por primera vez
  @override
  void initState() {
    super.initState();
    if (widget.vm.availableSpells.isEmpty) {
      widget.vm.loadAvailableSpells();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final vm = widget.vm;

    // Filtra por el query del buscador global + excluye ya conocidos opcionalmente
    final q = widget.query.toLowerCase();
    final filtered = vm.availableSpells.where((s) {
      return q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          (s.school?.toLowerCase().contains(q) ?? false);
    }).toList();

    // Agrupa por nivel para mostrar igual que la tab principal
    final Map<int, List<SpellOption>> byLevel = {};
    for (final s in filtered) {
      byLevel.putIfAbsent(s.level, () => []).add(s);
    }
    final sortedLevels = byLevel.keys.toList()..sort();

    if (vm.isLoadingSpells) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primary),
            const SizedBox(height: 14),
            Text(
              _tr(context, en: 'Loading spells…', es: 'Cargando hechizos…', gl: 'Cargando feitizos…'),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (vm.spellsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: AppTheme.accent, size: 40),
            const SizedBox(height: 12),
            Text(vm.spellsError!,
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: vm.loadAvailableSpells,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(AppStrings.of(context).retry),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary)),
            ),
          ]),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          q.isEmpty
              ? _tr(context, en: 'No spells available for this class.', es: 'No hay hechizos disponibles para esta clase.', gl: 'Non hai feitizos dispoñibles para esta clase.')
              : _tr(context, en: 'No results for "$q".', es: 'Sin resultados para "$q".', gl: 'Sen resultados para "$q".'),
          style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: sortedLevels.length,
      itemBuilder: (_, i) {
        final level     = sortedLevels[i];
        final spells    = byLevel[level]!;
        final levelName = _spellLevelName(context, level);

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera de nivel
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Row(children: [
                  Text(levelName,
                      style: GoogleFonts.libreBaskerville(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: Divider(color: AppTheme.surfaceVariant)),
                ]),
              ),
              // Tiles de spells
              ...spells.map((spell) => _LearnSpellTile(
                    spell: spell,
                    isKnown: vm.knownSpellIds.contains(spell.id),
                    onLearn: () => _confirmLearn(context, spell, vm),
                  )),
            ]);
      },
    );
  }

  Future<void> _confirmLearn(
      BuildContext context, SpellOption spell, CharacterSheetViewModel vm) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.of(context).learnSpellTitle,
            style: GoogleFonts.libreBaskerville(color: AppTheme.primary)),
        content: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(spell.name,
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${spell.isCantrip ? _tr(context, en: 'Cantrip', es: 'Truco', gl: 'Truco') : _tr(context, en: 'Level ${spell.level}', es: 'Nivel ${spell.level}', gl: 'Nivel ${spell.level}')} '
            '${spell.school != null ? ' · ${spell.school}' : ''}',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
          if (spell.description != null && spell.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              spell.description!.length > 160
                  ? '${spell.description!.substring(0, 160)}…'
                  : spell.description!,
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
            ),
          ],
        ]),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.surfaceVariant, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 40),
                    ),
                    child: Text(AppStrings.of(context).cancel, style: GoogleFonts.lato(color: AppTheme.textSecondary)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text(AppStrings.of(context).learnButton,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await vm.learnSpell(spell.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.of(context).spellLearned(spell.name)),
          backgroundColor: AppTheme.primary.withOpacity(0.9),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }
}

// ── Learn Spell Tile ──────────────────────────────────────────────────────────

class _LearnSpellTile extends StatelessWidget {
  final SpellOption spell;
  final bool isKnown;
  final VoidCallback onLearn;
  const _LearnSpellTile({
      required this.spell,
      required this.isKnown,
      required this.onLearn});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isKnown
            ? AppTheme.primary.withOpacity(0.07)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isKnown ? AppTheme.primary.withOpacity(0.3) : AppTheme.surfaceVariant,
        ),
      ),
      child: Row(children: [
        // Nivel badge
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(isKnown ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              spell.isCantrip ? '∞' : '${spell.level}',
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.primary,
                  fontSize: spell.isCantrip ? 16 : 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spell.name,
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(children: [
                  if (spell.school != null)
                    Text(spell.school!,
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  if (spell.castingTime != null) ...[
                    if (spell.school != null)
                      const Text(' · ',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                    Text(spell.castingTime!,
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ]),
              ]),
        ),

        // Botón / badge
        if (isKnown)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
            ),
            child: Text(_tr(context, en: 'Known', es: 'Conocido', gl: 'Coñecido'),
                style: GoogleFonts.lato(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          )
        else
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppTheme.primary, size: 22),
            tooltip: AppStrings.of(context).learnSpellTitle,
            onPressed: onLearn,
          ),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.auto_fix_high,
                color: AppTheme.surfaceVariant, size: 48),
            const SizedBox(height: 16),
            Text(_tr(context, en: 'No spells learned yet', es: 'Aun no hay hechizos aprendidos', gl: 'Ainda non hai feitizos aprendidos'),
                style: GoogleFonts.libreBaskerville(
                    color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              _tr(context, en: 'Add spells using the "Manage Spells" button above.', es: 'Anade hechizos usando el boton "Gestionar Hechizos" de arriba.', gl: 'Engade feitizos usando o boton "Xestionar Feitizos" de arriba.'),
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: AppTheme.divider);
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 110,
            child: Text('$label:',
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 12)),
          ),
        ]),
      );
}