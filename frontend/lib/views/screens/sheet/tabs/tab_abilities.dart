import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:google_fonts/google_fonts.dart';

class TabAbilities extends StatelessWidget {
  final PlayerCharacter c;
  const TabAbilities({super.key, required this.c});

  static const _abilities = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA'];
  static const _abilityNames = {
    'STR': 'Strength',
    'DEX': 'Dexterity',
    'CON': 'Constitution',
    'INT': 'Intelligence',
    'WIS': 'Wisdom',
    'CHA': 'Charisma',
   };

   @override
   Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        //Ability Score Grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: _abilities.map((a){
            final score = c.abilityScores[a] ?? 10;
            final mod = c.modifier(a);
            return _AbilityCard(
              abbr: a,
              name: _abilityNames[a]!,
              score: score,
              mod: mod,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Passive Skills
        _SectionCard(
          title: 'Passive Skills',
          child: Column(children: [
            _PassiveRow('Passive Perception', c.passivePerception),
            _PassiveRow('Passive Investigation', c.passiveInvestigation),
            _PassiveRow('Passive Insight', c.passiveInsight),
          ]),
        ),
        const SizedBox(height: 12),

        // Spell Stats (only if relevant)
        if (c.spellSaveDC > 8 || c.spellAttackBonus != 0)
          _SectionCard(
            title: 'Spellcasting',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LabelValue('Spell Save DC',
                  '${c.spellSaveDC}'),
                _LabelValue('Spell Attack Bonus',
                  c.spellAttackBonus >= 0
                    ? '+${c.spellAttackBonus}' : '${c.spellAttackBonus}'),
                _LabelValue('Max Prepared Spells',
                  '${c.maxPreparedSpells}'),
              ],
            ),
          ),
      ],
    );
   }
}

class _AbilityCard extends StatelessWidget {
  final String abbr;
  final String name;
  final int score;
  final int mod;
  const _AbilityCard(
      {required this.abbr, required this.name, required this.score, required this.mod});
  
  @override
  Widget build(BuildContext context) {
    final modLabel = mod >= 0 ? '+$mod' : '$mod';
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(abbr,
          style: GoogleFonts.cinzel(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(modLabel,
          style: GoogleFonts.cinzel(
            color: AppTheme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.surfaceVariant),
            ),
            child: Text('$score',
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(name,
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary, fontSize: 9),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.surfaceVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: GoogleFonts.cinzel(
          color: AppTheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1)),
        const Divider(color: AppTheme.divider, height: 16),
        child,
      ],
    ),
  );
}

class _PassiveRow extends StatelessWidget {
  final String label;
  final int value;
  const _PassiveRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                color: AppTheme.textPrimary, fontSize: 14)),
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.background,
            border: Border.all(color: AppTheme.primary, width: 1.5),
          ),
          child: Center(
            child: Text('$value',
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value,
    style: GoogleFonts.cinzel(
      color: AppTheme.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold)),
    const SizedBox(height: 2),
    Text(label,
      style: GoogleFonts.lato(
        color: AppTheme.textSecondary, fontSize: 10),
        textAlign: TextAlign.center),      
  ]);
}