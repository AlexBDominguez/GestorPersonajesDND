import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/viewmodels/auth/auth_viewmodel.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_list_viewmodel.dart';
import 'package:provider/provider.dart';

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
    final vm = context.watch<CharacterListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Characters"),
        actions: [
          IconButton(
            onPressed: () => authVm.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO: navegar al wizar de creación (más adelante)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create character not implemented yet')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(CharacterListViewModel vm) {
    if(vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if(vm.errorMessage != null) {
      return Center(child: Text('Error: ${vm.errorMessage}'));
    }
    if(vm.characters.isEmpty) {
      return const Center(child: Text('No characters found. Create one to get started!'));
    }

    return ListView.separated(
      itemCount: vm.characters.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = vm.characters[index];
        return ListTile(
          title: Text(c.name),
          subtitle: Text('Level ${c.level}'),
          onTap: () {
            //TODO: navegar a ficha digital (más adelante)

          }
        );
      }
    );
  }
}