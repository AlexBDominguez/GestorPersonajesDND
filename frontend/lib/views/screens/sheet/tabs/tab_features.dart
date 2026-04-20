import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/config/combat_features.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_combat.dart';
import 'package:google_fonts/google_fonts.dart';

class TabFeatures extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabFeatures({super.key, required this.character, required this.vm});

  @override
  Widget build(BuildContext context){
    return ListenableBuilder(
      listenable: vm, 
      builder: (_, __) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isLoading = vm.isLoadingFeatures || vm.isLoadingSubclassFeatures;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        //-- Class Features
        _GroupHeader(
          label: 'Class Features',
          sublabel: character.dndClassName,
          icon: Icons.auto_fix_high_outlined,
          color: AppTheme.primary,
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const _LoadingRow()
        else if (vm.classFeatures.isEmpty)
          _EmptyCard(message: 'No class features loaded.')
        else
          ...vm.classFeatures.map((f) => _FeatureTile(
            feature: f,
            vm: vm,
            showCombatBadge: isCombatRelevant(f.indexName),
          )),

        // -- Subclass Features (si las hay, en el mismo bloque de clase)
        if (vm.subclassFeatures.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6, top: 4),
            child: Row(children: [
              const Icon(Icons.arrow_right,
                color: AppTheme.textSecondary, size: 16),
              Text(
                character.subclassName ?? 'Subclass',
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 11, 
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
              ),
            ]),
          ),
          ...vm.subclassFeatures.map((f) => _FeatureTile(
            feature: f,
            vm: vm,
            showCombatBadge: isCombatRelevant(f.indexName),
          )),
        ],

        const SizedBox(height: 24),

        //-- Racial Traits
        _GroupHeader(
          label: 'Racial Traits',
          sublabel: character.raceName,
          icon: Icons.nature_people_outlined,
          color: Color(0xFF7FAACC),
        ),
        const SizedBox(height: 8),
        _RacialTraitsSection(character: character),

        const SizedBox(height: 24),

        //-- Feats
        _GroupHeader(
          label: 'Feats',
          sublabel: null,
          icon: Icons.star_outline,
          color: const Color(0xFFC8A45A),
        ),
        const SizedBox(height: 8),
        _FeatsSection(character: character, vm: vm),
      ]),
    );
  }
}

// -- Group Header
class _GroupHeader extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData icon;
  final Color color;
  const _GroupHeader({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.cinzel(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8)),
        if (sublabel != null) ...[
          const SizedBox(width: 6),
          Text('· $sublabel',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic)),
        ],
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
      ]);
}

// -- Feature tile con badge "combat"
class _FeatureTile extends StatelessWidget {
  final ClassFeature feature;
  final CharacterSheetViewModel vm;
  final bool showCombatBadge;
  final bool isSubclass;
  const _FeatureTile({
    required this.feature,
    required this.vm,
    this.showCombatBadge = false,
    this.isSubclass = false,
  });

  @override
  Widget build(BuildContext context) {
    final isConsumable = vm.isConsumableFeature(feature);
    final maxUses = vm.featureMaxUses(feature);
    final remaining = vm.featureUsesRemaining(feature);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSubclass
              ? AppTheme.surfaceVariant.withOpacity(0.6)
              : AppTheme.surfaceVariant,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 4, 10, 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(feature.name,
                  style: GoogleFonts.cinzel(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
              // Badge "combat" - indica que también aparece en la tab Combat
              if (showCombatBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.4)),
                  ),
                  child: Text('combat',
                    style: GoogleFonts.lato(
                      color: AppTheme.primary,
                      fontSize: 0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
                ),
            ],
          ),
          subtitle: Row(children: [
            Text('Level ${feature.level}',
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 10)),
            //Contadores de usos (mismo círculo que en Combat)
            if (isConsumable) ...[
              const SizedBox(width: 8),
              ...List.generate(maxUses, (i) {
                final isUsed = i >= remaining;
                return GestureDetector(
                  onTap: () => 
                    isUsed ? vm.restoreFeature(feature) :
                    vm.useFeature(feature),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUsed ? Colors.transparent : AppTheme.primary,
                        border: Border.all(
                          color: isUsed ? AppTheme.textSecondary : AppTheme.primary,
                          width: 1.5
                          ),
                        ),
                      ),
                    ),
                  );
              }),
            ],
          ]),
          iconColor: AppTheme.textSecondary,
          collapsedIconColor: AppTheme.textSecondary,
          children: [
            Text(feature.description,
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// -- Racial traits section
//Por ahora muestra los datos que ya tenemos de la raza.
//Cuando existan RacialTrait entities, este widget se actualizará.

class _RacialTraitsSection extends StatelessWidget {
  final PlayerCharacter character;
  const _RacialTraitsSection({required this.character});

  @override
  Widget build(BuildContext context) {
    // Los traits individuales aún no vienen del backend como entidades separadas.
    // Mostramos la info disponible + aviso honesto.
    final rows = <(String, String)>[];
    if (character.raceName != null) {
      rows.add(('Race', character.raceName!));
    }
    if (character.subraceName != null) {
      rows.add(('Subrace', character.subraceName!));
    }

    return Column(children: [
      // Info disponible
      if (rows.isNotEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: Column(
            children: rows.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                SizedBox(
                  width: 70,
                  child: Text('${r.$1}:',
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Text(r.$2,
                      style: GoogleFonts.cinzel(
                          color: AppTheme.textPrimary, fontSize: 13)),
                ),
              ]),
            )).toList(),
          ),
        ),
      const SizedBox(height: 8),
      // Aviso honesto sobre los traits pendientes
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline,
              color: AppTheme.textSecondary, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Individual racial traits (Darkvision, Fey Ancestry, etc.) will appear here once the backend provides them as separate entities.',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ]),
      ),
    ]);
  }
}

//-- Feats
// Placeholder - los feats del personaje vendrán cuando se implemente
// el endpoint GET /api/characters/{id}/feats
class _FeatsSection extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const _FeatsSection({required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    return _EmptyCard(
      message: 'No feats assigned.',
      hint: 'Feats can be chosen during level-up (levels 4, 8, 12, 16, 19).',
    );
  }
}

//Widgets auxiliares

class _EmptyCard extends StatelessWidget {
  final String message;
  final String? hint;
  const _EmptyCard({required this.message, this.hint});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.surfaceVariant),
    ),
    child: Column (mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.auto_awesome_outlined,
      color: AppTheme.surfaceVariant, size: 32),
      const SizedBox(height: 8),
      Text(message,
        style: GoogleFonts.lato(
          color: AppTheme.textSecondary, fontSize: 13)),
      if (hint != null) ...[
        const SizedBox(height: 4),
        Padding(
          padding:const EdgeInsets.symmetric(horizontal: 24),
          child: Text(hint!,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontStyle: FontStyle.italic)),
        ),
      ],
    ]),
  );
}
class _LoadingRow extends StatelessWidget {
  const _LoadingRow();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.primary),
          ),
        ),
      );
}