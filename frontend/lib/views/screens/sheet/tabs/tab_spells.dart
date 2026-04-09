import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/spell_slot.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final abilityShort = vm.spellcastingAbility;
    final abilityFull  = CharacterSheetViewModel.abilityFull[abilityShort] ?? abilityShort;
    final abilityMod   = c.modifier(abilityShort);

    return Container(
      color: AppTheme.surfaceVariant.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatPill(
            top: abilityShort,
            mid: vm.signedInt(abilityMod),
            bottom: abilityFull,
          ),
          _VertDivider(),
          _StatPill(
            top: 'SAVE DC',
            mid: '${c.spellSaveDC}',
            bottom: 'Difficulty',
          ),
          _VertDivider(),
          _StatPill(
            top: 'ATTACK',
            mid: vm.signedInt(c.spellAttackBonus),
            bottom: 'Spell Attack',
          ),
          _VertDivider(),
          _StatPill(
            top: 'PREPARED',
            mid: '${c.characterSpells.where((s) => s.prepared && !s.isCantrip).length}/${c.maxPreparedSpells}',
            bottom: 'Spells',
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String top;
  final String mid;
  final String bottom;
  const _StatPill({required this.top, required this.mid, required this.bottom});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(top,
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(mid,
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(bottom,
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 9)),
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
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
        if (!isCantrip && maxSl > 0) ...[
          const SizedBox(width: 8),
          _SlotTracker(used: usedSl, max: maxSl),
        ],
      ]),
      const SizedBox(height: 6),

      // B. Fila de etiquetas
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          _LabelCell('NAME', flex: 3),
          const SizedBox(width: 6),
          _LabelCell('TIME', flex: 1),
          const SizedBox(width: 6),
          _LabelCell('RANGE', flex: 1),
          const SizedBox(width: 6),
          _LabelCell('HIT/DC', flex: 1),
          const SizedBox(width: 6),
          _LabelCell('EFFECT', flex: 2),
          const SizedBox(width: 52), //espacio para el botón CAST
        ]),
      ),
      const Divider (height: 8, color: AppTheme.divider),

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


// - Label Cell

class _LabelCell extends StatelessWidget {
  final String text;
  final int flex;
  const _LabelCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(text,
        style: GoogleFonts.lato(
            color: AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5)),
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

  // Extrae abreviatura de casting time:
  // "1 action" -> "1A", "1 bonus action" -> "1BA", "1 reaction" -> "1R", etc.
  String _shortTime(String? ct){
    if (ct == null) return '--';
    final l = ct.toLowerCase();
    if (l.contains('bonus')) return 'BA';
    if (l.contains('reaction')) return 'R';
    if (l.contains('1 action') || l == 'action') return '1A';
    if(l.contains('minute')) {
      final m = RegExp(r'(\d+)').firstMatch(l)?.group(1) ?? '1';
      return '${m}M';
    }
    return ct.length > 3 ? ct.substring(0, 3) : ct;
  }

  // Extrae rango corto: "30 feet" -> "30 ft"
  String _shortRange(String? r) {
    if (r == null) return '--';
    return r.replaceAll(' feet', 'ft').replaceAll(' foot', 'ft');
  }

    // Hit/DC: si tiene attack bonus lo muestra, si no "--"
  String _hitDc(CharacterSpell s) {
    // Por ahora mostramos DC si tiene save, o el ataque si no
    // Cuando tengamos más datos del spell podemos refinar esto
    return '--';
  }

  //Effect: usamos la escuela como resumen
  String _effect(CharacterSpell s) {
    final school = s.school;
    if(school == null) return '--';
    //Abreviatura de la escuela
    const abrr = {
      'Abjuration': 'Protect',
      'Conjuration': 'Summon',
      'Divination': 'Info',
      'Enchantment': 'Charm',
      'Evocation': 'Damage',
      'Illusion': 'Trick',
      'Necromancy': 'Necro',
      'Transmutation': 'Transform',
    };
    return abrr[school] ?? school;
  }

  @override
  Widget build(BuildContext context) {
    final isCantrip = spell.isCantrip;
    final hasSlots = vm.availableSlots(level) > 0;
    final canCast = isCantrip || hasSlots;

    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              //Nombre
              Expanded(
                flex: 3,
                child: Row(children: [
                  //Dot de prepared
                  if (!isCantrip)
                  Icon(
                    spell.prepared ? Icons.bookmark : Icons.bookmark_border,
                    size: 11,
                    color: spell.prepared
                        ? AppTheme.primary
                        : AppTheme.divider,
                  ),
                if (!isCantrip) const SizedBox(width: 4),
                Expanded(
                  child: Text(spell.name,
                      style: GoogleFonts.lato(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                      ),
                ]),
              ),
              const SizedBox(width: 6),
              //Time
              Expanded(
                flex: 1,
                child: Text(_shortTime(spell.castingTime),
                    style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 11)),
              ),
              const SizedBox(width: 6),
              //Range
              Expanded(
                flex: 1,
                child: Text(_shortRange(spell.range),
                    style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 11)),
              ),
              const SizedBox(width: 6),
              //Hit/DC
              Expanded(
                flex: 1,
                child: Text(_hitDc(spell),
                    style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 11)),
              ),
              const SizedBox(width: 6),
              // Effect
              Expanded(
               flex: 2,
                child: Text(_effect(spell),
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 11),
                overflow: TextOverflow.ellipsis),
              ),
              
              //Botón Cast
              SizedBox(
                width: 52,
                child: OutlinedButton(
                  onPressed: canCast
                      ? () {
                        final ok = vm.castSpell(level);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('No spell slots available for level $level'),
                            backgroundColor: AppTheme.accent,
                            duration: const Duration(seconds: 2),
                          ));
                        }
                      }
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size(44, 26),
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
                      style: GoogleFonts.cinzel(
                        fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),              
            ]),
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
        onDelete: () {
          // TODO: llamar al backend DELETE /characters/{id}/spells/{spellId}
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Delete spell — coming soon'),
              backgroundColor: AppTheme.surfaceVariant));
        },
        onTogglePrepare: (_) {
          // TODO: llamar al backend PATCH /characters/{id}/spells/{spellId}/prepare
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Toggle prepare — coming soon'),
              backgroundColor: AppTheme.surfaceVariant));
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