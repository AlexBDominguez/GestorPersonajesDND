import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class TabAbilities extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabAbilities({super.key, required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    final c = character;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        
        // 1.1 Ability Scores
        // ────────────────────────────────
        _SectionTitle('Ability Scores'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: CharacterSheetViewModel.abilityNames
              .map((a) => _AbilityCell(ability: a, character: c, modifiersTop: c.abilityDisplayMode == 'MODIFIERS_TOP'))
              .toList(),
        ),
        const SizedBox(height: 24),

        //1.2 Saving Throws
        // ────────────────────────────────
        _SectionTitle('Saving Throws'),
        const SizedBox(height: 12),
        // 3 filas x 2 columnas
        ...List.generate(3, (row){
          final left = CharacterSheetViewModel.abilityNames[row * 2];
          final right = CharacterSheetViewModel.abilityNames[row * 2 + 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: _SavingThrowRow(ability: left, character: c)),
              const SizedBox(width: 12),
              Expanded(child: _SavingThrowRow(ability: right, character: c)),
            ]),
          );
        }),
        const SizedBox(height: 24),

        // 1.3 Senses
        // ────────────────────────────────
        _SectionTitle('Senses'),
        const SizedBox(height: 12),
        _SenseRow(value: c.passivePerception, label: 'Passive Perception'),
        _SenseRow(value: c.passiveInvestigation, label: 'Passive Investigation'),
        _SenseRow(value: c.passiveInsight, label: 'Passive Insight'),
        // Darkvision and other special senses from racial traits
        ...vm.racialTraits
            .where((t) {
              final n = t.name.toLowerCase();
              return n.contains('darkvision') ||
                  n.contains('blindsight') ||
                  n.contains('tremorsense') ||
                  n.contains('truesight') ||
                  n.contains('superior darkvision');
            })
            .map((t) => _SpecialSenseRow(name: t.name, description: t.description)),
        const SizedBox(height: 4),        
        
      ]),
    );
  }
}

// Ability Cell
class _AbilityCell extends StatelessWidget{
  final String ability;
  final PlayerCharacter character;
  final bool modifiersTop;
  const _AbilityCell({required this.ability, required this.character, this.modifiersTop = false});

  @override
  Widget build(BuildContext context){
    final score = character.abilityScores[ability] ?? 10;
    final mod = character.modifier(ability);
    final modLbl = mod >= 0 ? '+$mod' : '$mod';

    // Big box: score or modifier depending on preference
    final bigLabel  = modifiersTop ? modLbl : '$score';
    final smallLabel = modifiersTop ? '$score' : modLbl;
    final bigFontSize  = modifiersTop ? 18.0 : 18.0;
    final smallFontSize = modifiersTop ? 12.0 : 12.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ability,
            style: GoogleFonts.cinzel(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1
            )),
          const SizedBox(height: 6),
          // Primary value — rectangle box
          Container(
            width: 48, height: 34,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.primary.withOpacity(0.6)),
            ),
            child: Center(
              child: Text(bigLabel,
                style: GoogleFonts.cinzel(
                  color: AppTheme.textPrimary,
                  fontSize: bigFontSize,
                  fontWeight: FontWeight.bold
                )),
            ),
          ),
          const SizedBox(height: 6),
          // Secondary value — ellipse
          Container(
            width: 38, height: 22,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppTheme.primary, width: 1),
            ),
            child: Center(
              child: Text(smallLabel,
                style: GoogleFonts.lato(
                  color: AppTheme.primary,
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.bold
                )),
            ),
          ),
        ]),
    );
  }
}

// Saving Throw row
class _SavingThrowRow extends StatelessWidget {
  final String ability;           // "STR", "DEX", etc. (uppercase)
  final PlayerCharacter character;
  const _SavingThrowRow({required this.ability, required this.character});

  @override
  Widget build(BuildContext context){
    final savingThrow = character.savingThrows
        .where((st) => st.abilityScore.toUpperCase() == ability)
        .firstOrNull;

    final bonus = savingThrow?.bonus ?? character.modifier(ability);
    final proficient = savingThrow?.proficient ?? false;
    final lbl = bonus >= 0 ? '+$bonus' : '$bonus';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: proficient
              ? AppTheme.primary.withOpacity(0.5)
              : AppTheme.surfaceVariant,
        ),
      ),
      child: Row(children: [
        // Proficiency dot
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: proficient ? AppTheme.primary : Colors.transparent,
            border: Border.all(
                color: proficient
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
                width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            CharacterSheetViewModel.abilityFull[ability] ?? ability,
            style: GoogleFonts.lato(
              color: proficient ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 12),
          ),
        ),
            Text(lbl, style: GoogleFonts.cinzel(
            color: proficient ? AppTheme.primary : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: proficient ? FontWeight.bold : FontWeight.normal,
            )),
      ]),
    );
  }
}

class _SenseRow extends StatelessWidget {
  final int value;
  final String label;
  const _SenseRow({required this.value, required this.label});

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Row(children: [
        SizedBox(
          width: 36,
          child: Text('$value',
            style: GoogleFonts.cinzel(
              color: AppTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
            ),
            const SizedBox(width: 12),
            Text(label,
              style: GoogleFonts.lato(
                color: AppTheme.textPrimary, fontSize: 13
              )),
      ]),
    );
  }
}

// Special sense row (Darkvision, Blindsight, etc.) from racial traits
class _SpecialSenseRow extends StatelessWidget {
  final String name;
  final String description;
  const _SpecialSenseRow({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.visibility_outlined,
            color: AppTheme.primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: GoogleFonts.cinzel(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            if (description.isNotEmpty)
              Text(description,
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      height: 1.4)),
          ]),
        ),
      ]),
    );
  }
}

// Section title
class _SectionTitle extends StatelessWidget{
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title,
      style: GoogleFonts.cinzel(
        color: AppTheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1)),
    const SizedBox(width: 10),
    const Expanded(child: Divider(color: AppTheme.surfaceVariant))
  ]);
}
