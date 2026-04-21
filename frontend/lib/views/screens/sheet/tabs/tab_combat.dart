import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/config/combat_features.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

// Shared column widths (keep in sync with tab_spells.dart)
const double _kHitDcW = 62.0;
const double _kDmgW   = 80.0;
const double _kColGap =  8.0;

// ── Tab Combat ────────────────────────────────────────────────────────────────

class TabCombat extends StatefulWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabCombat({super.key, required this.character, required this.vm});

  @override
  State<TabCombat> createState() => _TabCombatState();
}

class _TabCombatState extends State<TabCombat> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final c  = widget.character;
    final vm = widget.vm;

    final actionSpells = c.characterSpells
        .where((s) => _isAction(s) && (s.isCantrip || s.prepared))
        .toList()..sort((a, b) => a.level.compareTo(b.level));
    final bonusSpells = c.characterSpells
        .where((s) => _isBonus(s) && (s.isCantrip || s.prepared))
        .toList()..sort((a, b) => a.level.compareTo(b.level));
    final reactionSpells = c.characterSpells
        .where((s) => _isReaction(s) && (s.isCantrip || s.prepared))
        .toList();

        final actionFeatures =
          vm.combatFeaturesByCategory(FeatureCategory.combatAction)
              + vm.subclassFeatures.where((f) => classifyFeature(f.indexName) ==
                  FeatureCategory.combatAction).toList();
        final bonusFeatures =
          vm.combatFeaturesByCategory(FeatureCategory.combatBonus)
              + vm.subclassFeatures.where((f) => classifyFeature(f.indexName) ==
                  FeatureCategory.combatBonus).toList();
        final reactionFeatures =
          vm.combatFeaturesByCategory(FeatureCategory.combatReaction)
              + vm.subclassFeatures.where((f) => classifyFeature(f.indexName) ==
                  FeatureCategory.combatReaction).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── 1. Standard Actions card (always visible, at top) ────────────────
        _StandardActionsCard(),
        const SizedBox(height: 16),

        // ── 2. Actions ───────────────────────────────────────────────────────
        _SectionTitle('Actions'),
        const SizedBox(height: 8),
        if (actionSpells.isNotEmpty) ...[
          _SpellAttackTable(spells: actionSpells, vm: vm),
          const SizedBox(height: 8),
        ],
        if (vm.isLoadingFeatures)
          const _LoadingRow()
        else
          _FeatureGroup(features: actionFeatures, vm: vm),
        const SizedBox(height: 16),

        // ── 3. Bonus Actions ─────────────────────────────────────────────────
        _SectionTitle('Bonus Actions'),
        const SizedBox(height: 8),
        if (bonusSpells.isNotEmpty) ...[
          _SpellAttackTable(spells: bonusSpells, vm: vm),
          const SizedBox(height: 8),
        ],
        _StaticSection(actions: kBonusActions),
        if (bonusFeatures.isNotEmpty) ...[
          const SizedBox(height: 8),
          _FeatureGroup(features: bonusFeatures, vm: vm),
        ],
        const SizedBox(height: 16),

        // ── 4. Reactions ─────────────────────────────────────────────────────
        _SectionTitle('Reactions'),
        const SizedBox(height: 8),
        if (reactionSpells.isNotEmpty) ...[
          _SpellAttackTable(spells: reactionSpells, vm: vm),
          const SizedBox(height: 8),
        ],
        _StaticSection(actions: kReactions),
        if (reactionFeatures.isNotEmpty) ...[
          const SizedBox(height: 8),
          _FeatureGroup(features: reactionFeatures, vm: vm),
        ],
        const SizedBox(height: 20),

        // ── 5. Death Saves (conditional) ─────────────────────────────────────
        if (!c.isConscious || c.isDying || c.currentHp == 0) ...[
          _SectionTitle('Death Saving Throws'),
          const SizedBox(height: 8),
          _DeathSavesRow(
            successes: c.deathSaveSuccesses,
            failures: c.deathSaveFailures,
          ),
          const SizedBox(height: 20),
        ],

        // ── 6. Hit Dice & Speed ───────────────────────────────────────────────
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
            const Icon(Icons.casino_outlined, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Text('Hit Dice: ',
                style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
            Text('${c.availableHitDice}',
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.directions_run, color: AppTheme.textSecondary, size: 16),
            const SizedBox(width: 4),
            Text('${c.currentSpeed} ft',
                style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  static bool _isAction(CharacterSpell s) {
    final ct = s.castingTime?.toLowerCase() ?? '';
    return ct.contains('1 action') || ct == 'action';
  }

  static bool _isBonus(CharacterSpell s) =>
      s.castingTime?.toLowerCase().contains('bonus') ?? false;

  static bool _isReaction(CharacterSpell s) =>
      s.castingTime?.toLowerCase().contains('reaction') ?? false;
}

// ── Feature group: lista de features de una categoría ────────────────────────────────────────────
class _FeatureGroup extends StatelessWidget {
  final List<ClassFeature> features;
  final CharacterSheetViewModel vm;
  const _FeatureGroup({required this.features, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) return const SizedBox.shrink();
    return Column(
      children: features.map((feature) => 
      _FeatureTile(feature: feature, vm: vm)).toList(),
    );
  }
}

// ── Feature tile con contadores circulares ───────────────────────────────────────────
class _FeatureTile extends StatelessWidget {
  final ClassFeature feature;
  final CharacterSheetViewModel vm;
  const _FeatureTile({required this.feature, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isConsumable = vm.isConsumableFeature(feature);
    final maxUses = vm.featureMaxUses(feature);
    final remaining = vm.featureUsesRemaining(feature);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 4, 10, 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Row(children: [
            Expanded(
              child: Text(feature.name,
                  style: GoogleFonts.cinzel(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
                  ),
                  //Contadores circulares
                  if (isConsumable) ...[
                    const SizedBox(width: 8),
                    ...List.generate(maxUses, (i) {
                      final isUsed = i >= remaining;
                      return GestureDetector(
                        onTap: () => 
                          isUsed ? vm.restoreFeature(feature) :
                          vm.useFeature(feature),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUsed
                                  ? Colors.transparent
                                  : AppTheme.primary,
                              border: Border.all(
                                color: isUsed
                                  ? AppTheme.textSecondary
                                  : AppTheme.primary,
                                width: 1.5),
                              ),
                            ),
                          ),
                        );
                    }),
                  ],
          ]),
          subtitle: Text('Level ${feature.level}',
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 10)),
          iconColor: AppTheme.textSecondary,
          collapsedIconColor: AppTheme.textSecondary,
          children: [
            Text(feature.description,
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.5)),
          ],
        )
      )
    );
  }
}

// ── Loading row ───────────────────────────────────────────
class _LoadingRow extends StatelessWidget {
  const _LoadingRow();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.primary),
          ),
        ),
      );
}

// ── Standard Actions card (navigates to full-screen list) ─────────────────────

class _StandardActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _ActionListScreen(
              title: 'Standard Actions', actions: kStandardActions),
        )),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
          ),
          child: Row(children: [
            const Icon(Icons.list_alt_outlined,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Text('Standard Actions',
                style: GoogleFonts.cinzel(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${kStandardActions.length} actions',
                style:
                    GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 18),
          ]),
        ),
      );
}

// ── Spell Attack Table (no CAST button, no per-row slot tracker) ──────────────

class _SpellAttackTable extends StatelessWidget {
  final List<CharacterSpell> spells;
  final CharacterSheetViewModel vm;
  const _SpellAttackTable({required this.spells, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(children: [
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
                      letterSpacing: 0.5)),
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
        ...spells.map((s) => _SpellRow(spell: s, vm: vm)),
      ]),
    );
  }
}

// ── Spell row (tap → detail sheet) ────────────────────────────────────────────

class _SpellRow extends StatelessWidget {
  final CharacterSpell spell;
  final CharacterSheetViewModel vm;
  const _SpellRow({required this.spell, required this.vm});

  String _hitDc() {
    if (spell.attackType != null && spell.attackType!.isNotEmpty)
      return vm.signedInt(vm.character?.spellAttackBonus ?? 0);
    if (spell.dcType != null && spell.dcType!.isNotEmpty)
      return '${spell.dcType} ${vm.character?.spellSaveDC ?? 0}';
    return '—';
  }

  String _damage() {
    final b = spell.damageBase;
    final t = spell.damageType;
    if (b == null || b.isEmpty) return '—';
    if (t == null || t.isEmpty) return b;
    return '$b $t';
  }

  String _range() {
    final r = spell.range;
    if (r == null) return '—';
    return r.replaceAll(' feet', 'ft').replaceAll(' foot', 'ft');
  }

  @override
  Widget build(BuildContext context) {
    final hasSlots = vm.availableSlots(spell.level) > 0;
    final canCast  = spell.isCantrip || hasSlots;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _SpellDetailSheet(spell: spell, vm: vm),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xFF2A2A4A), width: 0.5))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
      ),
    );
  }
}

// ── Spell Detail Sheet ─────────────────────────────────────────────────────────

class _SpellDetailSheet extends StatelessWidget {
  final CharacterSpell spell;
  final CharacterSheetViewModel vm;
  const _SpellDetailSheet({required this.spell, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isCantrip = spell.isCantrip;
    final level     = spell.level;
    final maxSl     = vm.maxSlots(level);
    final usedSl    = vm.usedSlots(level);
    final hasSlots  = vm.availableSlots(level) > 0;
    final canCast   = isCantrip || hasSlots;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

          // Title row + CAST button
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spell.name,
                        style: GoogleFonts.cinzel(
                            color: AppTheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${spell.levelLabel}'
                      '${spell.school != null ? ' · ${spell.school}' : ''}',
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ]),
            ),
            if (!isCantrip) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 72,
                height: 38,
                child: OutlinedButton(
                  onPressed: canCast
                      ? () async {
                          final ok = await vm.castSpell(level);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('No slots for level $level'),
                              backgroundColor: AppTheme.accent,
                              duration: const Duration(seconds: 2),
                            ));
                          }
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppTheme.primary,
                    disabledForegroundColor: AppTheme.divider,
                    side: BorderSide(
                        color: canCast ? AppTheme.primary : AppTheme.divider),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('CAST',
                      style: GoogleFonts.cinzel(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ]),

          // Interactive slot tracker
          if (!isCantrip && maxSl > 0) ...[
            const SizedBox(height: 12),
            Row(children: [
              Text('Slots Lv.$level',
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4)),
              const SizedBox(width: 10),
              ...List.generate(maxSl, (i) {
                final isFull = i < usedSl;
                return GestureDetector(
                  onTap: () async {
                    if (isFull) {
                      await vm.restoreSpellSlot(level);
                    } else {
                      await vm.castSpell(level);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      isFull
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isFull ? AppTheme.accent : AppTheme.textSecondary,
                      size: 20),
                  ),
                );
              }),
            ]),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          if (spell.castingTime != null)
            _DetailRow('Casting Time', spell.castingTime!),
          if (spell.range != null) _DetailRow('Range', spell.range!),
          if (spell.duration != null) _DetailRow('Duration', spell.duration!),
          if (spell.components != null)
            _DetailRow('Components', spell.components!),
          if (!isCantrip)
            _DetailRow('Status', spell.prepared ? 'Prepared ✓' : 'Learned'),
          if (spell.description != null && spell.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Description',
                style: GoogleFonts.cinzel(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(spell.description!,
                style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 13, height: 1.6)),
          ],
        ]),
      ),
    );
  }
}

// ── Static section (inline expandable list: bonus actions / reactions) ─────────

class _StaticSection extends StatelessWidget {
  final List<_ActionEntry> actions;
  const _StaticSection({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: actions
          .map((a) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceVariant),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    title: Text(a.name,
                        style: GoogleFonts.cinzel(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    iconColor: AppTheme.textSecondary,
                    collapsedIconColor: AppTheme.textSecondary,
                    children: [
                      Text(a.desc,
                          style: GoogleFonts.lato(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.5)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ── Full-screen action list (Standard Actions) ─────────────────────────────────

class _ActionListScreen extends StatelessWidget {
  final String title;
  final List<_ActionEntry> actions;
  const _ActionListScreen(
      {required this.title, required this.actions});

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
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppTheme.primary),
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

// ── Static data ────────────────────────────────────────────────────────────────

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
      desc: "Your movement doesn't provoke opportunity attacks for the rest of the turn."),
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
      desc: "Make a Persuasion, Deception, or Intimidation check to sway a creature's attitude."),
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

// Only universal bonus actions available to ALL characters by default.
// Class-specific features (Second Wind, Cunning Action, Wild Shape, etc.)
// are loaded dynamically in _ClassFeaturesSection from the API.
const kBonusActions = [
  _ActionEntry(name: 'Off-Hand Attack',
      desc: "When you take the Attack action with a light melee weapon, you can use a bonus action to attack with a different light melee weapon held in the other hand. No ability modifier to damage unless negative."),
];

// Only universal reactions available to ALL characters by default.
// Class-specific reactions (Uncanny Dodge, etc.) appear via _ClassFeaturesSection.
const kReactions = [
  _ActionEntry(name: 'Opportunity Attack',
      desc: 'When a creature you can see moves out of your reach, make one melee attack against it as a reaction.'),
  _ActionEntry(name: 'Readied Action',
      desc: 'Take the action you prepared with the Ready action when the trigger you declared occurs.'),
];

// ── Section title ──────────────────────────────────────────────────────────────


//Shared WIDGETS

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
                letterSpacing: 1)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
      ]);
}

// ── Death Saves ────────────────────────────────────────────────────────────────

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
              children: List.generate(
                  3, (i) => _SaveDot(filled: i < successes, color: AppTheme.primary))),
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
                  3, (i) => _SaveDot(filled: i < failures, color: AppTheme.accent))),
        ])),
      ]),
    );
  }
}

class _SaveDot extends StatelessWidget {
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

// ── Detail Row ─────────────────────────────────────────────────────────────────

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
