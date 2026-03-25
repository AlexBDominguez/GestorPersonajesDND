import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/app_theme.dart';
import '../../../../models/character/player_character.dart';

class TabCombat extends StatelessWidget {
  final PlayerCharacter c;
  const TabCombat({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── HP block ───────────────────────────────────────────
        _SectionCard(
          title: 'Hit Points',
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BigStat(label: 'Current', value: '${c.currentHp}',
                    color: _hpColor(c)),
                _BigStat(label: 'Max', value: '${c.maxHp}'),
                _BigStat(label: 'Temp', value: '${c.temporaryHp}',
                    color: const Color(0xFF4A90D9)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: c.hpPercent,
                backgroundColor: AppTheme.background,
                valueColor: AlwaysStoppedAnimation<Color>(_hpColor(c)),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            // Status badges
            if (c.isDying || c.isDead || !c.isConscious)
              Wrap(spacing: 8, children: [
                if (c.isDead)
                  _StatusBadge('Dead', AppTheme.accent),
                if (c.isDying && !c.isDead)
                  _StatusBadge('Dying', Colors.orange),
                if (!c.isConscious && !c.isDead)
                  _StatusBadge('Unconscious', Colors.purple),
                if (c.isStable)
                  _StatusBadge('Stable', const Color(0xFF2D6A4F)),
              ]),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Death Saves ────────────────────────────────────────
        if (c.isDying || c.deathSaveSuccesses > 0 || c.deathSaveFailures > 0)
          _SectionCard(
            title: 'Death Saving Throws',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DeathSaveRow(label: 'Successes',
                    count: c.deathSaveSuccesses, color: const Color(0xFF2D6A4F)),
                _DeathSaveRow(label: 'Failures',
                    count: c.deathSaveFailures, color: AppTheme.accent),
              ],
            ),
          ),
        if (c.isDying || c.deathSaveSuccesses > 0 || c.deathSaveFailures > 0)
          const SizedBox(height: 12),

          //Combat Stats
          _SectionCard(
            title: 'Combat',
            child: Wrap(
              spacing: 12, runSpacing: 12,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _StatBox(label: 'Armor Class', value: '${c.armorClass}'),
                _StatBox(label: 'Initiative',
                  value: c.initiativeModifier >= 0
                    ? '+${c.initiativeModifier}'
                    : '${c.initiativeModifier}'),
                _StatBox(label: 'Speed', value: '${c.currentSpeed} ft'),
                _StatBox(label: 'Prof. Bonus',
                  value: '+${c.proficiencyBonus}'),
                _StatBox(label: 'Hit Dice', value: '${c.availableHitDice}'),
                if (c.hasInspiration)
                  _StatBox(label: 'Inspiration', value: '✦',
                    valueColor: AppTheme.primary), 
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Attack Bonuses
          _SectionCard(
            title: 'Attack Bonuses',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatBox(label: 'Melee',
                  value: _signedInt(c.meleeAttackBonus)),
                _StatBox(label: 'Ranged',
                  value: _signedInt(c.rangedAttackBonus)),
                _StatBox(label: 'Finesse',
                  value: _signedInt(c.finesseAttackBonus)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          //XP
          _SectionCard(
            title: 'Experience',
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${c.experiencePoints} XP',
                    style: GoogleFonts.cinzel(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold)),
                Text('Next level: ${c.experienceToNextLevel} XP',
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 12)),                                    
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: c.xpPercent,
                  backgroundColor: AppTheme.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 8,
                ),
              ),
            ]),
          ),        
      ],
    );
  }
  Color _hpColor(PlayerCharacter c) {
    if (c.isDead) return AppTheme.accent;
    if (c.hpPercent > 0.6) return const Color (0xFF2D6A4F);
    if (c.hpPercent > 0.3) return const Color (0xFFC8A45A);
    return AppTheme.accent;
  }

  String _signedInt(int v) => v >= 0 ? '+$v' : '$v';
}

//Private widgets
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity ,
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
}

class _BigStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _BigStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(label,
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 11
            )),
  ]);
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatBox({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.cinzel(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 10)),
       ]),
  );             
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(label,
    style: GoogleFonts.lato(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.bold)),
    backgroundColor: color,
    padding: EdgeInsets.zero,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

class _DeathSaveRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _DeathSaveRow({required this.label, required this.count, required this.color });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label,
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary, fontSize: 11)),
      const SizedBox(height: 6),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            i < count ? Icons.circle : Icons.circle_outlined,
            color: i < count ? color : AppTheme.surfaceVariant,
            size: 20,
          ),
      )),
    ),
  ]);
}



