import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_abilities.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_combat.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_info.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/tabs/tab_traits.dart';
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

class _SheetBody extends StatelessWidget {
  const _SheetBody();

  static const _tabs = [
    Tab(icon: Icon(Icons.shield_outlined), text: 'Combat'),
    Tab(icon: Icon(Icons.bar_chart), text: 'Abilities'),
    Tab(icon: Icon(Icons.face_outlined), text: 'Traits'),
    Tab(icon: Icon(Icons.info_outline), text: 'Info'),
  ];

  @override
  Widget build(BuildContext context){
    final vm = context.watch<CharacterSheetViewModel>();

    //Cargando
    if (vm.isLoading){
      return Scaffold(
        appBar: AppBar(title: const Text('Character Sheet')),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    //Error
    if(vm.errorMessage != null){
      return Scaffold(
        appBar: AppBar(title: const Text('Character Sheet')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                  color: AppTheme.accent, size: 48),
                const SizedBox(height: 16),
                Text(vm.errorMessage!,
                  style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 14),
                  textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: vm.load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),                  
              ],
            ),
          ),
        ),
      );
    }

    final c = vm.character!;

    return DefaultTabController(
      length: _tabs.length,
      initialIndex: vm.tabIndex,
      child: Scaffold(
        //Appbar con la info del personaje
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(c.name,
                style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
              Text(
                [
                  if (c.raceName != null) c.raceName!,
                  if(c.dndClassName != null) c.dndClassName!,
                  'Level ${c.level}',
                ].join(' • '),
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
          bottom: TabBar(
            onTap: vm.setTab,
            tabs: _tabs,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            labelStyle: GoogleFonts.lato(
                fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.lato(fontSize: 11),
          ),
        ),
          // Tab vistas
          body: TabBarView(children: [
            TabCombat(c: c),
            TabAbilities(c: c),
            TabTraits(c: c),
            TabInfo(c: c),
        ]),
      ),
    );
  }
}