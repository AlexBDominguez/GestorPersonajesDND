import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/l10n/app_strings.dart';
import 'package:gestor_personajes_dnd/l10n/dnd_terms.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/wizard/character_creator_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

String _tr(BuildContext context, {required String en, required String es, required String gl}) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'es') return es;
  if (code == 'gl') return gl;
  return en;
}

class StepSpells extends StatefulWidget {
  const StepSpells({super.key});

  @override
  State<StepSpells> createState() => _StepSpellsState();
}

class _StepSpellsState extends State<StepSpells> {
  int _filterLevel = -1;
  final _searchCtrl = TextEditingController();
  // 0 = class spells, 1 = magical secrets, 2 = additional magical secrets (lore)
  int _activeSection = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _switchSection(int section) {
    setState(() {
      _activeSection = section;
      _filterLevel = -1;
      _searchCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();
    final s = AppStrings.of(context);

    final bool hasMagicalSecrets = vm.magicalSecretsSlots > 0;
    final bool hasLoreExtras = vm.additionalMagicalSecretsSlots > 0;
    final int sectionCount = 1 + (hasMagicalSecrets ? 1 : 0) + (hasLoreExtras ? 1 : 0);

    // Clamp active section if class changed away from bard
    if (_activeSection >= sectionCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _activeSection = 0));
    }

    if (vm.isLoading || (_activeSection >= 1 && vm.isLoadingMagicalSecrets)) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    // Determine active pool and callbacks based on current section
    final List<SpellOption> pool;
    final bool Function(SpellOption) isSelectedFn;
    final bool Function(SpellOption) isBlockedFn;
    final void Function(int) onToggleFn;

    switch (_activeSection) {
      case 1:
        pool = vm.magicalSecretsPool;
        isSelectedFn = (s) => vm.magicalSecretIds.contains(s.id);
        isBlockedFn = (s) {
          if (vm.magicalSecretIds.contains(s.id)) return false;
          if (vm.selectedSpellIds.contains(s.id)) return true; // already picked
          return vm.magicalSecretLimitReached;
        };
        onToggleFn = vm.toggleMagicalSecret;
        break;
      case 2:
        pool = vm.magicalSecretsPool;
        isSelectedFn = (s) => vm.additionalMagicalSecretIds.contains(s.id);
        isBlockedFn = (s) {
          if (vm.additionalMagicalSecretIds.contains(s.id)) return false;
          if (vm.selectedSpellIds.contains(s.id)) return true;
          if (vm.magicalSecretIds.contains(s.id)) return true;
          return vm.additionalMagicalSecretLimitReached;
        };
        onToggleFn = vm.toggleAdditionalMagicalSecret;
        break;
      default: // 0 — class spells
        pool = vm.availableSpells;
        isSelectedFn = (s) => vm.selectedSpellIds.contains(s.id);
        isBlockedFn = (s) => !vm.selectedSpellIds.contains(s.id) &&
            (s.isCantrip ? vm.cantripLimitReached : vm.spellLimitReached);
        onToggleFn = vm.toggleSpell;
    }

    final filtered = pool.where((s) {
      final matchLevel = _filterLevel == -1 || s.level == _filterLevel;
      final query = _searchCtrl.text.toLowerCase();
      final matchSearch = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          (s.school?.toLowerCase().contains(query) ?? false);
      return matchLevel && matchSearch;
    }).toList()..sort((a, b) => a.level.compareTo(b.level));

    final levels = <int>{};
    for (final s in pool) levels.add(s.level);
    final sortedLevels = [-1, ...levels.toList()..sort()];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Header compacto ──────────────────────────────────────────────────
      Container(
        color: AppTheme.surface,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Fila: título + contadores
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Icon(Icons.auto_fix_high,
                color: AppTheme.primary, size: 16),
            const SizedBox(width: 6),
            Text(_tr(context, en: 'Choose Spells', es: 'Elegir conjuros', gl: 'Escoller conxuros'),
                style: GoogleFonts.libreBaskerville(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _SlotCounter(
                    label: _tr(context, en: 'Cantrips', es: 'Trucos', gl: 'Trucos'),
                    current: vm.selectedCantripCount,
                    max: vm.maxCantrips,
                  ),
                  const SizedBox(width: 6),
                  _SlotCounter(
                    label: s.tabSpells,
                    current: vm.selectedSpellCount,
                    max: vm.maxSpellsKnown,
                  ),
                  if (hasMagicalSecrets) ...[
                    const SizedBox(width: 6),
                    _SlotCounter(
                      label: _tr(context, en: 'Secrets', es: 'Secretos', gl: 'Segredos'),
                      current: vm.selectedMagicalSecretCount,
                      max: vm.magicalSecretsSlots,
                      highlight: true,
                    ),
                  ],
                  if (hasLoreExtras) ...[
                    const SizedBox(width: 6),
                    _SlotCounter(
                      label: _tr(context, en: 'Lore Extras', es: 'Extras de Saber', gl: 'Extras de Saber'),
                      current: vm.selectedAdditionalMagicalSecretCount,
                      max: vm.additionalMagicalSecretsSlots,
                      highlight: true,
                    ),
                  ],
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 8),

          // Selector de sección (bardo con Magical Secrets)
          if (sectionCount > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _SectionTab(
                  label: _tr(context, en: 'Class Spells', es: 'Conjuros de clase', gl: 'Conxuros de clase'),
                  selected: _activeSection == 0,
                  onTap: () => _switchSection(0),
                ),
                if (hasMagicalSecrets) ...[
                  const SizedBox(width: 6),
                  _SectionTab(
                    label: '${_tr(context, en: 'Magical Secrets', es: 'Secretos magicos', gl: 'Segredos maxicos')} (${vm.magicalSecretsSlots})',
                    selected: _activeSection == 1,
                    onTap: () => _switchSection(1),
                  ),
                ],
                if (hasLoreExtras) ...[
                  const SizedBox(width: 6),
                  _SectionTab(
                    label: '${_tr(context, en: 'Lore Extras', es: 'Extras de Saber', gl: 'Extras de Saber')} (2)',
                    selected: _activeSection == 2,
                    onTap: () => _switchSection(2),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 6),
          ],

          // Hint for magical secrets sections (compact)
          if (_activeSection == 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 13),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _tr(
                      context,
                      en: 'Choose ${vm.magicalSecretsSlots} spell(s) from any class list.',
                      es: 'Elige ${vm.magicalSecretsSlots} conjuro(s) de cualquier lista de clase.',
                      gl: 'Escolle ${vm.magicalSecretsSlots} conxuro(s) de calquera lista de clase.',
                    ),
                    style: GoogleFonts.lato(
                        color: Colors.amber.shade700, fontSize: 11),
                  ),
                ),
              ]),
            ),
          if (_activeSection == 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 13),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _tr(
                      context,
                      en: 'Additional Magical Secrets (College of Lore): 2 free spells.',
                      es: 'Secretos Magicos adicionales (Colegio del Saber): 2 conjuros libres.',
                      gl: 'Segredos Maxicos adicionais (Colexio do Saber): 2 conxuros libres.',
                    ),
                    style: GoogleFonts.lato(
                        color: Colors.amber.shade700, fontSize: 11),
                  ),
                ),
              ]),
            ),

          // Buscador + filtro nivel inline
          Row(children: [
            // Buscador
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: _activeSection == 0
                        ? _tr(context, en: 'Search spells...', es: 'Buscar conjuros...', gl: 'Buscar conxuros...')
                        : _tr(context, en: 'Search all spells...', es: 'Buscar todos los conjuros...', gl: 'Buscar todos os conxuros...'),
                    hintStyle: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 12),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.primary, size: 16),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 14),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceVariant,
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 6),

          // Filtro por nivel — scroll horizontal
          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              children: sortedLevels.map((lvl) {
                final label = lvl == -1
                  ? _tr(context, en: 'All', es: 'Todos', gl: 'Todos')
                    : lvl == 0
                    ? _tr(context, en: 'Cantrips', es: 'Trucos', gl: 'Trucos')
                        : 'Lv $lvl';
                final selected = _filterLevel == lvl;
                return GestureDetector(
                  onTap: () => setState(() => _filterLevel = lvl),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.divider,
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.libreBaskerville(
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
        ]),
      ),
      const Divider(height: 1),

      // ── Lista de hechizos ────────────────────────────────────────
      Expanded(
        child: filtered.isEmpty
            ? Center(
            child: Text(_tr(context, en: 'No spells found', es: 'No se encontraron conjuros', gl: 'Non se atoparon conxuros'),
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 14)))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final s = filtered[i];
                  return _SpellTile(
                    spell: s,
                    isSelected: isSelectedFn(s),
                    isBlocked: isBlockedFn(s),
                    onTap: isBlockedFn(s) ? null : () => onToggleFn(s.id),
                  );
                },
              ),
      ),
    ]);
  }
}

// ── Selector de sección ───────────────────────────────────────────────────────

class _SectionTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SectionTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.divider,
          ),
          boxShadow: selected ? [
            BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 4, offset: const Offset(0, 2)),
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Contador de slots ─────────────────────────────────────────────────────────

class _SlotCounter extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final bool highlight;
  const _SlotCounter({
    required this.label,
    required this.current,
    required this.max,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final full = current >= max;
    final color = highlight ? Colors.amber.shade700 : AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: full
            ? color.withOpacity(0.15)
            : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: full ? color : AppTheme.divider),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          full ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: full ? color : AppTheme.textSecondary,
        ),
        const SizedBox(width: 5),
        Text('$label: $current / $max',
            style: GoogleFonts.lato(
                color: full ? color : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: full ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}

// ── Spell Tile ────────────────────────────────────────────────────────────────

class _SpellTile extends StatelessWidget {
  final SpellOption spell;
  final bool isSelected;
  final bool isBlocked;
  final VoidCallback? onTap;
  const _SpellTile({
    required this.spell,
    required this.isSelected,
    required this.isBlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                ? const Icon(Icons.check, size: 14, color: AppTheme.background)
                : isBlocked
                    ? const Icon(Icons.block, size: 12, color: AppTheme.textSecondary)
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
                          style: GoogleFonts.libreBaskerville(
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
                    _LvTag(
                      label: spell.isCantrip
                          ? _tr(context, en: 'Cantrip', es: 'Truco', gl: 'Truco')
                          : 'Lv ${spell.level}',
                      isCantrip: spell.isCantrip,
                    ),
                    if (spell.school != null) ...[const SizedBox(width: 4), _Tag(localizeSpellSchool(context, spell.school!))],
                    if (spell.castingTime != null) ...[const SizedBox(width: 4), _Tag(spell.castingTime!)],
                  ]),
                ]),
          ),

          // Botón de detalle
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 20),
            padding: const EdgeInsets.only(left: 8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: _tr(context, en: 'View details', es: 'Ver detalles', gl: 'Ver detalles'),
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
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${spell.isCantrip ? _tr(context, en: 'Cantrip', es: 'Truco', gl: 'Truco') : '${_tr(context, en: 'Level', es: 'Nivel', gl: 'Nivel')} ${spell.level} ${_tr(context, en: 'spell', es: 'conjuro', gl: 'conxuro')}'}'
                  '${spell.school != null ? ' · ${localizeSpellSchool(context, spell.school!)}' : ''}',
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                // Propiedades
                if (spell.castingTime != null)
                  _DetailRow(_tr(context, en: 'Casting Time', es: 'Tiempo de lanzamiento', gl: 'Tempo de lanzamento'), spell.castingTime!),
                if (spell.range != null)
                  _DetailRow(_tr(context, en: 'Range', es: 'Alcance', gl: 'Alcance'), spell.range!),
                if (spell.duration != null)
                  _DetailRow(_tr(context, en: 'Duration', es: 'Duracion', gl: 'Duracion'), spell.duration!),
                if (spell.components != null)
                  _DetailRow(_tr(context, en: 'Components', es: 'Componentes', gl: 'Compoñentes'), spell.components!),
                if (spell.description != null &&
                    spell.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(_tr(context, en: 'Description', es: 'Descripcion', gl: 'Descricion'),
                      style: GoogleFonts.libreBaskerville(
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
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.4),
            width: 0.8,
          ),
        ),
        child: Text(label,
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary,
                fontSize: 9,
                fontWeight: FontWeight.bold)),
      );
}
