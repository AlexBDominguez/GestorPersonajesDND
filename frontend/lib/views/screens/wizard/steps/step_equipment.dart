import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';
import 'package:gestor_personajes_dnd/l10n/dnd_terms.dart';
import 'package:gestor_personajes_dnd/viewmodels/wizard/character_creator_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

String _tr(BuildContext context, {required String en, required String es, required String gl}) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'es') return es;
  if (code == 'gl') return gl;
  return en;
}

class StepEquipment extends StatefulWidget {
  const StepEquipment({super.key});

  @override
  State<StepEquipment> createState() => _StepEquipmentState();
}

class _StepEquipmentState extends State<StepEquipment>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _typeFilter = 'all';

  static const _typeFilters = [
    'all',
    'weapon',
    'armor',
    // ('potion', 'Potions'),        // not yet in catalog
    // ('ring', 'Rings'),            // not yet in catalog
    // ('rod', 'Rods'),              // not yet in catalog
    // ('scroll', 'Scrolls'),        // not yet in catalog
    // ('staff', 'Staves'),          // not yet in catalog
    // ('wand', 'Wands'),            // not yet in catalog
    // ('wondrous_item', 'Wondrous'),// not yet in catalog
    'adventuring_gear',
  ];
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CharacterCreatorViewModel>();
      if (vm.catalogItems.isEmpty) vm.loadItemCatalog();      

    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterCreatorViewModel>();

    return Column(children: [
      // ── Header compacto ──────────────────────────────────────────────────
      Container(
        color: AppTheme.surface,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Título + badge + hint (una sola fila)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              const Icon(Icons.backpack_outlined,
                  color: AppTheme.primary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(_tr(context, en: 'Starting Equipment', es: 'Equipo inicial', gl: 'Equipo inicial'),
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              if (vm.selectedItemIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary),
                  ),
                  child: Text(
                    '${vm.selectedItemIds.length} ${_tr(context, en: 'selected', es: 'seleccionados', gl: 'seleccionados')}',
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(
                  _tr(context, en: 'Optional', es: 'Opcional', gl: 'Opcional'),
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
            ]),
          ),
          const SizedBox(height: 8),

          // Buscador + filtro inline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              // Buscador
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                    style: GoogleFonts.lato(
                        color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: _tr(context, en: 'Search items...', es: 'Buscar objetos...', gl: 'Buscar obxectos...'),
                      hintStyle: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 12),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.textSecondary, size: 16),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppTheme.textSecondary, size: 14),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),

          // Filtros de tipo — scroll horizontal
          SizedBox(
            height: 30,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: _typeFilters.map((f) {
                final active = _typeFilter == f;
                final label = switch (f) {
                  'all' => _tr(context, en: 'All', es: 'Todos', gl: 'Todos'),
                  'weapon' => _tr(context, en: 'Weapons', es: 'Armas', gl: 'Armas'),
                  'armor' => _tr(context, en: 'Armor', es: 'Armadura', gl: 'Armadura'),
                  'adventuring_gear' => _tr(context, en: 'Other Gear', es: 'Otro equipo', gl: 'Outro equipo'),
                  _ => f,
                };
                return GestureDetector(
                  onTap: () => setState(() => _typeFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.primary.withOpacity(0.15)
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active
                            ? AppTheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(label,
                        style: GoogleFonts.lato(
                          color: active
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),

          // Tabs
          TabBar(
            controller: _tabCtrl,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            labelStyle: GoogleFonts.libreBaskerville(
                fontSize: 11, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: _tr(context, en: 'CATALOG', es: 'CATALOGO', gl: 'CATALOGO')),
              Tab(text: _tr(context, en: 'SELECTED', es: 'SELECCIONADO', gl: 'SELECCIONADO')),
            ],
          ),
        ]),
      ),
      const Divider(height: 1),

      // - Contenido -
      Expanded(
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _CatalogTab(
              vm: vm,
              query: _query,
              typeFilter: _typeFilter,
            ),
            _SelectedTab(vm: vm),
          ],
        ),
      ),
    ]);
  }
}

// - Tab Catalogo -
class _CatalogTab extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  final String query;
  final String typeFilter;

  const _CatalogTab({
    required this.vm,
    required this.query,
    required this.typeFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingItems) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary));      
    }
    if (vm.itemsError != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children:[
          const Icon(Icons.error_outline, color: AppTheme.accent, size: 40),
          const SizedBox(height: 12),
          Text(vm.itemsError!,
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: vm.loadItemCatalog,
              icon: const Icon (Icons.refresh, size: 16),
              label: Text(_tr(context, en: 'Retry', es: 'Reintentar', gl: 'Reintentar')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary)),
              ),
        ]),
      );
    }

    if (vm.catalogItems.isEmpty && !vm.isLoadingItems && vm.itemsError == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inventory_2_outlined, color: AppTheme.surfaceVariant, size: 48),
          const SizedBox(height: 12),
          Text(_tr(context, en: 'No items available.', es: 'No hay objetos disponibles.', gl: 'Non hai obxectos dispoñibles.'),
              style: GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: vm.loadItemCatalog,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(_tr(context, en: 'Retry', es: 'Reintentar', gl: 'Reintentar')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary)),
          ),
        ]),
      );
    }

    final filtered = vm.catalogItems.where((item) {
      final matchesType = typeFilter == 'all' ||
          (item.itemType?.toLowerCase() == typeFilter);
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          (item.category?.toLowerCase().contains(query) ?? false);
      return matchesType && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _tr(context, en: 'No items found.', es: 'No se encontraron objetos.', gl: 'Non se atoparon obxectos.'),
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary, fontSize: 13),
          ),
        );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _ItemTile(
        item: filtered[i],
        isSelected: vm.selectedItemIds.contains(filtered[i].id),
        onToggle: () => vm.toggleItem(filtered[i].id),
      ),
    );
  }
}

// - Tab Seleccionados -
class _SelectedTab extends StatelessWidget {
  final CharacterCreatorViewModel vm;
  const _SelectedTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final selected = vm.catalogItems
        .where((i) => vm.selectedItemIds.contains(i.id))
        .toList();
    
    if(selected.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inventory_2_outlined,
            color: AppTheme.surfaceVariant, size: 48),
          const SizedBox(height: 16),
          Text (_tr(context, en: 'No items selected yet', es: 'Aun no hay objetos seleccionados', gl: 'Ainda non hai obxectos seleccionados'),
            style: GoogleFonts.libreBaskerville(
              color: AppTheme.textSecondary, fontSize: 14
            )),
          const SizedBox(height: 8),
          Text(_tr(context, en: 'Go to the Catalog tab to add starting gear.', es: 'Ve a la pestana Catalogo para anadir equipo inicial.', gl: 'Vai a pestana Catalogo para engadir equipo inicial.'),
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 12,
              fontStyle: FontStyle.italic
            )),
        ]),
      );
    }

    //Total wieght
    final totalWeight = selected.fold<double>(0, (sum, i) => sum + i.weight);

    return Column(children: [
      //Weight summary
      Container(
        width: double.infinity,
        padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppTheme.surfaceVariant.withOpacity(0.4),
        child: Text(
          '${selected.length} ${_tr(context, en: 'items', es: 'objetos', gl: 'obxectos')} · ${totalWeight.toStringAsFixed(1)} lb ${_tr(context, en: 'total', es: 'total', gl: 'total')}',
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary, fontSize: 12),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: selected.length,
          itemBuilder: (_, i) => _ItemTile(
            item: selected[i],
            isSelected: true,
            onToggle: () => vm.toggleItem(selected[i].id),
        ),
        ),
    ),
    ]);
  }
}

// - Tile de item -
class _ItemTile extends StatelessWidget {
  final ItemCatalogEntry item;
  final bool isSelected;
  final VoidCallback onToggle;
  const _ItemTile({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.1)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.surfaceVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          //Checkbox visual
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isSelected ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
                width: 1.5,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check,
                    color: AppTheme.background, size: 14)
                : null,
          ),
          const SizedBox(width: 12),

          //Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: GoogleFonts.libreBaskerville(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 2),
                Row(children: [
                  if (item.itemType != null)
                    Text(
                      _formatItemType(context, item.itemType!),
                      style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 11)),
                  if (item.statSummary.isNotEmpty) ...[
                    const Text(' · ',
                      style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
                    Text(item.statSummary,
                      style: GoogleFonts.lato(
                        color: const Color(0xFFC8A45A),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                  ],
                ]),
              ]),          
          ),

          // Peso + coste
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(item.costDisplay,
                style: GoogleFonts.lato(
                    color: const Color(0xFFC8A45A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            Text('${item.weight} lb',
                style: GoogleFonts.lato(
                    color: AppTheme.textSecondary, fontSize: 10)),
          ]),

          // Info button — always show
          GestureDetector(
            onTap: () => _showDetail(context),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.info_outline,
                  color: AppTheme.textSecondary, size: 18),
            ),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text(item.name,
                    style: GoogleFonts.libreBaskerville(
                        color: AppTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  [
                    if (item.itemType != null) _formatItemType(context, item.itemType!),
                    if (item.rarity != null) item.rarity,
                  ].whereType<String>().join(' · '),
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _DetailRow(_tr(context, en: 'Cost', es: 'Costo', gl: 'Custo'), item.costDisplay),
                _DetailRow(_tr(context, en: 'Weight', es: 'Peso', gl: 'Peso'), '${item.weight} lb'),
                if (item.damageDice != null)
                  _DetailRow(_tr(context, en: 'Damage', es: 'Dano', gl: 'Dano'),
                      '${item.damageDice} ${item.damageType != null ? localizeDamageType(context, item.damageType!) : ''}'),
                if (item.armorClass != null)
                  _DetailRow(_tr(context, en: 'Armor Class', es: 'Clase de armadura', gl: 'Clase de armadura'),
                      '${item.armorClass}${item.armorType != null ? ' (${item.armorType})' : ''}'),
                if (item.weaponProperties.isNotEmpty)
                  _DetailRow(_tr(context, en: 'Properties', es: 'Propiedades', gl: 'Propiedades'),
                      item.weaponProperties.map((p) => localizeWeaponProperty(context, p)).join(', ')),
                if (item.requiresAttunement)
                  _DetailRow(_tr(context, en: 'Attunement', es: 'Sintonizacion', gl: 'Sintonizacion'), _tr(context, en: 'Required', es: 'Requerido', gl: 'Requirido')),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_tr(context, en: 'Description', es: 'Descripcion', gl: 'Descricion'),
                      style: GoogleFonts.libreBaskerville(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(item.description!,
                      style: GoogleFonts.lato(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          height: 1.6)),
                ],
              ]),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text('$label:',
            style: GoogleFonts.lato(
              color: AppTheme.textSecondary, fontSize: 12,
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

/// Converts raw backend itemType (e.g. ADVENTURING_GEAR) to a readable label.
String _formatItemType(BuildContext context, String raw) {
  switch (raw.toUpperCase()) {
    case 'ADVENTURING_GEAR':
      return _tr(context, en: 'Adventuring Gear', es: 'Equipo de aventura', gl: 'Equipo de aventura');
    case 'MOUNTS_AND_VEHICLES':
      return _tr(context, en: 'Mounts & Vehicles', es: 'Monturas y vehiculos', gl: 'Monturas e vehiculos');
    default:
      return raw
          .toLowerCase()
          .split('_')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ');
  }
}
