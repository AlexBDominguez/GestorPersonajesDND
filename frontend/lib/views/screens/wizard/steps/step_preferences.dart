import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/viewmodels/wizard/character_creator_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StepPreferences extends StatelessWidget{
  const StepPreferences({super.key});

  static String _tr(BuildContext context, {required String en, required String es, required String gl}) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'es') return es;
    if (code == 'gl') return gl;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text(_tr(context, en: 'Character Basics', es: 'Basicos del personaje', gl: 'Basicos da personaxe'),
        style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 4),
        Text(_tr(context, en: 'Give your character a name and set some preferences.', es: 'Pon un nombre al personaje y define algunas preferencias.', gl: 'Pon un nome ao personaxe e define algunhas preferencias.'),
          style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 28),

          //- Nombre
          TextFormField(
          initialValue: vm.characterName,
          decoration: InputDecoration(
            labelText: '${_tr(context, en: 'Character name', es: 'Nombre del personaje', gl: 'Nome da personaxe')} *',
            prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primary),
          ),
          style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 16),
          onChanged: vm.setName,
        ),
        const SizedBox(height: 28),

          // Ability Scores display preference
          Text(_tr(context, en: 'Ability Scores display', es: 'Vista de atributos', gl: 'Vista de atributos'),
            style: GoogleFonts.libreBaskerville(
              color: AppTheme.textPrimary,
              fontSize: 14, fontWeight: FontWeight.bold
            )),
          const SizedBox(height: 4),
          Text(_tr(context, en: 'How ability scores appear in the character sheet.', es: 'Como se muestran los atributos en la hoja de personaje.', gl: 'Como se mostran os atributos na folla de personaxe.'),
            style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _DisplayModeTile(
              title: '20',
              subtitle: '+5',
              label: _tr(context, en: 'Score on top', es: 'Puntuacion arriba', gl: 'Puntuacion arriba'),
              selected: vm.abilityDisplayMode == 'SCORES_TOP',
              onTap: () => vm.setAbilityDisplayMode('SCORES_TOP'),
            )),
            const SizedBox(width: 10),
            Expanded(child: _DisplayModeTile(
              title: '+5',
              subtitle: '20',
              label: _tr(context, en: 'Modifier on top', es: 'Modificador arriba', gl: 'Modificador arriba'),
              selected: vm.abilityDisplayMode == 'MODIFIERS_TOP',
              onTap: () => vm.setAbilityDisplayMode('MODIFIERS_TOP'),
            )),
          ]),

          // [DISABLED] Progression system (XP vs Milestone) — omitido by design.
          // Siempre se usa Milestone. Para reactivar, descomentar este bloque.
          /*
          Text('Progression system', ...),
          _OptionTile(title: 'Milestone', ...),
          _OptionTile(title: 'Experience Points (XP)', ...),
          const SizedBox(height: 28),
          */

          // [DISABLED] Encumbrance — omitido by design.
          // Para reactivar, descomentar este bloque y restaurar _OptionTile.
          /*
          Text('Optional rules', ...),
          SwitchListTile(value: vm.useEncumbrance, onChanged: vm.setEncumbrance),
          */
      ]),
    );
  }
}

// ── Tile de selección de modo de visualización ────────────────────────────────

class _DisplayModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DisplayModeTile({
    required this.title, required this.subtitle, required this.label,
    required this.selected, required this.onTap,
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
          // Mock ability card preview
          Container(
            width: 44, height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: selected ? AppTheme.primary : AppTheme.surfaceVariant),
            ),
            child: Text(title,
                style: GoogleFonts.libreBaskerville(
                  color: selected ? AppTheme.primary : AppTheme.textPrimary,
                  fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Container(
            width: 36, height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (selected ? AppTheme.primary : AppTheme.textSecondary).withOpacity(0.18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(subtitle,
                style: GoogleFonts.lato(
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                  fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                fontSize: 11, fontWeight: FontWeight.w600)),
          if (selected) ...[
            const SizedBox(height: 4),
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
          ],
        ]),
      ),
    );
  }
}