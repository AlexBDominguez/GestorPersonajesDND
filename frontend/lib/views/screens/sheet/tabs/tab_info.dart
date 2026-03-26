import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:google_fonts/google_fonts.dart';

class TabInfo extends StatelessWidget {
  final PlayerCharacter c;
  const TabInfo({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        //Identity
        _InfoCard(title: 'Identity', rows: [
          _Row('Race', c.raceName),
          _Row('Class', c.dndClassName),
          _Row('Subclass', c.subclassName),
          _Row('Background', c.backgroundName),
          _Row('Level', '${c.level}'),
        ]),
        const SizedBox(height: 12),

        //Physical
        _InfoCard(title: 'Appearance', rows: [
          _Row('Age',    c.age != null ? '${c.age}' : null),
          _Row('Height', c.height),
          _Row('Weight', c.weight),
          _Row('Eyes', c.eyes),
          _Row('Skin', c.skin),
          _Row('Hair', c.hair),
        ]),
        const SizedBox(height: 12),

        if (c.appearance?.isNotEmpty == true)
          _InfoCard(title: 'Physical Description', rows: [
            _Row(null, c.appearance),
          ]),
        if (c.additionalTreasure?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'Additional Treasure & Notes', rows: [
            _Row(null, c.additionalTreasure),
          ]),
        ],
      ],
    );
  }
}

class _Row {
  final String? label;
  final String? value;
  const _Row(this.label, this.value);
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_Row> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    // Filter out rows with no value
    final visible = rows.where((r) => r.value?.isNotEmpty == true).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.cinzel(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        const Divider(color: AppTheme.divider, height: 16),
        if (visible.isEmpty)
          Text('No data yet.',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic))
        else
          ...visible.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: r.label != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text('${r.label}',
                                style: GoogleFonts.lato(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                          ),
                          Expanded(
                            child: Text(r.value!,
                                style: GoogleFonts.lato(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      )
                    : Text(r.value!,
                        style: GoogleFonts.lato(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            height: 1.5)),
              )),
      ]),
    );
  }
}