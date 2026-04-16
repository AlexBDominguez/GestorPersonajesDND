import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:google_fonts/google_fonts.dart';

class TabInfo extends StatelessWidget{
  final PlayerCharacter character;
  const TabInfo({super.key, required this.character});

  @override
  Widget build(BuildContext context){
    final c = character;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: 
      CrossAxisAlignment.start, children: [

        //Personal Characteristics
        _SectionTitle('Personal Characteristics'),
        const SizedBox(height: 12),

        _TraitCard(
          icon: Icons.psychology_outlined,
          label: 'Personality Traits',
          children: [
            if (c.personalityTrait != null && c.personalityTrait!.isNotEmpty)
              _TraitText(c.personalityTrait!)
            else
              _EmptyHint('No personality trait recorded.'),
          ],
        ),
        const SizedBox(height: 10),

        _TraitCard(
          icon: Icons.star_border_outlined,
          label: 'Ideals',
          children: [
            c.ideal != null && c.ideal!.isNotEmpty
              ? _TraitText(c.ideal!)
              : _EmptyHint('No ideal recorded.'),
          ],
        ),
        const SizedBox(height: 10),

        _TraitCard(
          icon: Icons.link_outlined,
          label: 'Bonds',
          children: [
            c.bond != null && c.bond!.isNotEmpty
              ? _TraitText(c.bond!)
              : _EmptyHint('No bond recorded.'),
          ],
        ),
        const SizedBox(height: 10),

        _TraitCard(
          icon: Icons.healing_outlined,
          label: 'Flaws',
          children: [
            c.flaw != null && c.flaw!.isNotEmpty
              ? _TraitText(c.flaw!)
              : _EmptyHint('No flaw recorded.'),
          ],          
        ),
        const SizedBox(height: 24),

        //Background and Alignment
        _SectionTitle('Identity'),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(
            child: _InfoPill(
              label: 'Race',
              value: c.subraceName != null
                  ? '${c.raceName ?? '—'} (${c.subraceName})'
                  : c.raceName ?? '—',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoPill(
              label: 'Class',
              value: c.subclassName != null
                  ? '${c.dndClassName ?? '—'} · ${c.subclassName}'
                  : c.dndClassName ?? '—',
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _InfoPill(
              label: 'Background',
              value: c.backgroundName ?? '—',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoPill(
              label: 'Alignment',
              value: c.alignment ?? '—',
            ),
          ),
        ]),
        const SizedBox(height: 24),

        //Physical Characteristics
        _SectionTitle('Physical Characteristics'),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            _PhysCell(label: 'Age', value: c.age != null ? '${c.age}' : '—'),
            _PhysCell(label: 'Height', value: c.height ?? '—'),
            _PhysCell(label: 'Weight', value: c.weight ?? '—'),
            _PhysCell(label: 'Eyes', value: c.eyes ?? '—'),
            _PhysCell(label: 'Skin', value: c.skin ?? '—'),
            _PhysCell(label: 'Hair', value: c.hair ?? '—'),
          ],
        ),
        const SizedBox(height: 24),

        //Backstory
        if (c.backstory != null && c.backstory!.isNotEmpty) ...[
          _SectionTitle('Backstory'),
          const SizedBox(height: 12),
          _LongTextCard(c.backstory!),
          const SizedBox(height: 24),
        ],

        //Appearance
        if (c.appearance != null && c.appearance!.isNotEmpty) ...[
          _SectionTitle('Appearance'),
          const SizedBox(height: 12),
          _LongTextCard(c.appearance!),
          const SizedBox(height: 24),
        ],

        //Character History
        if(c.characterHistory != null && c.characterHistory!.isNotEmpty) ...[
          _SectionTitle('Character History'),
          const SizedBox(height: 12),
          _LongTextCard(c.characterHistory!),
          const SizedBox(height: 24),
        ],

        //Allies and Organizations
        if(c.alliesAndOrganizations != null && c.alliesAndOrganizations!.isNotEmpty) ...[
          _SectionTitle('Allies and Organizations'),
          const SizedBox(height: 12),
          _LongTextCard(c.alliesAndOrganizations!),
          const SizedBox(height: 24),
        ],
      ]),
    );
  }
}

//Widgets auxliares
class _SectionTitle extends StatelessWidget{
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title,
      style: GoogleFonts.cinzel(
        color: AppTheme.primary,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      )),
    const SizedBox(width: 10),
    const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
  ]);
}

//Card con icono, label y contenido variable
class _TraitCard extends StatelessWidget{
  final IconData icon;
  final String label;
  final List<Widget> children;
  const _TraitCard({required this.icon, required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppTheme.primary, size: 15),
          const SizedBox(width: 6),
          Text(label,
            style: GoogleFonts.cinzel(
              color: AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            )),
        ]),
        const SizedBox(height: 8),
        ...children,
      ]),
    );
  }
}

class _TraitText extends StatelessWidget{
  final String text;
  const _TraitText(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text,
      style: GoogleFonts.lato(
        color: AppTheme.textPrimary,
        fontSize: 13,
        height: 1.4,
      )), 
  );
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: GoogleFonts.lato(
      color: AppTheme.textSecondary,
      fontSize: 12,
      fontStyle: FontStyle.italic,
    ));
}

//Pill pequeña: label + valor (para Background, Alignment)
class _InfoPill extends StatelessWidget{  
  final String label;
  final String value;
  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          )),
        const SizedBox(height: 4),
        Text(value,
          style: GoogleFonts.lato(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

//Celda del grid de características físicas
class _PhysCell extends StatelessWidget {
  final String label;
  final String value;
  const _PhysCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            )),
          const SizedBox(height: 2),
          Text(value,
            style: GoogleFonts.lato(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

//Bloque de texto largo(backstory, appearance, etc)
class _LongTextCard extends StatelessWidget{
  final String text;
  const _LongTextCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Text(text,
        style: GoogleFonts.lato(
          color: AppTheme.textPrimary,
          fontSize: 13,
          height: 1.6,
        )),
    );
  }
}

