import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/l10n/dnd_terms.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:google_fonts/google_fonts.dart';

String _tr(BuildContext context, {required String en, required String es, required String gl}) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'es') return es;
  if (code == 'gl') return gl;
  return en;
}

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
        _SectionTitle(_tr(context, en: 'Personal Characteristics', es: 'Rasgos personales', gl: 'Trazos persoais')),
        const SizedBox(height: 12),

        _TraitCard(
          icon: Icons.psychology_outlined,
          label: _tr(context, en: 'Personality Traits', es: 'Rasgos de personalidad', gl: 'Rasgos de personalidade'),
          children: [
            if (c.personalityTrait != null && c.personalityTrait!.isNotEmpty)
              _TraitText(c.personalityTrait!)
            else
              _EmptyHint(_tr(context, en: 'No personality trait recorded.', es: 'No hay rasgo de personalidad registrado.', gl: 'Non hai rasgo de personalidade rexistrado.')),
          ],
        ),
        const SizedBox(height: 10),

        _TraitCard(
          icon: Icons.star_border_outlined,
          label: _tr(context, en: 'Ideals', es: 'Ideales', gl: 'Ideais'),
          children: [
            c.ideal != null && c.ideal!.isNotEmpty
              ? _TraitText(c.ideal!)
              : _EmptyHint(_tr(context, en: 'No ideal recorded.', es: 'No hay ideal registrado.', gl: 'Non hai ideal rexistrado.')),
          ],
        ),
        const SizedBox(height: 10),

        _TraitCard(
          icon: Icons.link_outlined,
          label: _tr(context, en: 'Bonds', es: 'Vinculos', gl: 'Vinculos'),
          children: [
            c.bond != null && c.bond!.isNotEmpty
              ? _TraitText(c.bond!)
              : _EmptyHint(_tr(context, en: 'No bond recorded.', es: 'No hay vinculo registrado.', gl: 'Non hai vinculo rexistrado.')),
          ],
        ),
        const SizedBox(height: 10),

        _TraitCard(
          icon: Icons.healing_outlined,
          label: _tr(context, en: 'Flaws', es: 'Defectos', gl: 'Defectos'),
          children: [
            c.flaw != null && c.flaw!.isNotEmpty
              ? _TraitText(c.flaw!)
              : _EmptyHint(_tr(context, en: 'No flaw recorded.', es: 'No hay defecto registrado.', gl: 'Non hai defecto rexistrado.')),
          ],          
        ),
        const SizedBox(height: 24),

        //Background and Alignment
        _SectionTitle(_tr(context, en: 'Identity', es: 'Identidad', gl: 'Identidade')),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(
            child: _InfoPill(
              label: _tr(context, en: 'Race', es: 'Raza', gl: 'Raza'),
              value: c.subraceName != null
                  ? '${c.raceName != null ? localizeKnownName(context, c.raceName!) : '—'} (${localizeKnownName(context, c.subraceName!)})'
                  : (c.raceName != null ? localizeKnownName(context, c.raceName!) : '—'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoPill(
              label: _tr(context, en: 'Class', es: 'Clase', gl: 'Clase'),
              value: c.subclassName != null
                  ? '${c.dndClassName != null ? localizeKnownName(context, c.dndClassName!) : '—'} · ${localizeKnownName(context, c.subclassName!)}'
                  : (c.dndClassName != null ? localizeKnownName(context, c.dndClassName!) : '—'),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _InfoPill(
              label: _tr(context, en: 'Background', es: 'Trasfondo', gl: 'Trasfondo'),
              value: c.backgroundName != null ? localizeKnownName(context, c.backgroundName!) : '—',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoPill(
              label: _tr(context, en: 'Alignment', es: 'Alineamiento', gl: 'Aliñamento'),
              value: c.alignment != null ? localizeAlignment(context, c.alignment!) : '—',
            ),
          ),
        ]),
        const SizedBox(height: 24),

        //Physical Characteristics
        _SectionTitle(_tr(context, en: 'Physical Characteristics', es: 'Caracteristicas fisicas', gl: 'Caracteristicas fisicas')),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            _PhysCell(label: _tr(context, en: 'Age', es: 'Edad', gl: 'Idade'), value: c.age != null ? '${c.age}' : '—'),
            _PhysCell(label: _tr(context, en: 'Height', es: 'Altura', gl: 'Altura'), value: c.height ?? '—'),
            _PhysCell(label: _tr(context, en: 'Weight', es: 'Peso', gl: 'Peso'), value: c.weight ?? '—'),
            _PhysCell(label: _tr(context, en: 'Eyes', es: 'Ojos', gl: 'Ollos'), value: c.eyes ?? '—'),
            _PhysCell(label: _tr(context, en: 'Skin', es: 'Piel', gl: 'Pel'), value: c.skin ?? '—'),
            _PhysCell(label: _tr(context, en: 'Hair', es: 'Pelo', gl: 'Pelo'), value: c.hair ?? '—'),
          ],
        ),
        const SizedBox(height: 24),

        //Backstory
        if (c.backstory != null && c.backstory!.isNotEmpty) ...[
          _SectionTitle(_tr(context, en: 'Backstory', es: 'Trasfondo narrativo', gl: 'Historia')),
          const SizedBox(height: 12),
          _LongTextCard(c.backstory!),
          const SizedBox(height: 24),
        ],

        //Appearance
        if (c.appearance != null && c.appearance!.isNotEmpty) ...[
          _SectionTitle(_tr(context, en: 'Appearance', es: 'Apariencia', gl: 'Aparencia')),
          const SizedBox(height: 12),
          _LongTextCard(c.appearance!),
          const SizedBox(height: 24),
        ],

        //Character History
        if(c.characterHistory != null && c.characterHistory!.isNotEmpty) ...[
          _SectionTitle(_tr(context, en: 'Character History', es: 'Historia del personaje', gl: 'Historia do personaxe')),
          const SizedBox(height: 12),
          _LongTextCard(c.characterHistory!),
          const SizedBox(height: 24),
        ],

        //Allies and Organizations
        if(c.alliesAndOrganizations != null && c.alliesAndOrganizations!.isNotEmpty) ...[
          _SectionTitle(_tr(context, en: 'Allies and Organizations', es: 'Aliados y organizaciones', gl: 'Aliados e organizacions')),
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
      style: GoogleFonts.libreBaskerville(
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
            style: GoogleFonts.libreBaskerville(
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

