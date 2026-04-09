import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class TabCombat extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabCombat({super.key, required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    final c = character;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // 3.1 Attack Bonuses (resumen rápido)
        _SectionTitle('Attack Bonuses'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _BonusPill(label: 'Melee', 
            value: vm.signedInt(c.meleeAttackBonus))),
          const SizedBox(width: 10),
          Expanded(child: _BonusPill(label: 'Ranged', 
            value: vm.signedInt(c.rangedAttackBonus))),
            const SizedBox(width: 10),
            Expanded(child: _BonusPill(label: 'Finesse', 
              value: vm.signedInt(c.finesseAttackBonus))),
        ]),
        const SizedBox(height: 24),

        // 3.2 Actions in Combat
        _SectionTitle('Actions'),
        const SizedBox(height: 10),
        _ActionsList(actions: kStandardActions),
        const SizedBox(height: 24),

        // 3.3 Bonus Actions
        _SectionTitle('Bonus Actions'),
        const SizedBox(height: 10),
        _ActionsList(actions: kBonusActions),
        const SizedBox(height: 24),

        // 3.4 Reactions
        _SectionTitle('Reactions'),
        const SizedBox(height: 10),
        _ActionsList(actions: kReactions),
        const SizedBox(height: 24),

        //3.5 Death Saves (si es aplicable)
        if(!c.isConscious || c.isDying || c.currentHp == 0) ...[
          _SectionTitle('Death Saving Throws'),
          const SizedBox(height: 10),
          _DeathSavesRow(
            successes: c.deathSaveSuccesses, 
            failures: c.deathSaveFailures
          ),
          const SizedBox(height: 16),
        ],

        //3.6 Hit Dice
        _SectionTitle('Hit Dice'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: Row(children: [
            const Icon(Icons.casino_outlined, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Text('Available Hit Dice: ',
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
            Text('${c.availableHitDice}',
              style: GoogleFonts.cinzel(
                color: AppTheme.primary,
                fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('Speed: ${c.currentSpeed} ft',
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 12)),
              
          ]),
        ),

        //3.7 Quick Spells (cantrips + action/bonus action spells)
        if (c.characterSpells.isNotEmpty)...[
          const SizedBox(height: 24),
          _SectionTitle('Quick Spells'),
          const SizedBox(height: 10),
          _QuickSpellsList(spells: c.characterSpells),
        ],
        const SizedBox(height: 16),
        ]),
      );      
        
  }
}

//Datos estáticos D&D 5e hardcoded.
const kStandardActions = [
  _ActionEntry(name: 'Attack', 
    desc: 'Make one weapon attack.'),
  _ActionEntry(name: 'Dash', 
    desc: 'Double your movement speed'),
  _ActionEntry(name: 'Disengage', 
    desc: 'Your movement doesn\'t provoke oportunity attacks.'),
  _ActionEntry(name: 'Dodge', 
    desc: 'Attack against you have disadvantage.'),
  _ActionEntry(name: 'Grapple', 
    desc: 'Special melee attack - Athletics vs. Athletics/Acrobatics'),
  _ActionEntry(name: 'Help', 
    desc: 'Give an ally advantage on a check or attack.'),
  _ActionEntry(name: 'Hide', 
    desc: 'Make a Stealth check to hide.'),
  _ActionEntry(name: 'Improvise', 
    desc: 'Do something not covered by other actions. DM decides outcome.'),
  _ActionEntry(name: 'Influence', 
    desc: 'Make a Persuasion, Deception or Intimidation check.'),
  _ActionEntry(name: 'Magic', 
    desc: 'Cast a spell or use a magic item.'),
  _ActionEntry(name: 'Ready', 
    desc: 'Prepare a reaction for a specific trigger.'),
  _ActionEntry(name: 'Search', 
    desc: 'Make a Perception or Investigation check.'),
  _ActionEntry(name: 'Shove', 
    desc: 'Special melee attack to push or knock prone'),
  _ActionEntry(name: 'Study', 
    desc: 'Make an Intelligence check to recall information'),
  _ActionEntry(name: 'Utilize', 
    desc: 'Use an object or device.'),
 ];

const kBonusActions = [
  _ActionEntry(name: 'Off-Hand Attack', 
    desc: 'Attack with a light off-hand weapon (no modifier to damage)'),
  _ActionEntry(name: 'Bonus Action Spell', 
    desc: 'Cast a spell with a casting time of 1 Bonus Action'),
];

const kReactions = [
  _ActionEntry(name: 'Opportunity Attack',
    desc: 'When a creature moves out of your reach, make one melee attack'),
  _ActionEntry(name: 'Readied Action',
    desc: 'Take the action you prepared with the Ready Action'),
];

//Widgets
class _BonusPill extends StatelessWidget{
  final String label;
  final String value;
  const _BonusPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(children:[
        Text(value,
          style: GoogleFonts.cinzel(
            color: AppTheme.primary,
            fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary, fontSize: 11)),
      ]),
    );
  }
}

class _ActionsList extends StatelessWidget{
  final List<_ActionEntry> actions;
  const _ActionsList({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (_, __) => 
          const Divider(height: 1, color: AppTheme.divider),
        itemBuilder: (_, i){
          final a = actions[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.name, style: GoogleFonts.cinzel(
                        color: AppTheme.textPrimary,
                        fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(a.desc,
                        style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 11)),                                              
                    ]),
                ),              
            ]),
          );
        },
      ),
    );
  }
}

class _ActionEntry{
  final String name;
  final String desc;
  const _ActionEntry({required this.name, required this.desc});
}

class _DeathSavesRow extends StatelessWidget{
  final int successes;
  final int failures;
  const _DeathSavesRow({required this.successes, required this.failures});

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
      ),
      child: Row(children:[
        //Successes
        Expanded(
          child: Column(children: [
            Text('Successes', style: GoogleFonts.lato(
              color: AppTheme.primary, fontSize: 11,
              fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => _SaveDot(
                filled: i < successes,
                color: AppTheme.primary))),            
          ])),
          Container(width: 1, height: 40, color: AppTheme.divider),
          //Failures
          Expanded(
            child: Column(children: [
              Text('Failures',
                style: GoogleFonts.lato(
                  color: AppTheme.accent, fontSize: 11,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => _SaveDot(
                  filled: i < failures, color: AppTheme.accent))),
        ]))
      ]),
    );
  }
}

class _SaveDot extends StatelessWidget{
  final bool filled;
  final Color color;
  const _SaveDot({required this.filled, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    width: 18, height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: filled ? color: Colors.transparent,
      border: Border.all(color: color, width: 2),
    ),
  );
}

class _SectionTitle extends StatelessWidget{
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title, style: GoogleFonts.cinzel(
        color: AppTheme.primary, fontSize: 14,
        fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
      ]);    
}

class _QuickSpellsList extends StatelessWidget {
  final List<CharacterSpell> spells;
  const _QuickSpellsList({required this.spells});

  @override
  Widget build(BuildContext context) {
    // Cantrips primero, luego spells preparados ordenados por nivel
    final cantrips  = spells.where((s) => s.isCantrip).toList();
    final prepared  = spells.where((s) => !s.isCantrip && s.prepared).toList()
      ..sort((a, b) => a.level.compareTo(b.level));
    final combined  = [...cantrips, ...prepared];

    if (combined.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Text('No cantrips or prepared spells.',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: combined.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppTheme.divider),
        itemBuilder: (_, i) {
          final s = combined[i];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              // Nivel badge
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    s.isCantrip ? '∞' : '${s.level}',
                    style: GoogleFonts.cinzel(
                        color: AppTheme.primary,
                        fontSize: s.isCantrip ? 14 : 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: GoogleFonts.cinzel(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      if (s.castingTime != null)
                        Text(s.castingTime!,
                            style: GoogleFonts.lato(
                                color: AppTheme.textSecondary,
                                fontSize: 11)),
                    ]),
              ),
              if (s.school != null)
                Text(s.school!,
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 11)),
            ]),
          );
        },
      ),
    );
  }
}





