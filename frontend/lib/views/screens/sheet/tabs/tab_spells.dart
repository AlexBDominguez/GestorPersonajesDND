import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/spell_slot.dart';
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
    final spells = c.characterSpells;
    final hasSpells = spells.isNotEmpty;

    // Niveles que el personaje realmente tiene
    final levels = <int>{};
    for (final s in spells) levels.add(s.level);
    final levelFilter = [-1, ...levels.toList()..sort()];

    // Spells filtrados según el chip activo
    final filtered = _selectedLevel == -1
        ? spells
        : spells.where((s) => s.level == _selectedLevel).toList();

    return Column(children: [
      // ── Spell modifiers bar ──────────────────────────────────────
      _SpellModifiersBar(character: c, vm: vm),

      // ── Aviso si no hay spells ───────────────────────────────────
      if (!hasSpells)
        Container(
          width: double.infinity,
          color: AppTheme.primary.withOpacity(0.07),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You have no spells yet. You can add them from the spell management screen.',
                style: GoogleFonts.lato(color: AppTheme.primary, fontSize: 12),
              ),
            ),
          ]),
        ),

      // ── Spell slots ──────────────────────────────────────────────
      if (c.spellSlots.isNotEmpty) _SpellSlotsRow(character: c),

      // ── Level filter chips ───────────────────────────────────────
      if (hasSpells)
        Container(
          color: AppTheme.surface,
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: levelFilter.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final lvl = levelFilter[i];
              final label = lvl == -1
                  ? 'All'
                  : lvl == 0
                      ? 'Cantrips'
                      : 'Lv $lvl';
              final selected = _selectedLevel == lvl;
              return GestureDetector(
                onTap: () => setState(() => _selectedLevel = lvl),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primary
                        : AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.divider),
                  ),
                  child: Text(label,
                      style: GoogleFonts.cinzel(
                          color: selected
                              ? AppTheme.background
                              : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
      const Divider(height: 1),

      // ── Lista de spells ──────────────────────────────────────────
      Expanded(
        child: !hasSpells
            ? _EmptyState()
            : filtered.isEmpty
                ? Center(
                    child: Text('No spells at this level',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 14)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _SpellCard(spell: filtered[i]),
                  ),
      ),
    ]);
  }
}

// ── Spell Slots Row ───────────────────────────────────────────────────────────

class _SpellSlotsRow extends StatelessWidget {
  final PlayerCharacter character;
  const _SpellSlotsRow({required this.character});

  @override
  Widget build(BuildContext context) {
    final slots = character.spellSlots
        .where((s) => s.maxSlots > 0)
        .toList()
      ..sort((a, b) => a.spellLevel.compareTo(b.spellLevel));

    if (slots.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Spell Slots',
            style: GoogleFonts.cinzel(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: slots.map((s) => _SlotPill(slot: s)).toList(),
          ),
        ),
      ]),
    );
  }
}

class _SlotPill extends StatelessWidget {
  final SpellSlot slot;
  const _SlotPill({required this.slot});

  @override
  Widget build(BuildContext context) {
    final used = slot.usedSlots;
    final max = slot.maxSlots;
    final full = used >= max;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: full
            ? AppTheme.surfaceVariant
            : AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: full ? AppTheme.divider : AppTheme.primary),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Lv ${slot.spellLevel}',
            style: GoogleFonts.cinzel(
                color: full ? AppTheme.textSecondary : AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text('${max - used}/$max',
            style: GoogleFonts.lato(
                color: full ? AppTheme.textSecondary : AppTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// ── Spell Modifiers Bar ───────────────────────────────────────────────────────

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
        _MiniStat(
            label: 'Modifier',
            value: vm.signedInt(c.spellAttackBonus - c.proficiencyBonus)),
        _VertDivider(),
        _MiniStat(
            label: 'Spell Attack',
            value: vm.signedInt(c.spellAttackBonus)),
        _VertDivider(),
        _MiniStat(label: 'Save DC', value: '${c.spellSaveDC}'),
        _VertDivider(),
        _MiniStat(
            label: 'Prepared',
            value:
                '${c.characterSpells.where((s) => s.prepared).length}/${c.maxPreparedSpells}'),
      ]),
    );
  }
}

// ── Spell Card ────────────────────────────────────────────────────────────────

class _SpellCard extends StatelessWidget {
  final CharacterSpell spell;
  const _SpellCard({required this.spell});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Row(children: [
          // Indicador de nivel / cantrip
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                spell.isCantrip ? '∞' : '${spell.level}',
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary,
                    fontSize: spell.isCantrip ? 18 : 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info principal
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(spell.name,
                          style: GoogleFonts.cinzel(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ),
                    // Badge de fuente (RACE, FEAT, etc.)
                    if (spell.spellSource != null &&
                        spell.spellSource != 'CLASS')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(spell.sourceLabel,
                            style: GoogleFonts.lato(
                                color: AppTheme.primary, fontSize: 9)),
                      ),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    if (spell.school != null) _Tag(spell.school!),
                    if (spell.school != null && spell.castingTime != null)
                      const SizedBox(width: 4),
                    if (spell.castingTime != null)
                      _Tag(spell.castingTime!),
                    const Spacer(),
                    // Indicador prepared/cantrip
                    if (!spell.isCantrip)
                      Row(children: [
                        Icon(
                          spell.prepared
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 13,
                          color: spell.prepared
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          spell.prepared ? 'Prepared' : 'Learned',
                          style: GoogleFonts.lato(
                              color: spell.prepared
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                              fontSize: 10),
                        ),
                      ]),
                  ]),
                ]),
          ),

          // Flecha de detalle
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right,
              color: AppTheme.textSecondary, size: 18),
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
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                // Nombre y nivel
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
                const SizedBox(height: 12),
                // Propiedades
                if (spell.castingTime != null)
                  _DetailRow('Casting Time', spell.castingTime!),
                if (spell.range != null)
                  _DetailRow('Range', spell.range!),
                if (spell.duration != null)
                  _DetailRow('Duration', spell.duration!),
                if (spell.components != null)
                  _DetailRow('Components', spell.components!),
                // Estado prepared
                if (!spell.isCantrip) ...[
                  const SizedBox(height: 4),
                  _DetailRow('Status',
                      spell.prepared ? 'Prepared ✓' : 'Learned (not prepared)'),
                ],
                // Descripción
                if (spell.description != null &&
                    spell.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Description',
                      style: GoogleFonts.cinzel(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(spell.description!,
                      style: GoogleFonts.lato(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          height: 1.6)),
                ],
              ]),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
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
            Text(
              'Spells added during character creation will appear here.\nYou can also add them later from the manage spells screen.',
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

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 9)),
        ],
      );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppTheme.divider);
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

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 10)),
      );
}