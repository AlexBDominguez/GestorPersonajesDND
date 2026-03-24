import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/character/player_character_summary.dart';

class CharacterCard extends StatelessWidget {
  final PlayerCharacterSummary character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  // Calcula color de la barra de HP
  Color _hpColor() {
    if (character.maxHp == 0) return AppTheme.textSecondary;
    final ratio = character.currentHp / character.maxHp;
    if (ratio > 0.6) return const Color(0xFF2D6A4F);   // verde
    if (ratio > 0.3) return const Color(0xFFC8A45A);   // dorado
    return AppTheme.accent;                              // rojo
  }

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
        child: Column(
          children: [
            //Cabecera dorada
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  // Icono de clase/personaje
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                      color: AppTheme.background,
                    ),
                    child: const Icon(Icons.person, color: AppTheme.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  // Nombre y subtítulo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          character.name,
                          style: GoogleFonts.cinzel(
                            color: AppTheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle(),
                          style: GoogleFonts.lato(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge de nivel
                  _LevelBadge(level: character.level),
                ],
              ),
            ),

            //Cuerpo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Estadísticas rápidas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(icon: Icons.shield_outlined,
                          label: 'AC', value: '${character.armorClass}'),
                      _StatChip(icon: Icons.favorite_outline,
                          label: 'HP',
                          value: '${character.currentHp}/${character.maxHp}'),
                      if (character.hasInspiration)
                        _StatChip(icon: Icons.star,
                            label: 'Inspiration', value: '✦',
                            valueColor: AppTheme.primary),
                      if (character.alignment != null)
                        _StatChip(icon: Icons.balance_outlined,
                            label: 'Alignment',
                            value: _shortAlignment(character.alignment!)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Barra de HP
                  if (character.maxHp > 0) ...[
                    Row(
                      children: [
                        Text('HP', style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 11)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (character.currentHp / character.maxHp)
                                  .clamp(0.0, 1.0),
                              backgroundColor: AppTheme.background,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_hpColor()),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${character.currentHp}/${character.maxHp}',
                          style: GoogleFonts.lato(
                              color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            //Footer: XP 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XP: ${character.experiencePoints}',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text('Ver ficha',
                          style: GoogleFonts.lato(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right,
                          color: AppTheme.primary, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    if (character.raceName != null) parts.add(character.raceName!);
    if (character.dndClassName != null) parts.add(character.dndClassName!);
    return parts.isEmpty ? 'Aventurero' : parts.join(' · ');
  }

  String _shortAlignment(String alignment) {
    // Abreviatura del alineamiento (ej: "Lawful Good" → "LG")
    return alignment
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }
}

// Widgets auxiliares privados

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
        'Nv $level',
        style: GoogleFonts.cinzel(
          color: AppTheme.background,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.cinzel(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 10)),
      ],
    );
  }
}