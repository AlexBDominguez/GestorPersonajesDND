import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/content_source.dart';
import 'package:gestor_personajes_dnd/viewmodels/wizard/character_creator_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StepPreferences extends StatelessWidget {
  const StepPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text('Character Basics', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text('Give your character a name.',
            style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 28),

        TextFormField(
          initialValue: vm.characterName,
          decoration: const InputDecoration(
            labelText: 'Character name *',
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.primary),
          ),
          style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 16),
          onChanged: vm.setName,
        ),
        const SizedBox(height: 32),

        // ── Content Sources ──────────────────────────────────────────────────
        Text('Content Sources',
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Choose which sourcebooks are available when selecting race, class, background and more.',
          style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (vm.sourcesLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
            ),
          )
        else if (vm.availableContentSources.isEmpty)
          Text('No sources available.',
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13))
        else
          _SourcesGrid(
            sources: vm.availableContentSources,
            selectedSources: vm.selectedSources,
            onToggle: vm.toggleSource,
          ),

        const SizedBox(height: 32),

        // ── Ability Scores display ───────────────────────────────────────────
        Text('Ability Scores display',
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('How ability scores appear in the character sheet.',
            style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _DisplayModeTile(
            title: '20',
            subtitle: '+5',
            label: 'Score on top',
            selected: vm.abilityDisplayMode == 'SCORES_TOP',
            onTap: () => vm.setAbilityDisplayMode('SCORES_TOP'),
          )),
          const SizedBox(width: 10),
          Expanded(
              child: _DisplayModeTile(
            title: '+5',
            subtitle: '20',
            label: 'Modifier on top',
            selected: vm.abilityDisplayMode == 'MODIFIERS_TOP',
            onTap: () => vm.setAbilityDisplayMode('MODIFIERS_TOP'),
          )),
        ]),
      ]),
    );
  }
}

// ── Sources grid ──────────────────────────────────────────────────────────────

class _SourcesGrid extends StatelessWidget {
  final List<ContentSource> sources;
  final Set<String> selectedSources;
  final void Function(String) onToggle;

  const _SourcesGrid({
    required this.sources,
    required this.selectedSources,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sources.map((s) => _SourceChip(
        source: s,
        selected: selectedSources.contains(s.shortName),
        onToggle: () => onToggle(s.shortName),
      )).toList(),
    );
  }
}

/// Etiqueta visible para el código corto de una source. Igual al shortName real
/// salvo "AI" (Acquisitions Incorporated), que se confunde con "inteligencia
/// artificial" al verse solo — el shortName real ("AI") no cambia, sigue siendo
/// lo que se usa para filtrar/seleccionar sources, solo cambia lo que se muestra.
String _sourceChipLabel(String shortName) =>
    shortName == 'AI' ? 'Ac. Inc.' : shortName;

class _SourceChip extends StatelessWidget {
  final ContentSource source;
  final bool selected;
  final VoidCallback onToggle;

  const _SourceChip({
    required this.source,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = source.isBase;
    final effectiveSelected = isLocked ? true : selected;

    return Tooltip(
      message: source.fullName,
      child: GestureDetector(
        onTap: isLocked ? null : onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: effectiveSelected
                ? AppTheme.primary.withOpacity(0.15)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: effectiveSelected
                  ? AppTheme.primary
                  : AppTheme.surfaceVariant,
              width: effectiveSelected ? 2 : 1,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (isLocked)
              const Icon(Icons.lock, size: 12, color: AppTheme.primary)
            else
              Icon(
                effectiveSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 16,
                color: effectiveSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            const SizedBox(width: 6),
            Text(
              _sourceChipLabel(source.shortName),
              style: GoogleFonts.libreBaskerville(
                color: effectiveSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: effectiveSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Display mode tile ─────────────────────────────────────────────────────────

class _DisplayModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DisplayModeTile({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.surfaceVariant),
            ),
            child: Text(title,
                style: GoogleFonts.libreBaskerville(
                    color: selected ? AppTheme.primary : AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Container(
            width: 36,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (selected ? AppTheme.primary : AppTheme.textSecondary)
                  .withOpacity(0.18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(subtitle,
                style: GoogleFonts.lato(
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          if (selected) ...[
            const SizedBox(height: 4),
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
          ],
        ]),
      ),
    );
  }
}
