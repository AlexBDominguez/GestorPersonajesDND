import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class TabSpells extends StatefulWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabSpells({super.key, required this.character, required this.vm});

  @override
  State<TabSpells> createState() => _TabSpellsState();
}

class _TabSpellsState extends State<TabSpells> {
  int _selectedLevel = -1; // -1 = All

  PlayerCharacter get c => widget.character;
  CharacterSheetViewModel get vm => widget.vm;

  @override
  Widget build(BuildContext context) {
    // Niveles disponibles según los spell slots reales del personaje (desde backend)
    final maxSpellLevel = c.spellSlots.isEmpty
        ? 0
        : c.spellSlots.map((s) => s.spellLevel).reduce((a, b) => a > b ? a : b);
    final levels = [-1, 0, ...List.generate(maxSpellLevel, (i) => i + 1)];

    return Column(children: [
      // ── Spell modifiers ─────────────────────────────────────
      _SpellModifiersBar(character: c, vm: vm),

      // ── Level filter chips ───────────────────────────────────
      Container(
        color: AppTheme.surface,
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: levels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final lvl = levels[i];
            final label = lvl == -1 ? 'All' : lvl == 0 ? 'Cantrips' : 'Lv $lvl';
            final selected = _selectedLevel == lvl;
            return GestureDetector(
              onTap: () => setState(() => _selectedLevel = lvl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? AppTheme.primary : AppTheme.divider),
                ),
                child: Text(label,
                    style: GoogleFonts.cinzel(
                        color: selected
                            ? AppTheme.background
                            : AppTheme.textSecondary,
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      ),
      const Divider(height: 1),

      // ── Spell list ───────────────────────────────────────────
      Expanded(
        child: _selectedLevel == -1
            ? _AllSpellsView(character: c, vm: vm)
            : _LevelSpellsView(
                level: _selectedLevel, character: c, vm: vm),
      ),
    ]);
  }

}

// Spells modifier bar
class _SpellModifiersBar extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const _SpellModifiersBar({required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    final c = character;
    return Container(
      color: AppTheme.surfaceVariant.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _MiniStat(label: 'Modifier', value: vm.signedInt(c.spellAttackBonus - c.proficiencyBonus)),
        _VertDivider(),
        _MiniStat(label: 'Spell Attack', value: vm.signedInt(c.spellAttackBonus)),
        _VertDivider(),
        _MiniStat(label: 'DC', value: '${c.spellSaveDC}'),
        _VertDivider(),
        _MiniStat(label: 'Max Prepared', value: '${c.maxPreparedSpells}'),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget{
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value,
        style: GoogleFonts.cinzel(
          color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
      Text(label,
        style: GoogleFonts.lato(
          color: AppTheme.textSecondary, fontSize: 9)),
    ],
  );
}

class _VertDivider extends StatelessWidget{
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 32, color: AppTheme.divider);
}

//All spells view
class _AllSpellsView extends StatelessWidget{
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const _AllSpellsView({required this.character, required this.vm});

  @override
  Widget build(BuildContext context){
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_fix_high,
            color: AppTheme.surfaceVariant, size: 48),
          const SizedBox(height: 16),
          Text('No spells learned yet',
            style: GoogleFonts.cinzel(
              color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
          Text('Use "Manage Spells" to learn and prepare spells.',
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 12,
              fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manage spells - coming soon!'),
                    backgroundColor: AppTheme.surfaceVariant,
                  ));
              },
              icon: const Icon(Icons.library_books_outlined,
                color: AppTheme.primary, size: 16),
              label: Text('Manage Spells',
                style: GoogleFonts.cinzel(
                  color: AppTheme.primary, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primary),
                minimumSize: const Size(180, 44),
              ),
            ),
        ]),
      ),
    );
  }
}

//Level spells view
class _LevelSpellsView extends StatelessWidget{
  final int level;
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const _LevelSpellsView({required this.level, required this.character, required this.vm});

  @override
  Widget build(BuildContext context){
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(level == 0 ? Icons.flare : Icons.auto_fix_high,
          color: AppTheme.surfaceVariant, size: 40),
        const SizedBox(height: 12),
        Text(
          level == 0? 'No cantrips known' : 'No level $level spells',
          style: GoogleFonts.cinzel(
            color: AppTheme.textSecondary, fontSize: 13),
          ),
        ]),
    );
  }
}

