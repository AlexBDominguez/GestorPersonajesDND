import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:google_fonts/google_fonts.dart';

class TabTraits extends StatelessWidget {
  final PlayerCharacter c;
  const TabTraits({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TraitCard(
          icon: Icons.face_outlined,
          title: 'Personality Traits',
          content: [
            if(c.personalityTrait1?.isNotEmpty == true)
            c.personalityTrait1!,
            if (c.personalityTrait2?.isNotEmpty == true)
            c.personalityTrait2!,
          ],
        ),
        const SizedBox(height: 12),
        _TraitCard(
          icon: Icons.star_outline,
          title: 'Ideal',
          content: [if (c.ideal?.isNotEmpty == true) c.ideal!],
        ),
        const SizedBox(height: 12),
        _TraitCard(
          icon: Icons.link_outlined,
          title: 'Bond',
          content: [if (c.bond?.isNotEmpty == true) c.bond!],
        ),
        const SizedBox(height:12),
        _TraitCard(
          icon: Icons.warning_amber_outlined,
          title: 'Flaw',
          content: [if (c.flaw?.isNotEmpty == true)c.flaw!],
        ),
        const SizedBox(height: 12),
        if (c.backstory?.isNotEmpty == true)
        _TraitCard(
          icon: Icons.menu_book_outlined,
          title: 'Backstory',
          content: [c.backstory!],
          multiline: true,
        ),
        if (c.backstory?.isNotEmpty == true) const SizedBox(height: 12),
        if(c.characterHistory?.isNotEmpty == true)
          _TraitCard(
            icon: Icons.history_edu_outlined,
            title: 'Character History',
            content: [c.characterHistory!],
            multiline: true,
          ),
        if (c.alliesAndOrganizations?.isNotEmpty == true)...[
          const SizedBox(height: 12),
          _TraitCard(
            icon: Icons.groups_outlined,
            title: 'Allies & Organizations',
            content: [c.alliesAndOrganizations!],
            multiline: true,
          ),
        ],
      ],
    );
  }
}

class _TraitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> content;
  final bool multiline;

  const _TraitCard({
    required this.icon,
    required this.title,
    required this.content,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(title,
          style: GoogleFonts.cinzel(
            color: AppTheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.bold)),
        ]),
        const Divider(color: AppTheme.divider, height: 16),
        if (content.isEmpty)
          Text('—',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic))
        else
          ...content.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(text,
                    style: GoogleFonts.lato(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        height: multiline ? 1.5 : 1.2)),
            )),
      ]),
    );
  }
}