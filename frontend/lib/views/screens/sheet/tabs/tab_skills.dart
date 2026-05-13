import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/l10n/app_strings.dart';
import 'package:gestor_personajes_dnd/l10n/dnd_terms.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class TabSkills extends StatelessWidget{
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabSkills({super.key, required this.character, required this.vm});

  @override
  Widget build(BuildContext context){
    final hdr = _columnHeaders(context);
    final skills = [...CharacterSheetViewModel.skillNames]
      ..sort((a, b) =>
          _skillLabel(context, a).toLowerCase().compareTo(_skillLabel(context, b).toLowerCase()));
    return Column(children: [
      //Header de la tabla
      Container(
        color: AppTheme.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const SizedBox(width: 20),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(hdr.mod,
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(hdr.skill,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10
            )),            
          ),
          Text(hdr.bonus,
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary,
              fontSize: 10, fontWeight: FontWeight.bold
            )),
          const SizedBox(width: 4),
        ]),
      ),

      //Lista de skills
      Expanded(
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: skills.length,
          separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppTheme.divider),
          itemBuilder: (_, i){
            final skill = skills[i];
            final ability = vm.skillAbility(skill);
            final bonus = vm.skillBonus(skill);
            final bonusLbl = bonus >= 0 ? '+$bonus' : '$bonus';
            final proficient = vm.skillProficient(skill);
            final expertise = vm.skillExpertise(skill);

            return Container(
              color: AppTheme.background,
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
              child: Row(children: [
                //Proficiency dot (filled = proficient, double ring = expertise)
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: proficient ? AppTheme.primary : Colors.transparent,
                  border: Border.all(
                    color: (proficient || expertise)
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                    width: expertise ? 2.5 : 1.5),
                  ),
                ),
                const SizedBox(width: 10),

              //MOD badge
              Container(
                width: 36,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_abilityAbbrev(context, ability),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),

                //Skill name
                Expanded(
                  child: Row(children: [
                    Text(_skillLabel(context, skill),
                    style: GoogleFonts.lato(
                      color: AppTheme.textPrimary, fontSize: 13)),
                    if (expertise) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
                        ),
                        child: Text('EXP',
                          style: GoogleFonts.lato(
                            color: AppTheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                      ),
                    ],
                  ]),
                ),

                //Bonus
                Text(bonusLbl,
                  style: GoogleFonts.libreBaskerville(
                    color: AppTheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                )),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  static ({String mod, String skill, String bonus}) _columnHeaders(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'es') return (mod: 'MOD', skill: 'HABILIDAD', bonus: 'BONO');
    if (code == 'gl') return (mod: 'MOD', skill: 'HABILIDADE', bonus: 'BONUS');
    return (mod: 'MOD', skill: 'SKILL', bonus: 'BONUS');
  }

  static String _abilityAbbrev(BuildContext context, String ability) {
    final s = AppStrings.of(context);
    return switch (ability) {
      'STR' => s.str,
      'DEX' => s.dex,
      'CON' => s.con,
      'INT' => s.intAttr,
      'WIS' => s.wis,
      'CHA' => s.cha,
      _ => ability,
    };
  }

  static String _skillLabel(BuildContext context, String skill) {
    return localizeSkillOrProficiency(context, skill);
  }
}