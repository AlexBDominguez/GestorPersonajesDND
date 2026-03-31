import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:google_fonts/google_fonts.dart';

class TabInventory extends StatelessWidget{
  final PlayerCharacter character;
  const TabInventory({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[

        //4.1 Currency
        _SectionTitle('Currency'),
        const SizedBox(height: 10),
        _CurrencyRow(),
        const SizedBox(height: 24),

        //4.2 Attuned Items
        _SectionTitle('Attuned Items'),
        const SizedBox(height: 4),
        Text('Maximum 3 attuned items.', 
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary, fontSize: 11,
            fontStyle: FontStyle.italic)),
        const SizedBox(height: 10),
        ...List.generate(3, (i) => _AttunedSlot(index: i+1)),
        const SizedBox(height: 24),

        //4.3 Equipment
        _SectionTitle('Equipment'),
        const SizedBox(height: 4),
        Text(
          'Equipping/unequipping items will be available in future updates.',
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary, fontSize: 11,
            fontStyle: FontStyle.italic),              
          ),
        const SizedBox(height: 10),
        _EmptySlot(message: 'No equipment added yet'),
        const SizedBox(height: 24),

        //4.4 Backpack
        _SectionTitle('Backpack'),
        const SizedBox(height: 10),
        _EmptySlot(message: 'No items in backpack'),
        const SizedBox(height: 16),        
      ]),
    );
  }
}

//Currency
class _CurrencyRow extends StatelessWidget{
  //Datos hardcodeados por ahora - TODO: conectar con Backend
  static const _coins = [
    ('CP', Colors.brown),
    ('SP', Colors.grey),
    ('EP', Color(0xFF7FAACC)),
    ('GP', Color(0xFFC8A45A)),
    ('PP', Color(0xFFB0A0C8)),
  ];

  const _CurrencyRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _coins.map((entry){
        final label = entry.$1;
        final color = entry.$2;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: (color as Color).withOpacity(0.5)),
            ),
            child: Column(children: [
              Text('0', 
                style: GoogleFonts.cinzel(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label,
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 10,
                fontWeight: FontWeight.bold)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// Attuned Item Slot
class _AttunedSlot extends StatelessWidget{
  final int index;
  const _AttunedSlot({required this.index});

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.25), style: BorderStyle.solid),
        ),
        child: Row(children: [
          Icon(Icons.auto_fix_high_outlined,
            color: AppTheme.primary.withOpacity(0.4), size: 18),
            const SizedBox(width: 10),
            Text('Attunement slot $index - empty',
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 13,
                fontStyle: FontStyle.italic)),
        ]),
    );    
  }
}

//Empty Placeholder
class _EmptySlot extends StatelessWidget{
  final String message;
  const _EmptySlot({required this.message});

  @override
  Widget build(BuildContext context){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(children: [
        Icon(Icons.inventory_2_outlined,
          color: AppTheme.surfaceVariant, size: 36),
        const SizedBox(height: 8),
        Text(message,
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary, fontSize: 13,
            fontStyle: FontStyle.italic)),
      ]),
    );
  }
}

//Section Title
class _SectionTitle extends StatelessWidget{
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title,
      style: GoogleFonts.cinzel(
          color: AppTheme.primary, fontSize: 14,
          fontWeight: FontWeight.bold, letterSpacing: 1)),
    const SizedBox(width: 10),
    const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
  ]);
}

