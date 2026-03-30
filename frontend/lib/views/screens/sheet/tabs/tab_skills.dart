import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class TabSkills extends StatelessWidget{
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabSkills({super.key, required this.character, required this.vm});

  @override
  Widget build(BuildContext context){
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
            child: Text('MOD',
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const Expanded(
            child: Text('SKILL',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10
            )),            
          ),
          Text('BONUS',
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
          itemCount: CharacterSheetViewModel.skillNames.length,
          separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppTheme.divider),
          itemBuilder: (_, i){
            final skill = CharacterSheetViewModel.skillNames[i];
            final ability = vm.skillAbility(skill);
            final bonus = vm.skillBonus(skill);
            final bonusLbl = bonus >= 0 ? '+$bonus' : '$bonus';
            //TODO: cuando backend devuelva proficiencies, marcar el dot
            const proficient = false;

            return Container(
              color: AppTheme.background,
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
              child: Row(children: [
                //Proficiency dot
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: proficient ? AppTheme.primary : Colors.transparent,
                  border: Border.all(
                    color: proficient
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                    width: 1.5),
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
                child: Text(ability,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),

                //Skill name
                Expanded(
                  child: Text(skill,
                  style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 13)),
                ),

                //Bonus
                Text(bonusLbl,
                  style: GoogleFonts.cinzel(
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
}