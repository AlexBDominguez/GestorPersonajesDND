import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/character/player_character_summary.dart';

class CharacterCard extends StatelessWidget {
  final PlayerCharacterSummary character;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceVariant),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            //Avatar
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
                color: AppTheme.background,
              ),
              child: const Icon(Icons.person,
                color: AppTheme.primary, size: 26),
            ),
            const SizedBox(width: 14),

            // Nombre + subtítulo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Fila: nombre + badge de nivel
                  Row(children: [
                    Flexible(
                      child: Text(
                        character.name,
                        style: GoogleFonts.cinzel(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _LevelBadge(level: character.level),
                  ]),
                  const SizedBox(height: 2),
                  //Raza (o subrace si la hubiese)
                  if(character.raceName != null) 
                    Text(
                      character.raceName!,
                      style: GoogleFonts.lato(
                        color: AppTheme.textSecondary,
                        fontSize: 12),
                        ),
                        const SizedBox(height: 1),
                        //Clase | Subclase
                        if (character.dndClassName != null)
                          Text(
                            _classLine(),
                            style: GoogleFonts.lato(
                              color: AppTheme.textSecondary,
                              fontSize: 12),
                            ),
                  ]),
          ),
          // Menú 3 puntos
          _MoreMenuButton(
              character: character,
              onEdit: onEdit,
              onDelete: onDelete,
          ),
          ]),
        ),
      ),
    );
  }

  String _classLine() {
    final parts = <String>[];
    if (character.dndClassName != null) parts.add(character.dndClassName!);
    //subclassName no está en el summary aún - se puede añadir después
    return parts.join(' | ');
  }
}  

// Level Badge

class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Lvl $level',
        style: GoogleFonts.cinzel(
          color: AppTheme.background,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Menú de los 3 puntos (editar, eliminar)

class _MoreMenuButton extends StatelessWidget {
  final PlayerCharacterSummary character;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MoreMenuButton({
    required this.character,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppTheme.surfaceVariant)),
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') _confirmDelete(context);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            const Icon(Icons.edit_outlined,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Text('Edit',
                style: GoogleFonts.lato(color: AppTheme.textPrimary)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            const Icon(Icons.delete_outline, color: AppTheme.accent, size: 18),
            const SizedBox(width: 10),
            Text('Delete',
                style: GoogleFonts.lato(color: AppTheme.accent)),
          ]),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Character?',
            style: GoogleFonts.cinzel(
                color: AppTheme.accent,
                fontSize: 17, fontWeight: FontWeight.bold)),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 14),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                  text: character.name,
                  style: GoogleFonts.cinzel(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold)),
              const TextSpan(text: '?\n\nAll data will be lost.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.lato(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(context); // cierra el dialog
              onDelete();             // ejecuta el callback
            },
            child: Text('Delete',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}