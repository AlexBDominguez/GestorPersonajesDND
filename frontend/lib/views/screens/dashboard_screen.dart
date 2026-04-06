import 'package:flutter/material.dart';
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
    final authVm = context.read<AuthViewModel>();
    final vm     = context.watch<CharacterListViewModel>();

    return Scaffold(
      // ── AppBar ───────────────────────────────────────────────
      appBar: AppBar(
        title: const Text('DungeonScroll'),
        actions: [
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
          final created = await Navigator.of(context).push<bool>(MaterialPageRoute(
            builder: (_) => const CharacterCreatorScreen()),
          );
          if (created == true) vm.load(); // Recargar lista si se creó un personaje
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
              builder: (_) => CharacterSheetScreen(characterId: character.id),
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
          onDelete: () => vm.deleteCharacter(character.id),
        );
      },
  );
}
       

  void _confirmDelete(BuildContext context, CharacterListViewModel vm,
    int characterId, String characterName) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete "$characterName"?',
          style: GoogleFonts.cinzel(
            color: AppTheme.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold)),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.lato(
              color: AppTheme.textPrimary, fontSize: 14),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: characterName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary),
                ),
                const TextSpan(text: '? All data will be lost.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
              style: GoogleFonts.lato(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await vm.deleteCharacter(characterId);              
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold)),

          )
        ]
      ),
    );
  }
}