import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';

class StepClass extends StatelessWidget {
  const StepClass({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text('Choose your Class',
              style: Theme.of(context).textTheme.displayMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text('Your class is the primary definition of what your character does.',
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.classes.length,
            itemBuilder: (_, i) {
              final cls = vm.classes[i];
              final isSelected = vm.selectedClass?.id == cls.id;
              return Column(children: [
                GestureDetector(
                  onTap: () => vm.selectClass(cls),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.15)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.surfaceVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        // Hit die badge
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('d${cls.hitDie}',
                                style: GoogleFonts.cinzel(
                                    color: isSelected
                                        ? AppTheme.background
                                        : AppTheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ]),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(cls.name,
                                style: GoogleFonts.cinzel(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            if (cls.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(cls.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12)),
                            ],
                            if (cls.proficiencies.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(spacing: 4, runSpacing: 4,
                                  children: cls.proficiencies
                                      .take(3)
                                      .map((p) => _Tag(p))
                                      .toList()),
                            ],
                          ]),
                        ),
                        Icon(
                          isSelected
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppTheme.textSecondary,
                        ),
                      ]),
                    ),
                  ),
                ),
                // Features expandidas cuando está seleccionada
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(color: AppTheme.primary, width: 1),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Level 1 Features',
                          style: GoogleFonts.cinzel(
                              color: AppTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'HP: d${cls.hitDie} + CON modifier',
                        style: GoogleFonts.lato(
                            color: AppTheme.textPrimary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saving Throws & Proficiencies will be loaded from the backend.',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ]),
                  ),
              ]);
            },
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 10)),
      );
}