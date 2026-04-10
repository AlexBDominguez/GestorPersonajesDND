import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

//Anchos compartidos con tab_spells
const double _kHitDcW = 62.0;
const double _kDmgW   = 80.0;
const double _kColGap = 8.0;

class TabCombat extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabCombat({super.key, required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    final c = character;

    //Spells por tipo de casting time
    final actionSpells = c.characterSpells.where(_isAction).toList();
    final bonusActionSpells = c.characterSpells.where(_isBonusAction).toList();
    final reactionSpells = c.characterSpells.where(_isReaction).toList();

    //Cantrips que se lanzan como action (van en la tabla de Actions)
    final actionCantrips = actionSpells.where((s) => s.isCantrip).toList();
    final actionLeveled = actionSpells.where((s) => !s.isCantrip && s.prepared).toList();
    final combatSpells = [...actionCantrips, ...actionLeveled]..sort((a, b) => a.level.compareTo(b.level));

    final bonusSpells = bonusActionSpells
        .where((s) => s.isCantrip || s.prepared)
        .toList()
      ..sort((a, b) => a.level.compareTo(b.level));

    final reactionSpellsFiltered = reactionSpells
        .where((s) => s.isCantrip || s.prepared)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // --ACTIONS--
        _SectionTitle('Actions'),
        const SizedBox(height: 8),

        //Tabla de hechizos de acción
        if (combatSpells.isNotEmpty) ...[
          _AttackTable(spells: combatSpells, vm: vm),
          const SizedBox(height: 10),
        ],

        //Card colapsable de acciones estándar
        _ActionsCard(
          title: 'Standard Actions',
          actions: kStandardActions,
          context: context,
        ),
        const SizedBox(height: 20),

        // --BONUS ACTIONS--
        _SectionTitle('Bonus Actions'),
        const SizedBox(height: 8),

        if (bonusSpells.isNotEmpty) ...[
          _AttackTable(spells: bonusSpells, vm: vm),
          const SizedBox(height: 10),
        ],

        _ActionsCard(
          title: 'Bonus Actions',
          actions: kBonusActions,
          context: context,
        ),
        const SizedBox(height: 20),

        //--REACTIONS--
        _SectionTitle('Reactions'),
        const SizedBox(height: 8),

        if (reactionSpellsFiltered.isNotEmpty) ...[
          _AttackTable(spells: reactionSpellsFiltered, vm: vm),
          const SizedBox(height: 10),
        ],

        _ActionsCard(
          title: 'Reactions',
          actions: kReactions,
          context: context,
        ),
        const SizedBox(height: 20),

        // --DEATH SAVES--
        if(!c.isConscious || c.isDying || c.currentHp == 0) ...[
          _SectionTitle('Death Saving Throws'),
          const SizedBox(height: 8),
          _DeathSavesRow(
            successes: c.deathSaveSuccesses,
            failures: c.deathSaveFailures),
          const SizedBox(height: 20),
        ],

        // --HIT DICE + SPEED--
        _SectionTitle('Hit Dice & Speed'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Row(children: [
          const Icon(Icons.casino_outlined,
            color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Text('Hit Dice: ',
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 13)),
          Text('${c.availableHitDice}',
            style: GoogleFonts.cinzel(
              color: AppTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.directions_run,
            color: AppTheme.textSecondary, size: 16),
          const SizedBox(width: 4),
          Text('${c.currentSpeed} ft',
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 13)),
        ]),
        ),
      ]),
    );
  }
   
  bool _isAction(CharacterSpell s) {
    final ct = s.castingTime?.toLowerCase() ?? '';
    return ct.contains('1 action') || ct == 'action';
  }

  bool _isBonusAction(CharacterSpell s) =>
    s.castingTime?.toLowerCase().contains('bonus') ?? false;

  bool _isReaction(CharacterSpell s) =>
    s.castingTime?.toLowerCase().contains('reaction') ?? false;
}

// ── Attack Table 
// ──────────────────────────────────────────────────────────────

class _AttackTable extends StatelessWidget {
  final List<CharacterSpell> spells;
  final CharacterSheetViewModel vm;
  const _AttackTable({required this.spells, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(children: [
        //Cabecera de columnas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            const Expanded(
              flex: 3,
              child: Text('NAME',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
                )),
            ),
            SizedBox(
              width: _kHitDcW,
              child: const Text('HIT / DC',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: _kColGap),
            SizedBox(
              width: _kDmgW,
              child: const Text('DAMAGE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
          ]),
        ),
        // Filas
        ...spells.map((s) => _AttackRow(spell: s, vm: vm)),
      ]),
    );
  }
}

class _AttackRow extends StatelessWidget {
  final CharacterSpell spell;
  final CharacterSheetViewModel vm;
  const _AttackRow({required this.spell, required this.vm});

  String _hitDc() {
    if (spell.attackType != null && spell.attackType!.isNotEmpty) {
      return vm.signedInt(vm.character?.spellAttackBonus ?? 0);
    }
    if (spell.dcType != null && spell.dcType!.isNotEmpty) {
      return '${spell.dcType} ${vm.character?.spellSaveDC ?? 0}';
    }
    return '—';
  }

  String _damage() {
    final base = spell.damageBase;
    final type = spell.damageType;
    if (base == null || base.isEmpty) return '—';
    if (type == null || type.isEmpty) return base;
    return '$base $type';
  }

  String _range() {
    final r = spell.range;
    if (r == null) return '—';
    return r.replaceAll(' feet', 'ft').replaceAll(' foot', 'ft');
  }

  @override
  Widget build(BuildContext context) {
    final isCantrip   = spell.isCantrip;
    final hasSlots    = vm.availableSlots(spell.level) > 0;
    final canCast     = isCantrip || hasSlots;
    final maxSl       = vm.maxSlots(spell.level);

    return InkWell(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xFF2A2A4A), width: 0.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Nombre + rango
            Expanded(
              flex: 3,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spell.name,
                        style: GoogleFonts.lato(
                            color: canCast
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    Text(_range(),
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 10)),
                  ]),
            ),
            // Hit/DC
            SizedBox(
              width: _kHitDcW,
              child: Text(_hitDc(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: const Color(0xFFC8A45A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: _kColGap),
            // Damage
            SizedBox(
              width: _kDmgW,
              child: Text(_damage(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                      color: const Color(0xFFCB7A48),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          //Slot tracker + botón Cast (solo para leveled spells)
          if (!isCantrip && maxSl > 0) ...[
            const SizedBox(height: 6),
            Row(children: [
              //Slot squares
              ...List.generate(maxSl, (i) => GestureDetector(
                onTap: () async {
                  final used = vm.usedSlots(spell.level);
                  // Tap en cuadrado lleno -> no hace nada (solo Cast/reset)

                  if(i> used){
                    final ok = await vm.castSpell(spell.level);
                    if(!ok && context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('No slots available for level ${spell.level}'),
                        backgroundColor: AppTheme.accent,
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    i < vm.usedSlots(spell.level)
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                    color: i < vm.usedSlots(spell.level)
                      ? AppTheme.accent
                      : AppTheme.textSecondary,
                    size: 16,
                  ),
                ),
              )),
              const Spacer(),
              //Botón CAST
              SizedBox(
                width: 54,
                height: 26,
                child: OutlinedButton(
                  onPressed: canCast
                    ? () async {
                      final ok = await vm.castSpell(spell.level);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          content: Text(
                            'No slots for level ${spell.level}'),
                          backgroundColor: AppTheme.accent,
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    }
                    : null,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppTheme.primary,
                    disabledForegroundColor: AppTheme.divider,
                    side: BorderSide(
                      color: canCast ? AppTheme.primary : AppTheme.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('CAST',
                    style: GoogleFonts.cinzel(
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ],
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
        initialChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 9, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                '${spell.school != null ? ' (${spell.school})' : ''}',
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 13),
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
              if (spell.description != null && spell.description!.isNotEmpty) ... [
                const SizedBox(height: 12),
                Text('Description',
                  style: GoogleFonts.cinzel(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
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

// Actions Card (colapsable -> pantalla de detalle)
// ──────────────────────────────────────────────────────────────


class _ActionsCard extends StatelessWidget {
  final String title;
  final List<_ActionEntry> actions;
  final BuildContext context;
  const _ActionsCard({
    required this.title,
    required this.actions,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return InkWell(
      onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
        builder: (_) => _ActionsDetailScreen(
          title: title,
          actions: actions),        
      )),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: Row(children: [
            const Icon(Icons.list_alt_outlined,
              color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Text(title,
              style: GoogleFonts.cinzel(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${actions.length} actions',
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
              color: AppTheme.textSecondary, size: 18),
          ]),
        ),
      );    
  }
}

//Actions Detail Screen
// ──────────────────────────────────────────────────────────────

class _ActionsDetailScreen extends StatelessWidget {
  final String title;
  final List<_ActionEntry> actions;
  const _ActionsDetailScreen(
      {super.key, required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(title,
            style: GoogleFonts.cinzel(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: actions.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppTheme.divider),
        itemBuilder: (_, i) {
          final a = actions[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.name,
                              style: GoogleFonts.cinzel(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(a.desc,
                              style: GoogleFonts.lato(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  height: 1.5)),
                        ]),
                  ),
                ]),
          );
        },
      ),
    );
  }
}

//Static Action Data
// ──────────────────────────────────────────────────────────────

class _ActionEntry {
  final String name;
  final String desc;
  const _ActionEntry({required this.name, required this.desc});
}

const kStandardActions = [
  _ActionEntry(name: 'Attack',
      desc: 'Make one weapon attack. Extra attacks from class features may allow more.'),
  _ActionEntry(name: 'Dash',
      desc: 'You gain extra movement equal to your speed for the current turn.'),
  _ActionEntry(name: 'Disengage',
      desc: 'Your movement doesn\'t provoke opportunity attacks for the rest of the turn.'),
  _ActionEntry(name: 'Dodge',
      desc: 'Until the start of your next turn, attacks against you have disadvantage and you have advantage on Dex saves.'),
  _ActionEntry(name: 'Grapple',
      desc: 'Special melee attack. Contest: your Athletics vs. their Athletics or Acrobatics.'),
  _ActionEntry(name: 'Help',
      desc: 'Give an ally advantage on the next ability check or attack roll against a creature within 5 ft of you.'),
  _ActionEntry(name: 'Hide',
      desc: 'Make a Stealth check. If successful, you are hidden until you attack or are detected.'),
  _ActionEntry(name: 'Improvise',
      desc: 'Do something not covered by other actions. The DM decides the outcome.'),
  _ActionEntry(name: 'Influence',
      desc: 'Make a Persuasion, Deception, or Intimidation check to sway a creature\'s attitude.'),
  _ActionEntry(name: 'Magic',
      desc: 'Cast a spell with a casting time of 1 action, or use a magic item.'),
  _ActionEntry(name: 'Ready',
      desc: 'Prepare a reaction for a specific trigger. Declare the action and the trigger.'),
  _ActionEntry(name: 'Search',
      desc: 'Make a Perception or Investigation check to find something non-obvious.'),
  _ActionEntry(name: 'Shove',
      desc: 'Special melee attack to push a creature 5 ft away or knock it prone.'),
  _ActionEntry(name: 'Study',
      desc: 'Make an Intelligence check to recall lore or analyze something.'),
  _ActionEntry(name: 'Utilize',
      desc: 'Use an object or activate a device (e.g., a trap, lock, or special item).'),
];

const kBonusActions = [
  _ActionEntry(name: 'Off-Hand Attack',
      desc: 'When you take the Attack action with a light melee weapon, you can use a bonus action to attack with a different light melee weapon in your other hand. No ability modifier to damage unless it\'s negative.'),
  _ActionEntry(name: 'Bonus Action Spell',
      desc: 'Cast a spell with a casting time of 1 Bonus Action. You can\'t cast another non-cantrip spell on the same turn.'),
  _ActionEntry(name: 'Second Wind (Fighter)',
      desc: 'Regain 1d10 + Fighter level HP. Usable once per short or long rest.'),
  _ActionEntry(name: 'Cunning Action (Rogue)',
      desc: 'Take the Dash, Disengage, or Hide action as a bonus action.'),
  _ActionEntry(name: 'Wild Shape (Druid)',
      desc: 'Transform into a beast you have seen. Twice per short rest.'),
  _ActionEntry(name: 'Bardic Inspiration (Bard)',
      desc: 'Give one creature within 60 ft a Bardic Inspiration die (d6–d12). They can add it to one ability check, attack, or saving throw.'),
];

const kReactions = [
  _ActionEntry(name: 'Opportunity Attack',
      desc: 'When a creature you can see moves out of your reach, make one melee attack against it.'),
  _ActionEntry(name: 'Readied Action',
      desc: 'Take the action you prepared with the Ready action when the trigger occurs.'),
  _ActionEntry(name: 'Shield (Spell)',
      desc: 'When hit by an attack or targeted by Magic Missile, gain +5 AC until the start of your next turn.'),
  _ActionEntry(name: 'Uncanny Dodge (Rogue)',
      desc: 'When an attacker you can see hits you, halve the attack\'s damage.'),
];

// Section Title
// ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title,
        style: GoogleFonts.cinzel(
            color: AppTheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1
        )),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
  ]);
}

//Death Saves
// ──────────────────────────────────────────────────────────────
class _DeathSavesRow extends StatelessWidget {
  final int successes;
  final int failures;
  const _DeathSavesRow({required this.successes, required this.failures});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(children: [
        Text('Successes',
          style: GoogleFonts.lato(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => _SaveDot(
            filled: i < successes,
            color: AppTheme.primary))),
          ])),
          Container(width: 1, height: 40, color: AppTheme.divider),
        Expanded(
          child: Column(children: [
        Text('Failures',
          style: GoogleFonts.lato(
            color: AppTheme.accent,
            fontSize: 11,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => _SaveDot(
              filled: i < failures, color: AppTheme.accent))),
        ])),
      ]),
    );
 }
}

// Save Dot
// ──────────────────────────────────────────────────────────────
class _SaveDot extends StatelessWidget{
  final bool filled;
  final Color color;
  const _SaveDot({required this.filled, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: filled ? color : Colors.transparent,
      border: Border.all(color: color, width: 2),
  ),
  );
}

//Detail Row
// ──────────────────────────────────────────────────────────────
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
            color: AppTheme.textPrimary,
            fontSize: 12)),
      ),
    ]),
  );
}


