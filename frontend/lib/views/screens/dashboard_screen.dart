import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/views/screens/admin/admin_panel_screen.dart';
import 'package:gestor_personajes_dnd/views/screens/sheet/character_sheet_screen.dart';
import 'package:gestor_personajes_dnd/views/screens/wizard/character_creator_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/characters/character_list_viewmodel.dart';
import '../widgets/character_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterListViewModel()..load(),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final vm     = context.watch<CharacterListViewModel>();

    return Scaffold(
      // ── AppBar ───────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('DungeonScroll'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset, color: AppTheme.textSecondary),
            tooltip: 'Change Password',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          if (authVm.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined,
                color: AppTheme.primary),
              tooltip: 'User Management',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => authVm.logout(),
          ),
        ],
      ),

      // ── FAB: crear personaje ─────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Dentro del onPressed del FAB, antes de navegar al wizard:
          if (vm.characters.length >= 10) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Character limit reached (10 per account).'),
              backgroundColor: AppTheme.accent,
            ));
            return;
          }
          final newId = await Navigator.of(context).push<int>(MaterialPageRoute(
            builder: (_) => const CharacterCreatorScreen()),
          );
          if (newId != null) {
            // Recargamos la lista y abrimos la ficha del personaje recién creado
            await vm.load();
            if (context.mounted) {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CharacterSheetScreen(characterId: newId),
              ));
              vm.load(); // por si cambia HP u otros datos en la ficha
            }
          }
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.background,
        icon: const Icon(Icons.add),
        label: Text('New Character',
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
      ),

      // ── Body ─────────────────────────────────────────────────
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: () => vm.load(),
        child: _buildBody(context, vm),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CharacterListViewModel vm) {
    // Estado: cargando
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    // Estado: error
    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.accent, size: 48),
              const SizedBox(height: 16),
              Text('Error loading characters',
                  style: GoogleFonts.cinzel(
                      color: AppTheme.textPrimary, fontSize: 16)),
              const SizedBox(height: 8),
              Text(vm.errorMessage!,
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => vm.load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    // Estado: lista vacía
    if (vm.characters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, color: AppTheme.surfaceVariant, size: 80),
              const SizedBox(height: 24),
              Text('No adventurers yet',
                  style: GoogleFonts.cinzel(
                      color: AppTheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Create your first character\nto start the adventure.',
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Estado: lista con personajes
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 100),
      itemCount: vm.characters.length,
      itemBuilder: (context, index) {
        final character = vm.characters[index];
        return CharacterCard(
          character: character,
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => 
              CharacterSheetScreen(characterId: character.id),
            ));
            vm.load();
          },
          onEdit: (){
            //TODO: navegar al wizard en modo edición cuando esté implementado
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Edit — coming soon'),
              backgroundColor: AppTheme.surfaceVariant,
            ));
          },
          onDelete: () async{
            final name = character.name; //guardar antes de borrar
            await vm.deleteCharacter(character.id);
            if(context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$name has been deleted',
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.surfaceVariant,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                ),
              );              
            }
          },
        );
      },
  );
}
       
}