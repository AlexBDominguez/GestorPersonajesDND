import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/config/combat_features.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/racial_trait.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
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
        _RacialTraitsSection(character: character, vm: vm),

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
  const _FeatureTile({
    required this.feature,
    required this.vm,
    this.showCombatBadge = false,
  });

  /// Map a feature to its task type so we can look up the resolved choice.
  String? get _taskType {
    final n = feature.name.toLowerCase();
    if (n.contains('fighting style')) return 'FIGHTING_STYLE';
    if (n.contains('favored enemy'))  return 'FAVORED_ENEMY';
    if (n.contains('natural explorer') || n.contains('favored terrain')) return 'FAVORED_TERRAIN';
    if (n.contains('draconic ancestry')) return 'DRACONIC_ANCESTRY';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isConsumable = vm.isConsumableFeature(feature);
    final maxUses = vm.featureMaxUses(feature);
    final remaining = vm.featureUsesRemaining(feature);
    final taskType = _taskType;
    final resolvedChoice = taskType != null
        ? vm.resolvedChoiceFor(taskType, feature.level)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.surfaceVariant,
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
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
                ),
              // Resolved choice badge (e.g. "Undead", "Coast", etc.)
              if (resolvedChoice != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8A45A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFC8A45A).withOpacity(0.5)),
                  ),
                  child: Text(resolvedChoice,
                    style: GoogleFonts.lato(
                      color: const Color(0xFFC8A45A),
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
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
  final CharacterSheetViewModel vm;
  const _RacialTraitsSection({required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingTraits) {
      return const Padding(
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
    final traits = vm.racialTraits;

    if(traits.isEmpty){
      return _EmptyCard(message: 'No racial traits loaded.');
    }

    return Column(
      children: traits.map((t) => _RacialTraitTile(trait: t, vm: vm)).toList(),      
    );
  }
}

class _RacialTraitTile extends StatelessWidget {
  final RacialTrait trait;
  final CharacterSheetViewModel vm;
  const _RacialTraitTile({required this.trait, required this.vm});

  /// Map an indexName to the task type whose resolved choice describes this trait.
  String? get _ancestryTaskType {
    final idx = trait.indexName.toLowerCase();
    // Direct draconic ancestry choice
    if (idx.contains('draconic-ancestry') || idx.contains('draconic_ancestry')) {
      return 'DRACONIC_ANCESTRY';
    }
    // Breath weapon and damage resistance are DERIVED from draconic ancestry
    if (idx.contains('breath-weapon') || idx.contains('breath_weapon') ||
        idx.contains('damage-resistance') || idx.contains('damage_resistance')) {
      return 'DRACONIC_ANCESTRY'; // show the ancestry as context
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ancestryTaskType = _ancestryTaskType;
    final resolvedAncestry = ancestryTaskType != null
        ? vm.resolvedChoiceFor(ancestryTaskType, 1)
        : null;

    // Build a disambiguated subtitle for traits derived from ancestry
    final String? ancestrySuffix;
    if (resolvedAncestry != null) {
      final idx = trait.indexName.toLowerCase();
      if (idx.contains('draconic-ancestry') || idx.contains('draconic_ancestry')) {
        ancestrySuffix = resolvedAncestry;
      } else if (idx.contains('breath-weapon') || idx.contains('breath_weapon')) {
        ancestrySuffix = resolvedAncestry; // dragon type determines the element
      } else if (idx.contains('damage-resistance') || idx.contains('damage_resistance')) {
        ancestrySuffix = resolvedAncestry;
      } else {
        ancestrySuffix = null;
      }
    } else {
      ancestrySuffix = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
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
              Text(trait.name,
                  style: GoogleFonts.cinzel(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
              if (trait.isCombatRelevant)
                _TypeBadge('combat', AppTheme.primary),
              // Show the resolved ancestry choice as a gold badge
              if (ancestrySuffix != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8A45A).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFC8A45A).withOpacity(0.5)),
                  ),
                  child: Text(ancestrySuffix,
                    style: GoogleFonts.lato(
                      color: const Color(0xFFC8A45A),
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
                )
              else if (trait.requiresChoice)
                _TypeBadge('choose!', Colors.orange),
            ],
          ),
          iconColor: AppTheme.textSecondary,
          collapsedIconColor: AppTheme.textSecondary,
          children: [
            Text(
              trait.description.isNotEmpty
                  ? trait.description
                  : 'No description available.',
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label,
      style: GoogleFonts.lato(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5)),
  );
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