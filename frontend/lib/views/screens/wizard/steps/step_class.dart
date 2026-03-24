
import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/wizard/character_creator_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StepClass extends StatelessWidget{
  const StepClass({super.key});

  @override
  Widget build(BuildContext context){
    final vm = context.watch<CharacterCreatorViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose a Class',
            style: GoogleFonts.cinzel(
              color: AppTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Your class determines your primary abilites and hit die.',
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),

          if(vm.loadingRefs)
          const Center(
            child: CircularProgressIndicator(color: AppTheme.primary))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.classes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final cls = vm.classes[i];
                  final isSelected = vm.selectedClass?.id == cls.id;
                  return _ClassTile(
                    cls: cls,
                    isSelected: isSelected,
                    onTap: () => vm.selectClass(cls));
                },
              ),          
        ],
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  final ClassOption cls;
  final bool isSelected;
  final VoidCallback onTap;

  const _ClassTile({
    required this.cls,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
          ? AppTheme.primary.withOpacity(0.12)
          : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
            width: isSelected ? 2 : 1),
          ),
          child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.2)
                  : AppTheme.background,
              border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant),
            ),
            child: Center(
              child: Text(cls.hitDieLabel,
                  style: GoogleFonts.cinzel(
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cls.name,
                  style: GoogleFonts.cinzel(
                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text('Hit Die: ${cls.hitDieLabel}',
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ]),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 22),
        ]),
      ),
    );
  }
}