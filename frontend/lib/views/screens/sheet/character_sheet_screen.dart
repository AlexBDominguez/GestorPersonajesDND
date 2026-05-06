import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/pending_tasks_screen.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_abilities.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_combat.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_features.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_inventory.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_skills.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_spells.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_info.dart';

// Asegúrate de que esta ruta sea correcta
// import 'package:gestor_personajes_dnd/views/screens/sheet/pending_tasks_screen.dart'; 

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

class _SheetBody extends StatefulWidget {
  const _SheetBody();
  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showSpells = false;
  // Direct reference to the ViewModel so we can add/remove a listener.
  CharacterSheetViewModel? _vmRef;

  static const _baseTabs = [
    Tab(text: 'Abilities'),
    Tab(text: 'Skills'),
    Tab(text: 'Combat'),
    Tab(text: 'Features'),
    Tab(text: 'Inventory'),
    Tab(text: 'Info'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _baseTabs.length, vsync: this);
  }

  /// Called whenever an InheritedWidget above us changes — which includes the
  /// first time the Provider is available.  We attach a **direct** listener to
  /// the ViewModel here so that we can synchronously update `_tabController`
  /// via `setState` BEFORE `build()` runs with the new data.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<CharacterSheetViewModel>();
    if (_vmRef != vm) {
      _vmRef?.removeListener(_onVmChanged);
      _vmRef = vm;
      vm.addListener(_onVmChanged);
    }
  }

  @override
  void dispose() {
    _vmRef?.removeListener(_onVmChanged);
    _tabController.dispose();
    super.dispose();
  }

  /// Fired synchronously by [CharacterSheetViewModel.notifyListeners].
  /// Updates the tab controller BEFORE [build] is called, so tabs/views and
  /// the controller are always in sync within the same frame.
  void _onVmChanged() {
    if (!mounted) return;
    final character = _vmRef?.character;
    if (character == null) return;
    final showSpells =
        character.spellSlots.isNotEmpty || character.characterSpells.isNotEmpty;
    if (_showSpells == showSpells) return;
    // setState here is safe: we are inside a ChangeNotifier listener, which
    // fires outside of any build() call.
    setState(() {
      final newLength = showSpells ? _baseTabs.length + 1 : _baseTabs.length;
      final clampedIndex = _tabController.index.clamp(0, newLength - 1);
      _tabController.dispose();
      _showSpells = showSpells;
      _tabController = TabController(
          length: newLength, vsync: this, initialIndex: clampedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterSheetViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
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
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );
    }

    final c = vm.character!;

    // _showSpells is kept in sync with _tabController by _onVmChanged.
    // Both are always consistent here — no postFrameCallback needed.
    final tabs = [
      ..._baseTabs.sublist(0, 3), // Abilities, Skills, Combat
      if (_showSpells) const Tab(text: 'Spells'),
      ..._baseTabs.sublist(3),    // Features, Inventory, Info
    ];
    final views = <Widget>[
      TabAbilities(character: c, vm: vm),
      TabSkills(character: c, vm: vm),
      TabCombat(character: c, vm: vm),
      if (_showSpells) TabSpells(character: c, vm: vm),
      TabFeatures(character: c, vm: vm),
      TabInventory(character: c, vm: vm),
      TabInfo(character: c),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Barra de navegación (Ahora recibe vm)
          _NavBar(character: c, vm: vm),
          const Divider(height: 1, color: AppTheme.surfaceVariant),
          
          // Stats header
          _SheetHeader(character: c, vm: vm),

          // Death saves banner — visible when HP = 0 or dying
          if (c.currentHp <= 0 || c.isDying)
            _DyingBanner(character: c),

          // Tab bar
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
              indicatorColor: AppTheme.primary,
              indicatorWeight: 2,
              tabs: tabs,
            ),
          ),

          const Divider(height: 1),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: views,
            ),
          ),
        ]),
      ),
    );
  }
}

// Barra de navegación actualizada
class _NavBar extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const _NavBar({required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(4, 6, 10, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppTheme.primary, size: 20),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    character.name,
                    style: GoogleFonts.cinzel(
                        color: AppTheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(_subtitle(),
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          
          // Botón condicional de Tareas Pendientes
          if (vm.hasPendingTasks)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PendingTasksScreen(vm: vm),
                ),
              ),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.assignment_late_outlined,
                      color: AppTheme.primary),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: '${vm.pendingTasks.length} pending choice(s)',
            ),

          const SizedBox(width: 10),

          // Rest buttons (replace avatar)
          _RestButton(
            icon: Icons.nightlight_round,
            label: 'Long',
            color: AppTheme.primary,
            onTap: () => _showLongRestModal(context, vm),
          ),
          const SizedBox(width: 6),
          _RestButton(
            icon: Icons.coffee_outlined,
            label: 'Short',
            color: const Color(0xFF7B9ECC),
            onTap: () => _showShortRestModal(context, vm, character),
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    final parts = [
      if (character.raceName != null) character.raceName!,
      if (character.dndClassName != null) character.dndClassName!,
      'Lvl ${character.level}',
    ];
    return parts.join(' · ');
  }

  void _showLongRestModal(BuildContext context, CharacterSheetViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => _LongRestModal(vm: vm),
    );
  }

  void _showShortRestModal(BuildContext context, CharacterSheetViewModel vm, PlayerCharacter c) {
    showDialog(
      context: context,
      builder: (_) => _ShortRestModal(vm: vm, character: c),
    );
  }
}

// ── Dying Banner ──────────────────────────────────────────────────────────────

class _DyingBanner extends StatelessWidget {
  final PlayerCharacter character;
  const _DyingBanner({required this.character});

  @override
  Widget build(BuildContext context) {
    final c = character;
    final successes = c.deathSaveSuccesses;
    final failures  = c.deathSaveFailures;
    final isStable  = successes >= 3;

    return Container(
      width: double.infinity,
      color: isStable
          ? AppTheme.primary.withOpacity(0.12)
          : AppTheme.accent.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Icon(
          isStable ? Icons.favorite : Icons.warning_amber_rounded,
          color: isStable ? AppTheme.primary : AppTheme.accent,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isStable ? 'STABLE' : 'DYING — Death Saves',
            style: GoogleFonts.cinzel(
              color: isStable ? AppTheme.primary : AppTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Successes
        Row(children: [
          Text('✓',
              style: GoogleFonts.lato(
                  color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 3),
          ...List.generate(3, (i) => Container(
            margin: const EdgeInsets.only(right: 3),
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < successes
                  ? AppTheme.primary
                  : AppTheme.surfaceVariant,
              border: Border.all(
                color: AppTheme.primary,
                width: 1.5,
              ),
            ),
          )),
        ]),
        const SizedBox(width: 12),
        // Failures
        Row(children: [
          Text('✗',
              style: GoogleFonts.lato(
                  color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 3),
          ...List.generate(3, (i) => Container(
            margin: const EdgeInsets.only(right: 3),
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < failures
                  ? AppTheme.accent
                  : AppTheme.surfaceVariant,
              border: Border.all(
                color: AppTheme.accent,
                width: 1.5,
              ),
            ),
          )),
        ]),
      ]),
    );
  }
}

// Stats header (AC, Init, Speed, Prof, HP)
class _SheetHeader extends StatelessWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const _SheetHeader({required this.character, required this.vm});

  @override
  Widget build(BuildContext context) {
    final c = character;
    final initLabel = vm.signedInt(c.initiativeModifier);
    final profLabel = vm.signedInt(c.proficiencyBonus);

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ShieldAC(ac: c.armorClass),
          _StatPill(label: 'Initiative', value: initLabel),
          _StatPill(label: 'Speed', value: '${c.currentSpeed}'),
          _StatPill(label: 'Proficiency', value: profLabel),
          GestureDetector(
            onTap: () => _showManageHpModal(context),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _hpColor(c).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _hpColor(c), width: 1.5),
                ),
                child: Column(children: [
                  Text('${c.currentHp}/${c.maxHp}',
                      style: GoogleFonts.cinzel(
                          color: _hpColor(c),
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  if (c.temporaryHp > 0)
                    Text('+${c.temporaryHp} tmp',
                        style: GoogleFonts.lato(
                            color: Colors.lightBlueAccent, fontSize: 9)),
                ]),
              ),
              const SizedBox(height: 2),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('HP',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                        letterSpacing: 1)),
                const SizedBox(width: 2),
                const Icon(Icons.touch_app,
                    color: AppTheme.textSecondary, size: 11),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Color _hpColor(PlayerCharacter c) {
    if (c.currentHp <= 0) return AppTheme.accent;
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

class _ShieldAC extends StatelessWidget {
  final int ac;
  const _ShieldAC({required this.ac});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 42,
        height: 50,
        child: CustomPaint(
          painter: _ShieldPainter(),
          child: Align(
            alignment: const Alignment(0, -0.1),
            child: Text('$ac',
                style: GoogleFonts.cinzel(
                    color: AppTheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      const SizedBox(height: 2),
      Text('AC',
          style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 9, letterSpacing: 1)),
    ]);
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.08, 0)
      ..lineTo(w * 0.92, 0)
      ..quadraticBezierTo(w, 0, w, h * 0.1)
      ..lineTo(w, h * 0.58)
      ..quadraticBezierTo(w * 0.75, h * 0.88, w * 0.5, h)
      ..quadraticBezierTo(w * 0.25, h * 0.88, 0, h * 0.58)
      ..lineTo(0, h * 0.1)
      ..quadraticBezierTo(0, 0, w * 0.08, 0)
      ..close();
    canvas.drawPath(
        path,
        Paint()
          ..color = AppTheme.surfaceVariant
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = AppTheme.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) => false;
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 52,
        height: 36,
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
              color: AppTheme.textSecondary, fontSize: 9, letterSpacing: 1)),
    ]);
  }
}

class _ManageHpSheet extends StatefulWidget {
  const _ManageHpSheet();
  @override
  State<_ManageHpSheet> createState() => _ManageHpSheetState();
}

class _ManageHpSheetState extends State<_ManageHpSheet> {
  final _damageCtrl = TextEditingController();
  final _healCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();

  @override
  void dispose() {
    _damageCtrl.dispose();
    _healCtrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterSheetViewModel>();
    final c = vm.character!;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text('Manage HP',
            style: GoogleFonts.cinzel(
                color: AppTheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          '${c.currentHp}/${c.maxHp} HP'
          '${c.temporaryHp > 0 ? ' +${c.temporaryHp} temp' : ''}',
          style: GoogleFonts.lato(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),
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
        Row(children: [
          Expanded(
              child: _HpField(
                  controller: _damageCtrl,
                  label: 'Damage',
                  icon: Icons.remove_circle_outline,
                  color: AppTheme.accent)),
          const SizedBox(width: 10),
          Expanded(
              child: _HpField(
                  controller: _healCtrl,
                  label: 'Heal',
                  icon: Icons.add_circle_outline,
                  color: Colors.green)),
          const SizedBox(width: 10),
          Expanded(
              child: _HpField(
                  controller: _tempCtrl,
                  label: 'Temp HP',
                  icon: Icons.shield_outlined,
                  color: Colors.lightBlueAccent)),
        ]),
        const SizedBox(height: 20),
        if (vm.hpError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(vm.hpError!,
                style: GoogleFonts.lato(color: AppTheme.accent, fontSize: 12)),
          ),
        ElevatedButton(
          onPressed: vm.isSavingHp
              ? null
              : () async {
                  final dmg = int.tryParse(_damageCtrl.text) ?? 0;
                  final heal = int.tryParse(_healCtrl.text) ?? 0;
                  final temp = int.tryParse(_tempCtrl.text) ?? 0;
                  await vm.applyHpChange(damage: dmg, heal: heal, tempHp: temp);
                  if (vm.hpError == null && context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: vm.isSavingHp
              ? const SizedBox(
                  height: 20,
                  width: 20,
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
  const _HpField(
      {required this.controller,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
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

// ── Rest button (compact icon + label) ────────────────────────────────────────

class _RestButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RestButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.lato(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

// ── Long Rest Modal ────────────────────────────────────────────────────────────

class _LongRestModal extends StatefulWidget {
  final CharacterSheetViewModel vm;
  const _LongRestModal({required this.vm});

  @override
  State<_LongRestModal> createState() => _LongRestModalState();
}

class _LongRestModalState extends State<_LongRestModal> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      await widget.vm.longRest();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Long rest completed! HP and all spell slots restored.',
              style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: AppTheme.primary.withOpacity(0.9),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''),
              style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: AppTheme.accent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        const Icon(Icons.nightlight_round, color: AppTheme.primary, size: 22),
        const SizedBox(width: 8),
        Text('Long Rest', style: GoogleFonts.cinzel(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Taking a long rest will restore:', style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        _RestEffect(icon: Icons.favorite, text: 'HP to maximum'),
        _RestEffect(icon: Icons.auto_fix_high, text: 'All spell slots'),
        _RestEffect(icon: Icons.sports_esports, text: 'Class resources (Long Rest)'),
        _RestEffect(icon: Icons.casino, text: 'Hit dice (at least half your level)'),
        _RestEffect(icon: Icons.healing, text: 'Death saves reset'),
      ]),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.lato(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _confirm,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Rest'),
        ),
      ],
    );
  }
}

// ── Short Rest Modal ───────────────────────────────────────────────────────────

class _ShortRestModal extends StatefulWidget {
  final CharacterSheetViewModel vm;
  final PlayerCharacter character;
  const _ShortRestModal({required this.vm, required this.character});

  @override
  State<_ShortRestModal> createState() => _ShortRestModalState();
}

class _ShortRestModalState extends State<_ShortRestModal> {
  int _diceToSpend = 0;
  bool _loading = false;
  int _rolledTotal = 0;
  bool _hasRolled = false;

  int get _hitDie {
    final name = widget.character.dndClassName?.toLowerCase() ?? '';
    if (name.contains('barbarian')) return 12;
    if (name.contains('fighter') || name.contains('paladin') || name.contains('ranger')) return 10;
    if (name.contains('monk') || name.contains('druid') || name.contains('cleric') ||
        name.contains('warlock') || name.contains('rogue')) return 8;
    return 6; // Bard, Sorcerer, Wizard
  }

  int get _available => widget.character.availableHitDice;

  void _roll() {
    final rng = Random();
    int total = 0;
    for (int i = 0; i < _diceToSpend; i++) {
      total += rng.nextInt(_hitDie) + 1;
    }
    setState(() { _rolledTotal = total; _hasRolled = true; });
  }

  Future<void> _confirm() async {
    if (_diceToSpend == 0) {
      // Short rest with no dice spent (just class resources)
      _rolledTotal = 0;
    }
    setState(() => _loading = true);
    try {
      await widget.vm.shortRest(hitDiceToSpend: _diceToSpend, hitDiceRoll: _rolledTotal);
      if (mounted) {
        Navigator.pop(context);
        final healMsg = _rolledTotal > 0 ? ' Healed $_rolledTotal HP.' : '';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Short rest completed.$healMsg',
              style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: const Color(0xFF7B9ECC).withOpacity(0.9),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''),
              style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: AppTheme.accent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        const Icon(Icons.coffee_outlined, color: Color(0xFF7B9ECC), size: 22),
        const SizedBox(width: 8),
        Text('Short Rest', style: GoogleFonts.cinzel(color: const Color(0xFF7B9ECC), fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('You have $_available / ${widget.character.level} hit dice (d$_hitDie).',
            style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.textSecondary),
            onPressed: _diceToSpend > 0 ? () => setState(() { _diceToSpend--; _hasRolled = false; }) : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$_diceToSpend d$_hitDie',
                style: GoogleFonts.cinzel(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF7B9ECC)),
            onPressed: _diceToSpend < _available ? () => setState(() { _diceToSpend++; _hasRolled = false; }) : null,
          ),
        ]),
        if (_diceToSpend > 0) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _roll,
            icon: const Icon(Icons.casino, size: 16),
            label: const Text('Roll dice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceVariant,
              foregroundColor: const Color(0xFF7B9ECC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          if (_hasRolled) ...[
            const SizedBox(height: 8),
            Text('Result: +$_rolledTotal HP',
                style: GoogleFonts.cinzel(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ],
        const SizedBox(height: 8),
        _RestEffect(icon: Icons.sports_esports, text: 'Class resources (Short Rest) restored'),
      ]),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.lato(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: (_loading || (_diceToSpend > 0 && !_hasRolled)) ? null : _confirm,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B9ECC), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Rest'),
        ),
      ],
    );
  }
}

// ── Rest effect row ────────────────────────────────────────────────────────────

class _RestEffect extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RestEffect({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(icon, color: AppTheme.primary, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.lato(color: AppTheme.textPrimary, fontSize: 12))),
      ]),
    );
  }
}