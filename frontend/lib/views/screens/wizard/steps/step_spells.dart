import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/wizard/character_creator_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StepSpells extends StatefulWidget {
  const StepSpells({super.key});

  @override
  State<StepSpells> createState() => _StepSpellsState();
}

class _StepSpellsState extends State<StepSpells> {
  int _filterLevel = -1;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final filtered = vm.availableSpells.where((s) {
      final matchLevel = _filterLevel == -1 || s.level == _filterLevel;
      final query = _searchCtrl.text.toLowerCase();
      final matchSearch = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          (s.school?.toLowerCase().contains(query) ?? false);
      return matchLevel && matchSearch;
    }).toList();

    final levels = <int>{};
    for (final s in vm.availableSpells) levels.add(s.level);
    final sortedLevels = [-1, ...levels.toList()..sort()];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Banner informativo (paso opcional) ───────────────────────
      Container(
        width: double.infinity,
        color: AppTheme.primary.withOpacity(0.08),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          const Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This step is optional — you can add spells later from your character sheet.',
              style: GoogleFonts.lato(
                  color: AppTheme.primary, fontSize: 12),
            ),
          ),
        ]),
      ),

      // ── Contadores de selección ──────────────────────────────────
      Container(
        color: AppTheme.surface,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Choose Spells',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Row(children: [
            // Cantrips counter
            _SlotCounter(
              label: 'Cantrips',
              current: vm.selectedCantripCount,
              max: vm.maxCantrips,
            ),
            const SizedBox(width: 12),
            // Spells counter
            _SlotCounter(
              label: 'Spells',
              current: vm.selectedSpellCount,
              max: vm.maxSpellsKnown,
            ),
          ]),
        ]),
      ),

      // ── Buscador ─────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search spells...',
            hintStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
            prefixIcon:
                const Icon(Icons.search, color: AppTheme.primary, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),

      // ── Filtro por nivel ─────────────────────────────────────────
      SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          itemCount: sortedLevels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final lvl = sortedLevels[i];
            final label = lvl == -1
                ? 'All'
                : lvl == 0
                    ? 'Cantrips'
                    : 'Lv $lvl';
            final selected = _filterLevel == lvl;
            return GestureDetector(
              onTap: () => setState(() => _filterLevel = lvl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      selected ? AppTheme.primary : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          selected ? AppTheme.primary : AppTheme.divider),
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
      const SizedBox(height: 4),
      const Divider(height: 1),

      // ── Lista de hechizos ────────────────────────────────────────
      Expanded(
        child: filtered.isEmpty
            ? Center(
                child: Text('No spells found',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 14)))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) => _SpellTile(spell: filtered[i], vm: vm),
              ),
      ),
    ]);
  }
}

// ── Contador de slots ─────────────────────────────────────────────────────────

class _SlotCounter extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  const _SlotCounter(
      {required this.label, required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final full = current >= max;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: full
            ? AppTheme.primary.withOpacity(0.15)
            : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: full ? AppTheme.primary : AppTheme.divider),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          full ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: full ? AppTheme.primary : AppTheme.textSecondary,
        ),
        const SizedBox(width: 5),
        Text('$label: $current / $max',
            style: GoogleFonts.lato(
                color: full ? AppTheme.primary : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: full ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}

// ── Spell Tile ────────────────────────────────────────────────────────────────

class _SpellTile extends StatelessWidget {
  final SpellOption spell;
  final CharacterCreatorViewModel vm;
  const _SpellTile({required this.spell, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.selectedSpellIds.contains(spell.id);
    // ¿Está bloqueado (límite alcanzado y no está seleccionado)?
    final isBlocked = !isSelected &&
        (spell.isCantrip ? vm.cantripLimitReached : vm.spellLimitReached);

    return GestureDetector(
      // Tap en la card  toggle selección
      onTap: isBlocked ? null : () => vm.toggleSpell(spell.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.12)
              : isBlocked
                  ? AppTheme.surfaceVariant.withOpacity(0.5)
                  : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : isBlocked
                    ? AppTheme.divider
                    : AppTheme.surfaceVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          // Checkbox visual
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary
                  : isBlocked
                      ? AppTheme.divider
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : isBlocked
                        ? AppTheme.divider
                        : AppTheme.textSecondary,
                width: 1.5,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check,
                    size: 14, color: AppTheme.background)
                : isBlocked
                    ? const Icon(Icons.block,
                        size: 12, color: AppTheme.textSecondary)
                    : null,
          ),
          const SizedBox(width: 12),

          // Info del hechizo
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(spell.name,
                          style: GoogleFonts.cinzel(
                              color: isBlocked
                                  ? AppTheme.textSecondary
                                  : isSelected
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    // Level badge — primero, con color propio
                    _LvTag(
                      label: spell.isCantrip ? 'Cantrip' : 'Lv ${spell.level}',
                      isCantrip: spell.isCantrip,
                    ),
                    if (spell.school != null) ...[
                      const SizedBox(width: 4),
                      _Tag(spell.school!),
                    ],
                    if (spell.castingTime != null) ...[
                      const SizedBox(width: 4),
                      _Tag(spell.castingTime!),
                    ],
                  ]),
                ]),
          ),

          // Botón de detalle — separado del toggle
          IconButton(
            icon: const Icon(Icons.info_outline,
                color: AppTheme.textSecondary, size: 20),
            padding: const EdgeInsets.only(left: 8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'View details',
            onPressed: () => _showDetail(context),
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
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                // Título y nivel
                Text(spell.name,
                    style: GoogleFonts.cinzel(
                        color: AppTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${spell.isCantrip ? 'Cantrip' : 'Level ${spell.level} spell'}'
                  '${spell.school != null ? ' · ${spell.school}' : ''}',
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
                style:
                    GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 12)),
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

class _LvTag extends StatelessWidget {
  final String label;
  final bool isCantrip;
  const _LvTag({required this.label, required this.isCantrip});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isCantrip
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCantrip
                ? AppTheme.primary.withOpacity(0.4)
                : AppTheme.accent.withOpacity(0.4),
            width: 0.8,
          ),
        ),
        child: Text(label,
            style: GoogleFonts.cinzel(
                color: isCantrip ? AppTheme.primary : AppTheme.accent,
                fontSize: 9,
                fontWeight: FontWeight.bold)),
      );
}
