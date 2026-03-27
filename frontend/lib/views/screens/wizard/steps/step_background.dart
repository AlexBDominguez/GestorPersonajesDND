import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_theme.dart';
import '../../../../models/wizard/background_option.dart';
import '../../../../viewmodels/wizard/character_creator_viewmodel.dart';

class StepBackground extends StatelessWidget {
  const StepBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose a Background',
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Your background shapes your character\'s history and skills.',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),

          if (vm.isLoading)
            const Center(
                child: CircularProgressIndicator(color: AppTheme.primary))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.backgrounds.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final bg = vm.backgrounds[i];
                final isSelected = vm.selectedBackground?.id == bg.id;
                return _BackgroundTile(
                    bg: bg,
                    isSelected: isSelected,
                    onTap: () => vm.selectBackground(bg));
              },
            ),
        ],
      ),
    );
  }
}

class _BackgroundTile extends StatelessWidget {
  final BackgroundOption bg;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundTile(
      {required this.bg, required this.isSelected, required this.onTap});

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
          Icon(Icons.menu_book_outlined,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bg.name,
                    style: GoogleFonts.cinzel(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                if (bg.description.isNotEmpty)
                  Text(bg.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppTheme.primary, size: 22),
        ]),
      ),
    );
  }
}