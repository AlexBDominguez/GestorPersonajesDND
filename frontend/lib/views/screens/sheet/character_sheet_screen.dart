import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_abilities.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_skills.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CharacterSheetScreen extends StatelessWidget {
  final int characterId;
  const CharacterSheetScreen({super.key, required this.characterId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterSheetViewModel(characterId: characterId)..load(),
      child: const _SheetBody(),
    );
  }
}

class _SheetBody extends StatefulWidget{
  const _SheetBody();
  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody> with SingleTickerProviderStateMixin{
    late final TabController _tabController;
    
    static const _tabs = [
      Tab(text: 'Abilities'),
      Tab(text: 'Skills'),
      Tab(text: 'Combat'),
      Tab(text: 'Inventory'),
      Tab(text: 'Spells'),
    ];

    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: _tabs.length, vsync: this);
    }

    @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }    

    @override
    Widget build(BuildContext context) {
    final vm = context.watch<CharacterSheetViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (vm.error != null || vm.character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Character Sheet')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: AppTheme.accent, size: 48),
            const SizedBox(height: 12),
            Text(vm.error ?? 'Character not found',
                style: GoogleFonts.lato(color: AppTheme.accent)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.load,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 44)),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );
    }

    final c = vm.character!;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Header fijo
          _SheetHeader(character: c, vm: vm),

          //Tab bar
          Container(
            color: AppTheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 12),
              indicatorColor: AppTheme.primary, indicatorWeight: 2,
              tabs: _tabs,              
            ),
          ),

          const Divider(height: 1),

          //Tab content (swipeable)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TabAbilities(character: c),
                TabSkills(character: c, vm: vm),
                _ComingSoonTab(label: 'Combat'),
                _ComingSoonTab(label: 'Inventory'),
                _ComingSoonTab(label: 'Spells'),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// Header
class _SheetHeader extends StatelessWidget{
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const _SheetHeader({required this.character, required this.vm});

  @override
  Widget build(BuildContext context){
    final c = character;
    final initLabel = vm.signedInt(c.initiativeModifier);

  return Container(
    color: AppTheme.surface,
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center, children: [
        //Izquierda: AC + Initiative
        SizedBox(
          width: 72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, children: [
              _StatPill(label: 'AC', value: '${c.armorClass}'),
              const SizedBox(height: 6),
              _StatPill(label: 'Init', value: initLabel),
            ]),
        ),

        //Centro: nombre + subtítulo
        Expanded(
          child: Column(children: [
            // Placeholder avatar
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceVariant,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: const Icon(Icons.person,
                  color: AppTheme.primary, size: 28),
            ),
            const SizedBox(height: 4),
            Text(
              c.name,
              style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _subtitle(c),
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ]),
        ),

        //Derecha: HP pulsable
        SizedBox(
          width: 72,
          child: GestureDetector(
            onTap: () => _showManageHpModal(context),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _hpColor(c).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _hpColor(c), width: 1.5),
                ),
                child: Column(children: [
                  Text(
                    '${c.currentHp}/${c.maxHp}',
                    style: GoogleFonts.cinzel(
                      color: _hpColor(c),
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    ),
                    if(c.temporaryHp > 0)
                      Text('+${c.temporaryHp} tmp',
                        style: GoogleFonts.lato(
                          color: Colors.lightBlueAccent,
                          fontSize: 9)),
                ]),
                ),
              const SizedBox(height: 2),
              Text('HP',
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 10)),
                const Icon(Icons.touch_app, color: AppTheme.textSecondary, size: 12),
            ]),
          ),
        ),
      ]),
    );
  }
  String _subtitle(PlayerCharacter c) {
    final parts = [
      if (c.raceName != null) c.raceName!,
      if (c.dndClassName != null) c.dndClassName!,
      'Lvl ${c.level}',
    ];
    return parts.join(' · ');
  }

  Color _hpColor(PlayerCharacter c) {
    if(c.currentHp <= 0) return AppTheme.accent;
    final pct = c.hpPercent;
    if (pct < 0.25) return AppTheme.accent;
    if (pct < 0.5) return Colors.orangeAccent;
    return AppTheme.primary;
  }

  void _showManageHpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _ManageHpSheet(),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context){
    return Column(children: [
      Container(
        width: 52, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.primary, width: 1),
      ),
      child: Center(
        child: Text(value,
          style: GoogleFonts.cinzel(
            color: AppTheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold)),
      ),
    ),
    const SizedBox(height: 2),
    Text(label,
      style: GoogleFonts.lato(
        color: AppTheme.textSecondary, fontSize: 9,
        letterSpacing: 1)), 
    ]);
  }
}

// Manage HP Modal
class _ManageHpSheet extends StatefulWidget {
  const _ManageHpSheet();
  @override
  State<_ManageHpSheet> createState() => _ManageHpSheetState();
}

class _ManageHpSheetState extends State<_ManageHpSheet>{
  final _damageCtrl = TextEditingController();
  final _healCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();

  @override
  void dispose(){
    _damageCtrl.dispose();
    _healCtrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final vm = context.watch<CharacterSheetViewModel>();
    final c = vm.character!;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column (mainAxisSize: MainAxisSize.min, children: [
        //Handle
        Container(width: 40, height: 4,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),

        Text('Manage HP',
          style: GoogleFonts.cinzel(
            color: AppTheme.primary,
            fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          '${c.currentHp}/${c.maxHp} HP'
          '${c.temporaryHp > 0 ? ' +${c.temporaryHp} temp' : ''}',
          style: GoogleFonts.lato(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          //HP bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: c.hpPercent,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(
                c.hpPercent < 0.25
                ? AppTheme.accent
                : c.hpPercent < 0.5
                  ? Colors.orange
                  : AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Inputs en fila
          Row(children: [
            Expanded(child: _HpField(
              controller: _damageCtrl, label: 'Damage',
                icon: Icons.remove_circle_outline, color: AppTheme.accent)),
            const SizedBox(width: 10),
            Expanded(child: _HpField(
              controller: _healCtrl, label: 'Heal',
                icon: Icons.add_circle_outline, color: Colors.green)),
            const SizedBox(width: 10),
            Expanded(child: _HpField(
              controller: _tempCtrl, label: 'Temp HP',
                icon: Icons.shield_outlined, color: Colors.lightBlueAccent)),
          ]),
          const SizedBox(height: 20),

          if (vm.hpError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              vm.hpError!,
              style: GoogleFonts.lato(color: AppTheme.accent, fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: vm.isSavingHp
            ? null
            : () async {
              final dmg = int.tryParse(_damageCtrl.text) ?? 0;
              final heal = int.tryParse(_healCtrl.text) ?? 0;
              final temp = int.tryParse(_tempCtrl.text) ?? 0;
              await vm.applyHpChange(
                damage: dmg, heal: heal, tempHp: temp);
              if (vm.hpError == null && context.mounted) {
                Navigator.pop(context);
              }
            },
          child: vm.isSavingHp
            ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.background))
            : const Text('Apply'),
              ),
      ]),
    );
  }
}

class _HpField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  const _HpField({required this.controller, required this.label,
    required this.icon, required this.color});

  @override
  Widget build (BuildContext context){
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: GoogleFonts.cinzel(color: color, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: color, fontSize: 11),
        prefixIcon: Icon(icon, color: color, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color.withOpacity(0.4)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      );    
  }
}

// Placeholder Tabs
class _ComingSoonTab extends StatelessWidget {
  final String label;
  const _ComingSoonTab({required this.label});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.construction,
      color: AppTheme.surfaceVariant, size: 48),
      const SizedBox(height: 12),
      Text('$label - Coming soon',
      style: GoogleFonts.cinzel(
        color: AppTheme.textSecondary, fontSize: 14
      )),
    ]),
  );
}