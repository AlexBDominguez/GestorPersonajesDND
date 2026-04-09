import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

// Column widths shared between level header and spell rows
const double _kHitDcW  = 62.0;
const double _kDmgW    = 80.0;
const double _kColGap  =  8.0;
const double _kCastPad = 10.0;
const double _kCastW   = 54.0;

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
            label: const Text('Manage Spells'),
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
            label: 'SAVE DC',
            value: '${c.spellSaveDC}',
          ),
          _VertDivider(),
          _StatPill(
            label: 'ATTACK',
            value: vm.signedInt(c.spellAttackBonus),
          ),
          _VertDivider(),
          _StatPill(
            label: 'PREPARED',
            value: '${c.characterSpells.where((s) => s.prepared && !s.isCantrip).length}/${c.maxPreparedSpells}',
          ),
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
              style: GoogleFonts.cinzel(
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

  static const _levelNames = [
    'Cantrips',
    '1st Level',
    '2nd Level',
    '3rd Level',
    '4th Level',
    '5th Level',
    '6th Level',
    '7th Level',
    '8th Level',
    '9th Level',
  ];

  String get levelName =>
      level < _levelNames.length ? _levelNames[level] : 'Level $level';

  @override
  Widget build(BuildContext context) {
    final maxSl = vm.maxSlots(level);
    final usedSl = vm.usedSlots(level);
    final isCantrip = level == 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 12),

      //A. Cabecera de nivel con slot tracker
      Row(children: [
        Text(levelName,
            style: GoogleFonts.cinzel(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        if (!isCantrip && maxSl > 0) ...[
          const SizedBox(width: 8),
          _SlotTracker(used: usedSl, max: maxSl),
        ],
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
        if (!isCantrip) ...[
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
            child: Text('DAMAGE',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ),
          const SizedBox(width: _kCastPad + _kCastW),
        ],
      ]),
      const SizedBox(height: 6),

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

// Slot Tracker
class _SlotTracker extends StatelessWidget {
  final int used;
  final int max;
  const _SlotTracker({required this.used, required this.max});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(max, (i) => Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Icon(
        i < used
          ? Icons.check_box
          : Icons.check_box_outline_blank,
        color: i < used
          ? AppTheme.accent
          : AppTheme.textSecondary,
        size: 16,
      ),
    )),
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

  String _shortTime(String? ct) {
    if (ct == null) return '';
    final l = ct.toLowerCase();
    if (l.contains('bonus')) return 'Bonus';
    if (l.contains('reaction')) return 'Reaction';
    if (l.contains('1 action') || l == 'action') return 'Action';
    if (l.contains('minute')) {
      final m = RegExp(r'(\d+)').firstMatch(l)?.group(1) ?? '1';
      return '${m}m';
    }
    return ct;
  }

  String _shortRange(String? r) {
    if (r == null) return '';
    return r.replaceAll(' feet', 'ft').replaceAll(' foot', 'ft');
  }

  String _hitDc(CharacterSpell s) {
    if (s.attackType != null && s.attackType!.isNotEmpty) {
      return vm.signedInt(vm.character?.spellAttackBonus ?? 0);
    }
    if (s.dcType != null && s.dcType!.isNotEmpty) {
      return '${s.dcType} DC ${vm.character?.spellSaveDC ?? 0}';
    }
    return '';
  }

  String _damage(CharacterSpell s) {
    final base = s.damageBase;
    final type = s.damageType;
    if (base == null || base.isEmpty) return '';
    if (type == null || type.isEmpty) return base;
    return '$base $type';
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
                    time: _shortTime(spell.castingTime),
                    range: _shortRange(spell.range),
                    school: spell.school,
                  ),
                ],
              ),
            ),
            // Aligned data columns + CAST button for leveled spells
            if (!isCantrip) ...[
              const SizedBox(width: _kColGap),
              SizedBox(
                width: _kHitDcW,
                child: Text(
                  _hitDc(spell),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    color: const Color(0xFFC8A45A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: _kColGap),
              SizedBox(
                width: _kDmgW,
                child: Text(
                  _damage(spell),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    color: const Color(0xFFCB7A48),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: _kCastPad),
              _CastButton(
                canCast: canCast,
                onCast: () async {
                  final ok = await vm.castSpell(level);
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('No spell slots available for level $level'),
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
      builder: (_) => DraggableScrollableSheet(
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
            Text(spell.name,
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '${spell.levelLabel}'
              '${spell.school != null ? ' · ${spell.school}' : ''}'
              ' · ${spell.sourceLabel}',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            if (spell.castingTime != null)
              _DetailRow('Casting Time', spell.castingTime!),
            if (spell.range != null)
              _DetailRow('Range', spell.range!),
            if (spell.duration != null)
              _DetailRow('Duration', spell.duration!),
            if (spell.components != null)
              _DetailRow('Components', spell.components!),
            if (!spell.isCantrip)
              _DetailRow('Status', spell.prepared ? 'Prepared ✓' : 'Learned'),
            if (spell.description != null && spell.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Description',
                  style: GoogleFonts.cinzel(
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
  Widget build(BuildContext context) => SizedBox(
    width: 54,
    height: 32,
    child: OutlinedButton(
      onPressed: canCast ? () => onCast() : null,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
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
      child: Text('CAST',
          style: GoogleFonts.cinzel(fontSize: 9, fontWeight: FontWeight.bold)),
    ),
  );
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
    }

    @override
    void dispose() {
      _tabCtrl.dispose();
      _searchCtrl.dispose();
      super.dispose();
    }

    List<CharacterSpell> get _filteredSpells {
    final q = _query.toLowerCase();
    return widget.character.characterSpells.where((s) {
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
        title: Text('Manage Spells',
            style: GoogleFonts.cinzel(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: [
            Tab(child: Text('My Spells', style: GoogleFonts.cinzel(fontSize: 12))),
            Tab(child: Text('Learn New',  style: GoogleFonts.cinzel(fontSize: 12))),
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
              hintText: 'Search by name or school…',
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
              _LearnNewTab(),
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
          child: Text('No spells match your search.',
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
            title: Text('Remove spell?',
                style: GoogleFonts.cinzel(color: AppTheme.primary)),
            content: Text(
                'Remove "${spells[i].name}" from your spellbook?',
                style: GoogleFonts.lato(color: AppTheme.textPrimary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel',
                    style: GoogleFonts.lato(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await vm.removeSpell(spells[i].spellId);
          if (context.mounted) Navigator.of(context).pop(); // cerrar manage screen
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
              style: GoogleFonts.cinzel(
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
                    style: GoogleFonts.cinzel(
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
                    Text('· At Will',
                        style: GoogleFonts.lato(
                            color: AppTheme.primary, fontSize: 11)),
                  ] else if (alwaysPrepared) ...[
                    const SizedBox(width: 4),
                    Text('· Always Prepared',
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
          tooltip: 'Remove spell',
          onPressed: onDelete,
        ),
      ]),
    );
  }
}

// ── Tab: Learn New ────────────────────────────────────────────────────────────

class _LearnNewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.auto_fix_high,
                color: AppTheme.surfaceVariant, size: 48),
            const SizedBox(height: 16),
            Text('Learn New Spells',
                style: GoogleFonts.cinzel(
                    color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              'This feature is coming soon.\nYou will be able to browse and learn new spells here.',
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
            Text('No spells learned yet',
                style: GoogleFonts.cinzel(
                    color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              'Add spells using the "Manage Spells" button above.',
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