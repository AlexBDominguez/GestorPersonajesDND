import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/config/combat_features.dart';
import 'package:gestor_personajes_dnd/l10n/app_strings.dart';
import 'package:gestor_personajes_dnd/l10n/dnd_terms.dart';
import 'package:gestor_personajes_dnd/models/character/character_spell.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';
import 'package:gestor_personajes_dnd/models/wizard/class_option.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

// Shared column widths (keep in sync with tab_spells.dart)
const double _kHitDcW = 62.0;
const double _kDmgW   = 80.0;
const double _kColGap =  8.0;

String _tr(BuildContext context, {required String en, required String es, required String gl}) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'es') return es;
  if (code == 'gl') return gl;
  return en;
}

String _spellDetailLabel(BuildContext context, String key) {
  return switch (key) {
    'castingTime' => _tr(context, en: 'Casting Time', es: 'Tiempo de lanzamiento', gl: 'Tempo de lanzamento'),
    'range' => _tr(context, en: 'Range', es: 'Alcance', gl: 'Alcance'),
    'duration' => _tr(context, en: 'Duration', es: 'Duracion', gl: 'Duracion'),
    'components' => _tr(context, en: 'Components', es: 'Componentes', gl: 'Componentes'),
    'status' => _tr(context, en: 'Status', es: 'Estado', gl: 'Estado'),
    'description' => _tr(context, en: 'Description', es: 'Descripcion', gl: 'Descricion'),
    'prepared' => _tr(context, en: 'Prepared ✓', es: 'Preparado ✓', gl: 'Preparado ✓'),
    'learned' => _tr(context, en: 'Learned', es: 'Aprendido', gl: 'Aprendido'),
    _ => key,
  };
}

String _actionNameLocalized(BuildContext context, String name) {
  return switch (name) {
    'Attack' => _tr(context, en: 'Attack', es: 'Ataque', gl: 'Ataque'),
    'Dash' => _tr(context, en: 'Dash', es: 'Desplazarse', gl: 'Desprazarse'),
    'Disengage' => _tr(context, en: 'Disengage', es: 'Retirada', gl: 'Retirada'),
    'Dodge' => _tr(context, en: 'Dodge', es: 'Esquivar', gl: 'Esquivar'),
    'Grapple' => _tr(context, en: 'Grapple', es: 'Agarrar', gl: 'Agarre'),
    'Help' => _tr(context, en: 'Help', es: 'Ayudar', gl: 'Axudar'),
    'Hide' => _tr(context, en: 'Hide', es: 'Ocultarse', gl: 'Agocharse'),
    'Improvise' => _tr(context, en: 'Improvise', es: 'Improvisar', gl: 'Improvisar'),
    'Influence' => _tr(context, en: 'Influence', es: 'Influir', gl: 'Influir'),
    'Magic' => _tr(context, en: 'Magic', es: 'Magia', gl: 'Maxia'),
    'Ready' => _tr(context, en: 'Ready', es: 'Preparar', gl: 'Preparar'),
    'Search' => _tr(context, en: 'Search', es: 'Buscar', gl: 'Buscar'),
    'Shove' => _tr(context, en: 'Shove', es: 'Empujar', gl: 'Empurrar'),
    'Study' => _tr(context, en: 'Study', es: 'Estudiar', gl: 'Estudar'),
    'Utilize' => _tr(context, en: 'Utilize', es: 'Utilizar', gl: 'Utilizar'),
    'Off-Hand Attack' => _tr(context, en: 'Off-Hand Attack', es: 'Ataque con mano torpe', gl: 'Ataque coa man torpe'),
    'Opportunity Attack' => _tr(context, en: 'Opportunity Attack', es: 'Ataque de oportunidad', gl: 'Ataque de oportunidade'),
    'Readied Action' => _tr(context, en: 'Readied Action', es: 'Acción preparada', gl: 'Acción preparada'),
    _ => name,
  };
}

String _actionDescLocalized(BuildContext context, _ActionEntry action) {
  return switch (action.name) {
    'Attack' => _tr(context, en: action.desc, es: 'Realiza un ataque de arma. Los ataques extra de clase pueden permitir más.', gl: 'Realiza un ataque de arma. Os ataques extra de clase poden permitir máis.'),
    'Dash' => _tr(context, en: action.desc, es: 'Ganas movimiento adicional igual a tu velocidad en este turno.', gl: 'Gañas movemento adicional igual á túa velocidade nesta quenda.'),
    'Disengage' => _tr(context, en: action.desc, es: 'Tu movimiento no provoca ataques de oportunidad hasta el final del turno.', gl: 'O teu movemento non provoca ataques de oportunidade ata o final da quenda.'),
    'Dodge' => _tr(context, en: action.desc, es: 'Hasta tu próximo turno, los ataques contra ti tienen desventaja y tú tienes ventaja en salvaciones de Destreza.', gl: 'Ata a túa próxima quenda, os ataques contra ti teñen desvantaxe e ti tes vantaxe en salvacións de Destreza.'),
    'Grapple' => _tr(context, en: action.desc, es: 'Ataque cuerpo a cuerpo especial. Prueba enfrentada: tu Atletismo contra su Atletismo o Acrobacias.', gl: 'Ataque corpo a corpo especial. Proba enfrontada: o teu Atletismo contra o seu Atletismo ou Acrobacias.'),
    'Help' => _tr(context, en: action.desc, es: 'Concedes ventaja a un aliado en la siguiente prueba de habilidad o tirada de ataque contra una criatura a 5 pies.', gl: 'Concedes vantaxe a un aliado na seguinte proba de habilidade ou tirada de ataque contra unha criatura a 5 pés.'),
    'Hide' => _tr(context, en: action.desc, es: 'Haz una prueba de Sigilo. Si tiene éxito, permaneces oculto hasta atacar o ser detectado.', gl: 'Fai unha proba de Sixilo. Se ten éxito, permaneces agochado ata atacar ou ser detectado.'),
    'Improvise' => _tr(context, en: action.desc, es: 'Haz algo no cubierto por otras acciones. El DM decide el resultado.', gl: 'Fai algo non cuberto por outras accións. O DM decide o resultado.'),
    'Influence' => _tr(context, en: action.desc, es: 'Haz una prueba de Persuasión, Engaño o Intimidación para influir en la actitud de una criatura.', gl: 'Fai unha proba de Persuasión, Engaño ou Intimidación para influír na actitude dunha criatura.'),
    'Magic' => _tr(context, en: action.desc, es: 'Lanza un conjuro con tiempo de lanzamiento de 1 acción o usa un objeto mágico.', gl: 'Lanza un conxuro con tempo de lanzamento de 1 acción ou usa un obxecto máxico.'),
    'Ready' => _tr(context, en: action.desc, es: 'Preparas una reacción para un desencadenante concreto. Declara acción y desencadenante.', gl: 'Preparas unha reacción para un desencadeante concreto. Declara acción e desencadeante.'),
    'Search' => _tr(context, en: action.desc, es: 'Haz una prueba de Percepción o Investigación para encontrar algo no evidente.', gl: 'Fai unha proba de Percepción ou Investigación para atopar algo non evidente.'),
    'Shove' => _tr(context, en: action.desc, es: 'Ataque cuerpo a cuerpo especial para empujar a una criatura 5 pies o derribarla.', gl: 'Ataque corpo a corpo especial para empurrar unha criatura 5 pés ou derrubala.'),
    'Study' => _tr(context, en: action.desc, es: 'Haz una prueba de Inteligencia para recordar conocimientos o analizar algo.', gl: 'Fai unha proba de Intelixencia para lembrar coñecementos ou analizar algo.'),
    'Utilize' => _tr(context, en: action.desc, es: 'Usa un objeto o activa un dispositivo (trampa, cerradura u objeto especial).', gl: 'Usa un obxecto ou activa un dispositivo (trampa, pechadura ou obxecto especial).'),
    'Off-Hand Attack' => _tr(context, en: action.desc, es: 'Al hacer la acción Atacar con un arma ligera cuerpo a cuerpo, puedes usar una acción adicional para atacar con otra arma ligera en la otra mano.', gl: 'Ao facer a acción Atacar cunha arma lixeira corpo a corpo, podes usar unha acción adicional para atacar con outra arma lixeira na outra man.'),
    'Opportunity Attack' => _tr(context, en: action.desc, es: 'Cuando una criatura que ves sale de tu alcance, puedes hacer un ataque cuerpo a cuerpo como reacción.', gl: 'Cando unha criatura que ves sae do teu alcance, podes facer un ataque corpo a corpo como reacción.'),
    'Readied Action' => _tr(context, en: action.desc, es: 'Realiza la acción que preparaste cuando ocurra el desencadenante declarado.', gl: 'Realiza a acción que preparaches cando ocorra o desencadeante declarado.'),
    _ => action.desc,
  };
}

// ── Tab Combat ────────────────────────────────────────────────────────────────

class TabCombat extends StatefulWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabCombat({super.key, required this.character, required this.vm});

  @override
  State<TabCombat> createState() => _TabCombatState();
}

class _TabCombatState extends State<TabCombat> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final c  = widget.character;
    final vm = widget.vm;
    final loc = AppStrings.of(context);

    final actionSpells = c.characterSpells
        .where((s) => _isAction(s) && (s.isCantrip || s.prepared))
        .toList()..sort((a, b) => a.level.compareTo(b.level));
    final bonusSpells = c.characterSpells
        .where((s) => _isBonus(s) && (s.isCantrip || s.prepared))
        .toList()..sort((a, b) => a.level.compareTo(b.level));
    final reactionSpells = c.characterSpells
        .where((s) => _isReaction(s) && (s.isCantrip || s.prepared))
        .toList();

        final actionFeatures =
          vm.combatFeaturesByCategory(FeatureCategory.combatAction)
              + vm.subclassFeatures.where((f) => classifyFeature(f.indexName) ==
                  FeatureCategory.combatAction).toList();
        final bonusFeatures =
          vm.combatFeaturesByCategory(FeatureCategory.combatBonus)
              + vm.subclassFeatures.where((f) => classifyFeature(f.indexName) ==
                  FeatureCategory.combatBonus).toList();
        final reactionFeatures =
          vm.combatFeaturesByCategory(FeatureCategory.combatReaction)
              + vm.subclassFeatures.where((f) => classifyFeature(f.indexName) ==
                  FeatureCategory.combatReaction).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── 1. Actions ───────────────────────────────────────────────────────
        _SectionTitle(loc.actions),
        const SizedBox(height: 8),
        // Standard Actions are actions — show them first inside Actions
        _StandardActionsCard(),
        const SizedBox(height: 8),
        if (vm.equippedWeapons.isNotEmpty) ...[
          _WeaponAttackTable(weapons: vm.equippedWeapons, character: c),
          const SizedBox(height: 8),
        ],
        if (actionSpells.isNotEmpty) ...[
          _SpellAttackTable(spells: actionSpells, vm: vm),
          const SizedBox(height: 8),
        ],
        if (vm.isLoadingFeatures)
          const _LoadingRow()
        else
          _FeatureGroup(features: actionFeatures, vm: vm),
        const SizedBox(height: 16),

        // ── 3. Bonus Actions ─────────────────────────────────────────────────
        _SectionTitle(loc.bonusActions),
        const SizedBox(height: 8),
        if (bonusSpells.isNotEmpty) ...[
          _SpellAttackTable(spells: bonusSpells, vm: vm),
          const SizedBox(height: 8),
        ],
        _StaticSection(actions: kBonusActions),
        if (bonusFeatures.isNotEmpty) ...[
          const SizedBox(height: 8),
          _FeatureGroup(features: bonusFeatures, vm: vm),
        ],
        const SizedBox(height: 16),

        // ── 4. Reactions ─────────────────────────────────────────────────────
        _SectionTitle(loc.reactions),
        const SizedBox(height: 8),
        if (reactionSpells.isNotEmpty) ...[
          _SpellAttackTable(spells: reactionSpells, vm: vm),
          const SizedBox(height: 8),
        ],
        _StaticSection(actions: kReactions),
        if (reactionFeatures.isNotEmpty) ...[
          const SizedBox(height: 8),
          _FeatureGroup(features: reactionFeatures, vm: vm),
        ],
        const SizedBox(height: 20),

        // ── 5. Death Saves (conditional) ─────────────────────────────────────
        if (!c.isConscious || c.isDying || c.currentHp == 0) ...[
          _SectionTitle(loc.deathSavingThrows),
          const SizedBox(height: 8),
          _DeathSavesRow(
            successes: c.deathSaveSuccesses,
            failures: c.deathSaveFailures,
            onSuccessTap: () => vm.recordDeathSave(success: true),
            onFailureTap: () => vm.recordDeathSave(success: false),
            onReset: () => vm.resetDeathSaves(),
          ),
          const SizedBox(height: 20),
        ],

        // ── 6. Hit Dice & Speed ───────────────────────────────────────────────
        _SectionTitle(loc.hitDiceAndSpeed),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.surfaceVariant),
          ),
          child: Row(children: [
            const Icon(Icons.casino_outlined, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Text('${loc.hitDice}: ',
                style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
            Text('${c.availableHitDice}',
                style: GoogleFonts.libreBaskerville(
                    color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.directions_run, color: AppTheme.textSecondary, size: 16),
            const SizedBox(width: 4),
            Text('${c.currentSpeed} ft',
                style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  static bool _isAction(CharacterSpell s) {
    final ct = s.castingTime?.toLowerCase() ?? '';
    return ct.contains('1 action') || ct == 'action';
  }

  static bool _isBonus(CharacterSpell s) =>
      s.castingTime?.toLowerCase().contains('bonus') ?? false;

  static bool _isReaction(CharacterSpell s) =>
      s.castingTime?.toLowerCase().contains('reaction') ?? false;
}

// ── Feature group: lista de features de una categoría ────────────────────────────────────────────
class _FeatureGroup extends StatelessWidget {
  final List<ClassFeature> features;
  final CharacterSheetViewModel vm;
  const _FeatureGroup({required this.features, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) return const SizedBox.shrink();
    return Column(
      children: features.map((feature) => 
      _FeatureTile(feature: feature, vm: vm)).toList(),
    );
  }
}

// ── Feature tile → tap opens detail sheet ─────────────────────────────────────
class _FeatureTile extends StatelessWidget {
  final ClassFeature feature;
  final CharacterSheetViewModel vm;
  const _FeatureTile({required this.feature, required this.vm});

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FeatureDetailSheet(feature: feature, vm: vm),
    );
  }

  void _showUseModal(BuildContext context) {
    final remaining = vm.featureUsesRemaining(feature);
    if (remaining <= 0) return;
    final loc = AppStrings.of(context);
    int amount = 1;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(feature.name,
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.primary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.howManyUse,
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppTheme.primary),
                    onPressed: amount > 1 ? () => setS(() => amount--) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('$amount',
                        style: GoogleFonts.libreBaskerville(
                            color: AppTheme.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppTheme.primary),
                    onPressed:
                        amount < remaining ? () => setS(() => amount++) : null,
                  ),
                ],
              ),
              Text(loc.availableCount(remaining),
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
          actions: [
            TextButton(
              child: Text(loc.cancel,
                  style: GoogleFonts.lato(color: AppTheme.textSecondary)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary),
              child: Text(loc.use,
                  style: GoogleFonts.lato(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                vm.useFeatureN(feature, amount);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConsumable = vm.isConsumableFeature(feature);
    final isPool       = isConsumable && vm.isPoolResource(feature);
    final maxUses      = vm.featureMaxUses(feature);
    final remaining    = vm.featureUsesRemaining(feature);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _openSheet(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feature.name,
                      style: GoogleFonts.libreBaskerville(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                    Text(_tr(context, en: 'Level ${feature.level}', es: 'Nivel ${feature.level}', gl: 'Nivel ${feature.level}'),
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 10)),
                ],
              ),
            ),
            if (isConsumable) ...[
              const SizedBox(width: 8),
              if (isPool) ...[
                // Pool resource: counter + USE button
                Text(
                  '$remaining/$maxUses',
                  style: GoogleFonts.lato(
                      color: remaining == 0
                          ? AppTheme.textSecondary
                          : AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: remaining > 0 ? () => _showUseModal(context) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: remaining > 0
                          ? AppTheme.primary.withOpacity(0.15)
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: remaining > 0
                              ? AppTheme.primary.withOpacity(0.4)
                              : Colors.transparent),
                    ),
                    child: Text(AppStrings.of(context).use,
                        style: GoogleFonts.lato(
                            color: remaining > 0
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                  ),
                ),
              ] else if (maxUses <= 6) ...[
                // Circle tracker (small counts) — fills left→right
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(maxUses, (i) {
                    final isSpent = i < (maxUses - remaining);
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSpent ? AppTheme.primary : Colors.transparent,
                          border: Border.all(
                            color: isSpent
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            width: 1.5),
                        ),
                      ),
                    );
                  }),
                ),
              ] else ...[
                Text('$remaining/$maxUses',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ],
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 18),
          ]),
        ),
      ),
    );
  }
}

// ── Feature detail sheet ───────────────────────────────────────────────────────
class _FeatureDetailSheet extends StatelessWidget {
  final ClassFeature feature;
  final CharacterSheetViewModel vm;
  const _FeatureDetailSheet({required this.feature, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isConsumable = vm.isConsumableFeature(feature);
    final isPool       = isConsumable && vm.isPoolResource(feature);
    final maxUses      = vm.featureMaxUses(feature);
    final remaining    = vm.featureUsesRemaining(feature);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Title
          Text(feature.name,
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
            Text(_tr(context, en: 'Level ${feature.level}', es: 'Nivel ${feature.level}', gl: 'Nivel ${feature.level}'),
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 13)),
          // Usage tracker
          if (isConsumable) ...[
            const SizedBox(height: 16),
            if (isPool) ...[
              // Pool resource: large counter + use/restore buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$remaining',
                    style: GoogleFonts.libreBaskerville(
                        color: remaining == 0
                            ? AppTheme.textSecondary
                            : AppTheme.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' / $maxUses',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 16),
                  ),
                  const Spacer(),
                  if (remaining < maxUses)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppTheme.primary.withOpacity(0.5))),
                      icon: const Icon(Icons.refresh,
                          size: 14, color: AppTheme.primary),
                      label: Text(AppStrings.of(context).restore,
                          style: GoogleFonts.lato(
                              color: AppTheme.primary, fontSize: 12)),
                      onPressed: () => vm.restoreFeatureToFull(feature),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: remaining > 0
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant),
                  onPressed: remaining > 0
                      ? () {
                          final loc = AppStrings.of(context);
                          int amount = 1;
                          showDialog(
                            context: context,
                            builder: (_) => StatefulBuilder(
                              builder: (ctx, setS) => AlertDialog(
                                backgroundColor: AppTheme.surface,
                                title: Text('${AppStrings.of(context).use} ${feature.name}',
                                    style: GoogleFonts.libreBaskerville(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(loc.howManyUse,
                                        style: GoogleFonts.lato(
                                            color: AppTheme.textSecondary,
                                            fontSize: 13)),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: AppTheme.primary),
                                          onPressed: amount > 1
                                              ? () => setS(() => amount--)
                                              : null,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Text('$amount',
                                              style:
                                                  GoogleFonts.libreBaskerville(
                                                      color: AppTheme.primary,
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: AppTheme.primary),
                                          onPressed: amount < remaining
                                              ? () => setS(() => amount++)
                                              : null,
                                        ),
                                      ],
                                    ),
                                    Text(loc.availableCount(remaining),
                                        style: GoogleFonts.lato(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(loc.cancel,
                                        style: GoogleFonts.lato(
                                            color: AppTheme.textSecondary)),
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary),
                                    child: Text(loc.confirm,
                                        style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      vm.useFeatureN(feature, amount);
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    remaining > 0
                      ? AppStrings.of(context).use
                      : _tr(context, en: 'No uses left', es: 'Sin usos', gl: 'Sen usos'),
                    style: GoogleFonts.lato(
                        color: remaining > 0
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else ...[
              // Circle tracker (small counts) — fills left→right
              Row(children: [
                Text(_tr(context, en: 'Uses', es: 'Usos', gl: 'Usos'),
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4)),
                const SizedBox(width: 10),
                Text('$remaining / $maxUses',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ]),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(maxUses, (i) {
                  final isSpent = i < (maxUses - remaining);
                  return GestureDetector(
                    onTap: () => isSpent
                        ? vm.restoreFeature(feature)
                        : vm.useFeature(feature),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSpent ? AppTheme.primary : Colors.transparent,
                        border: Border.all(
                          color: isSpent
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          width: 1.5),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          if (feature.description.isNotEmpty)
            Text(feature.description,
                style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 13, height: 1.6))
          else
            Text(_tr(context, en: 'No description available.', es: 'Sin descripcion disponible.', gl: 'Sen descricion dispoñible.'),
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic)),
        ]),
      ),
    );
  }
}

// ── Loading row ───────────────────────────────────────────
class _LoadingRow extends StatelessWidget {
  const _LoadingRow();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.primary),
          ),
        ),
      );
}

// ── Standard Actions card (navigates to full-screen list) ─────────────────────

class _StandardActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _ActionListScreen(
              title: AppStrings.of(context).standardActions, actions: kStandardActions),
        )),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
          ),
          child: Row(children: [
            const Icon(Icons.list_alt_outlined,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Text(AppStrings.of(context).standardActions,
                style: GoogleFonts.libreBaskerville(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(_tr(context, en: '${kStandardActions.length} actions', es: '${kStandardActions.length} acciones', gl: '${kStandardActions.length} accions'),
                style:
                    GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 18),
          ]),
        ),
      );
}

// ── Spell Attack Table (no CAST button, no per-row slot tracker) ──────────────

// ── Weapon Attack Table ────────────────────────────────────────────────────────

class _WeaponAttackTable extends StatelessWidget {
  final List<InventoryItem> weapons;
  final PlayerCharacter character;
  const _WeaponAttackTable({required this.weapons, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            Expanded(
              flex: 3,
              child: Text(_tr(context, en: 'WEAPON', es: 'ARMA', gl: 'ARMA'),
                style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            SizedBox(
              width: _kHitDcW,
              child: Text(_tr(context, en: 'TO HIT', es: 'ATAQUE', gl: 'ATAQUE'),
                  textAlign: TextAlign.center,
                style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: _kColGap),
            SizedBox(
              width: _kDmgW,
              child: Text(_tr(context, en: 'DAMAGE', es: 'DANO', gl: 'DANO'),
                  textAlign: TextAlign.center,
                style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
          ]),
        ),
        ...weapons.map((w) => _WeaponRow(weapon: w, character: character)),
      ]),
    );
  }
}

class _WeaponRow extends StatelessWidget {
  final InventoryItem weapon;
  final PlayerCharacter character;
  const _WeaponRow({required this.weapon, required this.character});

  bool get _isRanged =>
      weapon.weaponRange?.toLowerCase() == 'ranged';

  bool get _isFinesse =>
      weapon.weaponProperties.any((p) => p.toLowerCase().contains('finesse'));

  int get _abilityMod {
    final str = character.modifier('STR');
    final dex = character.modifier('DEX');
    if (_isRanged) return dex;
    if (_isFinesse) return str > dex ? str : dex;
    return str;
  }

  int get _attackBonus => character.proficiencyBonus + _abilityMod;

  String get _attackText {
    final b = _attackBonus;
    return b >= 0 ? '+$b' : '$b';
  }

  String get _damageText {
    final dice = weapon.damageDice ?? '';
    if (dice.isEmpty) return '—';
    final mod = _abilityMod;
    if (mod > 0) return '$dice+$mod';
    if (mod < 0) return '$dice$mod';
    return dice;
  }

  String get _rangeLabel {
    final range = weapon.weaponRange;
    if (range == null || range.isEmpty) return 'Melee';
    return range[0].toUpperCase() + range.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Color(0xFF2A2A4A), width: 0.5))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          flex: 3,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weapon.name,
                    style: GoogleFonts.lato(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(_rangeLabel,
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 10)),
              ]),
        ),
        SizedBox(
          width: _kHitDcW,
          child: Text(_attackText,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  color: const Color(0xFFC8A45A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: _kColGap),
        SizedBox(
          width: _kDmgW,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_damageText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: const Color(0xFFCB7A48),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              if (weapon.damageType != null && weapon.damageType!.isNotEmpty)
                Text(localizeDamageType(context, weapon.damageType!),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Spell Attack Table ────────────────────────────────────────────────────────

class _SpellAttackTable extends StatelessWidget {
  final List<CharacterSpell> spells;
  final CharacterSheetViewModel vm;
  const _SpellAttackTable({required this.spells, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            Expanded(
              flex: 3,
              child: Text(_tr(context, en: 'NAME', es: 'NOMBRE', gl: 'NOME'),
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            SizedBox(
              width: _kHitDcW,
              child: const Text('HIT / DC',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: _kColGap),
            SizedBox(
              width: _kDmgW,
              child: Text(_tr(context, en: 'DAMAGE', es: 'DANO', gl: 'DANO'),
                  textAlign: TextAlign.center,
                style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
          ]),
        ),
        ...spells.map((s) => _SpellRow(spell: s, vm: vm)),
      ]),
    );
  }
}

// ── Spell row (tap → detail sheet) ────────────────────────────────────────────

class _SpellRow extends StatelessWidget {
  final CharacterSpell spell;
  final CharacterSheetViewModel vm;
  const _SpellRow({required this.spell, required this.vm});

  String _hitDcText() {
    if (spell.attackType != null && spell.attackType!.isNotEmpty)
      return vm.signedInt(vm.character?.spellAttackBonus ?? 0);
    return '—';
  }

  Widget _buildHitDcCell(BuildContext context) {
    // Spell attack: show bonus as single value
    if (spell.attackType != null && spell.attackType!.isNotEmpty) {
      return Text(_hitDcText(),
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              color: const Color(0xFFC8A45A),
              fontSize: 12,
              fontWeight: FontWeight.w600));
    }
    // Save DC: stack ability name over DC value
    if (spell.dcType != null && spell.dcType!.isNotEmpty) {
      final dc = vm.character?.spellSaveDC ?? 0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Text(localizeAbilityCode(context, spell.dcType!),
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  color: const Color(0xFFC8A45A),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3)),
          Text('DC $dc',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  color: const Color(0xFFC8A45A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      );
    }
    return Text('—',
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
            color: const Color(0xFFC8A45A),
            fontSize: 12,
            fontWeight: FontWeight.w600));
  }

  Widget _buildDamageCell(BuildContext context) {
    final b = spell.damageBase;
    final t = spell.damageType;
    if (b == null || b.isEmpty) {
      return Text('—',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              color: const Color(0xFFCB7A48),
              fontSize: 12,
              fontWeight: FontWeight.w600));
    }
    if (t == null || t.isEmpty) {
      return Text(b,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
              color: const Color(0xFFCB7A48),
              fontSize: 12,
              fontWeight: FontWeight.w600));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(b,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
                color: const Color(0xFFCB7A48),
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        Text(localizeDamageType(context, t).toUpperCase(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
                color: const Color(0xFFCB7A48),
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _range() {
    final r = spell.range;
    if (r == null) return '—';
    return r.replaceAll(' feet', 'ft').replaceAll(' foot', 'ft');
  }

  @override
  Widget build(BuildContext context) {
    final hasSlots = vm.availableSlots(spell.level) > 0;
    final canCast  = spell.isCantrip || hasSlots;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _SpellDetailSheet(spell: spell, vm: vm),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color(0xFF2A2A4A), width: 0.5))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            flex: 3,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spell.name,
                      style: GoogleFonts.lato(
                          color: canCast
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  Text(_range(),
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 10)),
                ]),
          ),
          SizedBox(
            width: _kHitDcW,
            child: _buildHitDcCell(context),
          ),
          const SizedBox(width: _kColGap),
          SizedBox(
            width: _kDmgW,
            child: _buildDamageCell(context),
          ),
        ]),
      ),
    );
  }
}

// ── Spell Detail Sheet ─────────────────────────────────────────────────────────

class _SpellDetailSheet extends StatelessWidget {
  final CharacterSpell spell;
  final CharacterSheetViewModel vm;
  const _SpellDetailSheet({required this.spell, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final loc = AppStrings.of(context);
    final isCantrip = spell.isCantrip;
    final level     = spell.level;
    final maxSl     = vm.maxSlots(level);
    final usedSl    = vm.usedSlots(level);
    final hasSlots  = vm.availableSlots(level) > 0;
    final canCast   = isCantrip || hasSlots;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Title row + CAST button
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spell.name,
                        style: GoogleFonts.libreBaskerville(
                            color: AppTheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${spell.levelLabel}'
                      '${spell.school != null ? ' · ${localizeSpellSchool(context, spell.school!)}' : ''}',
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ]),
            ),
            if (!isCantrip) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                height: 38,
                child: OutlinedButton(
                  onPressed: canCast
                      ? () async {
                          final ok = await vm.castSpell(level);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(_tr(context, en: 'No slots for level $level', es: 'Sin espacios de nivel $level', gl: 'Sen ocos de nivel $level')),
                              backgroundColor: AppTheme.accent,
                              duration: const Duration(seconds: 2),
                            ));
                          }
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    foregroundColor: AppTheme.primary,
                    disabledForegroundColor: AppTheme.divider,
                    side: BorderSide(
                        color: canCast ? AppTheme.primary : AppTheme.divider),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(loc.castButton,
                        style: GoogleFonts.libreBaskerville(
                            fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ]),

          // Interactive slot tracker
          if (!isCantrip && maxSl > 0) ...[
            const SizedBox(height: 12),
            Row(children: [
              Text(_tr(context, en: 'Slots Lv.$level', es: 'Espacios Nv.$level', gl: 'Ocos Nv.$level'),
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4)),
              const SizedBox(width: 10),
              ...List.generate(maxSl, (i) {
                final isFull = i < usedSl;
                return GestureDetector(
                  onTap: () async {
                    if (isFull) {
                      await vm.restoreSpellSlot(level);
                    } else {
                      await vm.castSpell(level);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      isFull
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isFull ? AppTheme.accent : AppTheme.textSecondary,
                      size: 20),
                  ),
                );
              }),
            ]),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          if (spell.castingTime != null)
            _DetailRow(_spellDetailLabel(context, 'castingTime'), spell.castingTime!),
          if (spell.range != null) _DetailRow(_spellDetailLabel(context, 'range'), spell.range!),
          if (spell.duration != null) _DetailRow(_spellDetailLabel(context, 'duration'), spell.duration!),
          if (spell.components != null)
            _DetailRow(_spellDetailLabel(context, 'components'), spell.components!),
          if (!isCantrip)
            _DetailRow(
              _spellDetailLabel(context, 'status'),
              spell.prepared
                  ? _spellDetailLabel(context, 'prepared')
                  : _spellDetailLabel(context, 'learned'),
            ),
          if (spell.description != null && spell.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_spellDetailLabel(context, 'description'),
                style: GoogleFonts.libreBaskerville(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(spell.description!,
                style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 13, height: 1.6)),
          ],
        ]),
      ),
    );
  }
}

// ── Static section (inline expandable list: bonus actions / reactions) ─────────

class _StaticSection extends StatelessWidget {
  final List<_ActionEntry> actions;
  const _StaticSection({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: actions
          .map((a) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceVariant),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    title: Text(_actionNameLocalized(context, a.name),
                        style: GoogleFonts.libreBaskerville(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    iconColor: AppTheme.textSecondary,
                    collapsedIconColor: AppTheme.textSecondary,
                    children: [
                      Text(a.desc,
                          style: GoogleFonts.lato(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.5)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ── Full-screen action list (Standard Actions) ─────────────────────────────────

class _ActionListScreen extends StatelessWidget {
  final String title;
  final List<_ActionEntry> actions;
  const _ActionListScreen(
      {required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(title,
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: actions.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppTheme.divider),
        itemBuilder: (_, i) {
          final a = actions[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(_actionNameLocalized(context, a.name),
                          style: GoogleFonts.libreBaskerville(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_actionDescLocalized(context, a),
                          style: GoogleFonts.lato(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.5)),
                    ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}

// ── Static data ────────────────────────────────────────────────────────────────

class _ActionEntry {
  final String name;
  final String desc;
  const _ActionEntry({required this.name, required this.desc});
}

const kStandardActions = [
  _ActionEntry(name: 'Attack',
      desc: 'Make one weapon attack. Extra attacks from class features may allow more.'),
  _ActionEntry(name: 'Dash',
      desc: 'You gain extra movement equal to your speed for the current turn.'),
  _ActionEntry(name: 'Disengage',
      desc: "Your movement doesn't provoke opportunity attacks for the rest of the turn."),
  _ActionEntry(name: 'Dodge',
      desc: 'Until the start of your next turn, attacks against you have disadvantage and you have advantage on Dex saves.'),
  _ActionEntry(name: 'Grapple',
      desc: 'Special melee attack. Contest: your Athletics vs. their Athletics or Acrobatics.'),
  _ActionEntry(name: 'Help',
      desc: 'Give an ally advantage on the next ability check or attack roll against a creature within 5 ft of you.'),
  _ActionEntry(name: 'Hide',
      desc: 'Make a Stealth check. If successful, you are hidden until you attack or are detected.'),
  _ActionEntry(name: 'Improvise',
      desc: 'Do something not covered by other actions. The DM decides the outcome.'),
  _ActionEntry(name: 'Influence',
      desc: "Make a Persuasion, Deception, or Intimidation check to sway a creature's attitude."),
  _ActionEntry(name: 'Magic',
      desc: 'Cast a spell with a casting time of 1 action, or use a magic item.'),
  _ActionEntry(name: 'Ready',
      desc: 'Prepare a reaction for a specific trigger. Declare the action and the trigger.'),
  _ActionEntry(name: 'Search',
      desc: 'Make a Perception or Investigation check to find something non-obvious.'),
  _ActionEntry(name: 'Shove',
      desc: 'Special melee attack to push a creature 5 ft away or knock it prone.'),
  _ActionEntry(name: 'Study',
      desc: 'Make an Intelligence check to recall lore or analyze something.'),
  _ActionEntry(name: 'Utilize',
      desc: 'Use an object or activate a device (e.g., a trap, lock, or special item).'),
];

// Only universal bonus actions available to ALL characters by default.
// Class-specific features (Second Wind, Cunning Action, Wild Shape, etc.)
// are loaded dynamically in _ClassFeaturesSection from the API.
const kBonusActions = [
  _ActionEntry(name: 'Off-Hand Attack',
      desc: "When you take the Attack action with a light melee weapon, you can use a bonus action to attack with a different light melee weapon held in the other hand. No ability modifier to damage unless negative."),
];

// Only universal reactions available to ALL characters by default.
// Class-specific reactions (Uncanny Dodge, etc.) appear via _ClassFeaturesSection.
const kReactions = [
  _ActionEntry(name: 'Opportunity Attack',
      desc: 'When a creature you can see moves out of your reach, make one melee attack against it as a reaction.'),
  _ActionEntry(name: 'Readied Action',
      desc: 'Take the action you prepared with the Ready action when the trigger you declared occurs.'),
];

// ── Section title ──────────────────────────────────────────────────────────────


//Shared WIDGETS

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(title,
            style: GoogleFonts.libreBaskerville(
                color: AppTheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
      ]);
}

// ── Death Saves ────────────────────────────────────────────────────────────────

class _DeathSavesRow extends StatelessWidget {
  final int successes;
  final int failures;
  final VoidCallback onSuccessTap;
  final VoidCallback onFailureTap;
  final VoidCallback onReset;
  const _DeathSavesRow({
    required this.successes,
    required this.failures,
    required this.onSuccessTap,
    required this.onFailureTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // ── Success half (fully tappable) ──────────────────────────
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onSuccessTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppStrings.of(context).successes,
                                style: GoogleFonts.lato(
                                    color: AppTheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  3, (i) => _SaveDot(filled: i < successes, color: AppTheme.primary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Divider ────────────────────────────────────────────────
                Container(width: 1, color: AppTheme.divider),
                // ── Failure half (fully tappable) ──────────────────────────
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onFailureTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppStrings.of(context).failures,
                                style: GoogleFonts.lato(
                                    color: AppTheme.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  3, (i) => _SaveDot(filled: i < failures, color: AppTheme.accent)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            // ── Divider ──────────────────────────────────────────────────
            Container(height: 1, color: AppTheme.divider),
            // ── RESET button ─────────────────────────────────────────────
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onReset,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  alignment: Alignment.center,
                  child: Text(
                    AppStrings.of(context).resetLabel,
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveDot extends StatelessWidget {
  final bool filled;
  final Color color;
  const _SaveDot({required this.filled, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
        ),
      );
}

// ── Detail Row ─────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 110,
            child: Text('$label:',
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 12)),
          ),
        ]),
      );
}
