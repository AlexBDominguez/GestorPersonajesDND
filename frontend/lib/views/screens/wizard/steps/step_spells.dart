import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/wizard/spell_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/wizard/character_creator_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class StepSpells extends StatefulWidget {
  const StepSpells({super.key});

  @override
  State<StepSpells> createState() => _StepSpellsState();
}

class _StepSpellsState extends State<StepSpells> {
  //Filtro de nivel: -1 = todos, 0 = cantrips, 1-9 = niveles
  int _filterLevel = -1;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    if(vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    //Spells filtrados por nivel y búsqueda
    final filtered = vm.availableSpells.where((s) {
      final matchLevel = _filterLevel == -1 || s.level == _filterLevel;
      final query = _searchCtrl.text.toLowerCase();
      final matchSearch = query.isEmpty || s.name.toLowerCase().contains(query);
      return matchLevel && matchSearch;
    }).toList();

    //Niveles disponibles según lo que devuelve el backend
    final levels = <int>{};
    for (final s in vm.availableSpells) levels.add(s.level);
    final sortedLevels = [-1, ... levels.toList()..sort()];

    final selectedCount = vm.selectedSpellIds.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      //Header -----------
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Choose your Spells', 
                style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(
                'Select the spells you start with. You can add more later.',
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 13),
               ),
            ],)
          ),
          //Badge contador
          if (selectedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary),
              ),
              child: Text('$selectedCount selected',
                style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
                  ),
            ]),
          ),

          //BUscador -------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search spells...',
                hintStyle: GoogleFonts.lato(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, 
                  color: AppTheme.primary, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {_searchCtrl.clear(); setState(() {});},
                  )
                  : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          //Filtro por nivel -------------
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: sortedLevels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final lvl = sortedLevels[i];
                final label = lvl == -1
                  ? 'All'
                  : lvl == 0
                    ? 'Cantrips'
                    : 'Lv $lvl';
                final selected = _filterLevel == lvl;
                return GestureDetector(
                  onTap: () => setState(() => _filterLevel = lvl),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppTheme.primary: AppTheme.divider),
                    ),
                    child: Text(label,
                      style: GoogleFonts.cinzel(
                        color: selected
                          ? AppTheme.background
                          : AppTheme.textSecondary,
                        fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                );
              },                 
            )
          ),
          const Divider(height: 1),

          //Lista de hechizos
          Expanded(
            child: filtered.isEmpty
            ? Center(
                child: Text('No spells found',
                  style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 14)))
            : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                const SizedBox(height: 6),
              itemBuilder: (_, i) =>
                _SpellTile(spell: filtered[i], vm: vm),
            ),
          ),
    ]);
  }
}

class _SpellTile extends StatelessWidget {
  final SpellOption spell;
  final CharacterCreatorViewModel vm;
  const _SpellTile({required this.spell, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.selectedSpellIds.contains(spell.id);

    return GestureDetector(
      onTap: () => vm.toggleSpell(spell.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),  
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          //Checkbox visual
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                width: 1.5,
              ),
            ),
            child: isSelected
              ? const Icon(Icons.check, size: 14, color:
              AppTheme.background)
              : null,
          ),
          const SizedBox(width: 12),

          //Info del hechizo
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(spell.name,
                    style: GoogleFonts.cinzel(
                      color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textPrimary,
                      fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    spell.isCantrip ? 'Cantrip' : 'Lv ${spell.level}',
                    style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 10),
                  ),
                ),
              ]),
              if (spell.school != null || spell.castingTime != null) ... [
                const SizedBox(height: 3),
                Row(children: [
                  if (spell.school != null)
                    _Tag(spell.school!),
                  if (spell.school != null && spell.castingTime != null)
                    const SizedBox(width: 4),
                  if (spell.castingTime != null)
                    _Tag(spell.castingTime!),
                ]),
              ],
              if (spell.description != null &&
                  spell.description!.isNotEmpty) ... [
                const SizedBox(height: 4),
                Text(
                  spell.description!.length > 120
                    ? '${spell.description!.substring(0, 120)}...'
                    : spell.description!,
                  style: GoogleFonts.lato(
                    color: AppTheme.textSecondary,
                    fontSize: 11, height: 1.4),
                ),
                  ],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Tag extends StatelessWidget{
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: AppTheme.surfaceVariant,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text,
      style: GoogleFonts.lato(
        color: AppTheme.textSecondary,
        fontSize: 10)),
    );
}
             