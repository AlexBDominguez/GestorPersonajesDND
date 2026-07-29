import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';
import 'package:gestor_personajes_dnd/services/inventory/inventory_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AddItemScreen extends StatefulWidget {
  final int characterId;
  final InventoryService service;
  final VoidCallback onAdded;

  const AddItemScreen({
    super.key,
    required this.characterId,
    required this.service,
    required this.onAdded,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  List<ItemCatalogEntry> _catalog = [];
  final Set<int> _selectedIds = {};
  bool _isLoading = true;
  String? _error;
  String _query = '';
  String _typeFilter = 'all';
  bool _adding = false;

  static const _typeFilters = [
    ('all', 'All'),
    ('weapon', 'Weapons'),
    ('armor', 'Armor'),
    ('adventuring_gear', 'Other Gear'),
    ('magic', 'Magic'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadCatalog();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _catalog = await widget.service.searchItems();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleItem(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _accept() async {
    if (_selectedIds.isEmpty) {
      Navigator.pop(context);
      return;
    }
    setState(() => _adding = true);
    try {
      for (final id in _selectedIds) {
        await widget.service.addItem(widget.characterId, id);
      }
      widget.onAdded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error adding items: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppTheme.accent,
        ));
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  List<ItemCatalogEntry> get _filtered => _catalog.where((item) {
        final matchesType = _typeFilter == 'all' ||
            (_typeFilter == 'magic'
                ? item.requiresAttunement
                : item.itemType?.toLowerCase() == _typeFilter);
        final matchesQuery = _query.isEmpty ||
            item.name.toLowerCase().contains(_query) ||
            (item.category?.toLowerCase().contains(_query) ?? false);
        return matchesType && matchesQuery;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final selected =
        _catalog.where((i) => _selectedIds.contains(i.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              color: AppTheme.surface,
              child: Column(
                children: [
                  // Title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppTheme.textSecondary, size: 20),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Cancel',
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Add Items',
                            style: GoogleFonts.libreBaskerville(
                                color: AppTheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_selectedIds.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primary),
                            ),
                            child: Text(
                              '${_selectedIds.length} selected',
                              style: GoogleFonts.libreBaskerville(
                                  color: AppTheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) =>
                            setState(() => _query = v.toLowerCase()),
                        style: GoogleFonts.lato(
                            color: AppTheme.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search items...',
                          hintStyle: GoogleFonts.lato(
                              color: AppTheme.textSecondary, fontSize: 14),
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
                  const SizedBox(height: 8),

                  // Type filters
                  SizedBox(
                    height: 30,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: _typeFilters.map((f) {
                        final active = _typeFilter == f.$1;
                        return GestureDetector(
                          onTap: () => setState(() => _typeFilter = f.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: active
                                    ? AppTheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              f.$2,
                              style: GoogleFonts.lato(
                                color: active
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Tab bar
                  TabBar(
                    controller: _tabCtrl,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primary,
                    labelStyle: GoogleFonts.libreBaskerville(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    tabs: [
                      const Tab(text: 'CATALOG'),
                      Tab(
                          text: _selectedIds.isEmpty
                              ? 'SELECTED'
                              : 'SELECTED (${_selectedIds.length})'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.primary))
                  : _error != null
                      ? _ErrorView(error: _error!, onRetry: _loadCatalog)
                      : TabBarView(
                          controller: _tabCtrl,
                          children: [
                            _CatalogTab(
                              filtered: _filtered,
                              selectedIds: _selectedIds,
                              allEmpty: _catalog.isEmpty,
                              onToggle: _toggleItem,
                              onRetry: _loadCatalog,
                            ),
                            _SelectedTab(
                              items: selected,
                              onToggle: _toggleItem,
                            ),
                          ],
                        ),
            ),

            // Bottom bar
            Container(
              color: AppTheme.surface,
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(
                            color: AppTheme.surfaceVariant, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.lato(
                              color: AppTheme.textSecondary, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _adding ? null : _accept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(0, 44),
                      ),
                      child: _adding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              _selectedIds.isEmpty
                                  ? 'Done'
                                  : 'Add ${_selectedIds.length} item${_selectedIds.length == 1 ? '' : 's'}',
                              style: GoogleFonts.lato(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Catalog tab

class _CatalogTab extends StatelessWidget {
  final List<ItemCatalogEntry> filtered;
  final Set<int> selectedIds;
  final bool allEmpty;
  final void Function(int id) onToggle;
  final VoidCallback onRetry;

  const _CatalogTab({
    required this.filtered,
    required this.selectedIds,
    required this.allEmpty,
    required this.onToggle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (allEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inventory_2_outlined,
              color: AppTheme.surfaceVariant, size: 48),
          const SizedBox(height: 12),
          Text('No items available.',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary)),
          ),
        ]),
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Text('No items found.',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 13)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _ItemTile(
        item: filtered[i],
        isSelected: selectedIds.contains(filtered[i].id),
        onToggle: () => onToggle(filtered[i].id),
      ),
    );
  }
}

// Selected tab

class _SelectedTab extends StatelessWidget {
  final List<ItemCatalogEntry> items;
  final void Function(int id) onToggle;

  const _SelectedTab({required this.items, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inventory_2_outlined,
              color: AppTheme.surfaceVariant, size: 48),
          const SizedBox(height: 16),
          Text('No items selected yet',
              style: GoogleFonts.libreBaskerville(
                  color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          Text('Go to the Catalog tab to add gear.',
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic)),
        ]),
      );
    }
    final totalWeight = items.fold<double>(0, (sum, i) => sum + i.weight);
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppTheme.surfaceVariant.withValues(alpha: 0.4),
        child: Text(
          '${items.length} items · ${totalWeight.toStringAsFixed(1)} lb total',
          style:
              GoogleFonts.lato(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (_, i) => _ItemTile(
            item: items[i],
            isSelected: true,
            onToggle: () => onToggle(items[i].id),
          ),
        ),
      ),
    ]);
  }
}

// Item tile

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
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          // Checkbox visual
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppTheme.primary : Colors.transparent,
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

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.libreBaskerville(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (item.requiresAttunement)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFB07DFF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFB07DFF)
                                  .withValues(alpha: 0.5)),
                        ),
                        child:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.auto_awesome,
                              size: 10, color: Color(0xFFB07DFF)),
                          const SizedBox(width: 3),
                          Text('Attunement',
                              style: GoogleFonts.lato(
                                  color: const Color(0xFFB07DFF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Wrap(
                  children: [
                    if (item.itemType != null)
                      Text(
                        _formatItemType(item.itemType!),
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    if (item.statSummary.isNotEmpty)
                      Text(
                        '  ·  ${item.statSummary}',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    if (item.rarity != null)
                      Text(
                        '  ·  ${_capitalize(item.rarity!)}',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    Text(
                      '  ·  ${item.costDisplay}',
                      style: GoogleFonts.lato(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    if (item.weight > 0)
                      Text(
                        '  ·  ${item.weight.toStringAsFixed(1)} lb',
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline,
                size: 18, color: AppTheme.textSecondary),
            splashRadius: 18,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
            tooltip: 'Description',
            onPressed: () => _showDetail(context, item),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context, ItemCatalogEntry item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(children: [
                Expanded(
                  child: Text(item.name,
                      style: GoogleFonts.libreBaskerville(
                          color: AppTheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                if (item.requiresAttunement)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB07DFF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              const Color(0xFFB07DFF).withValues(alpha: 0.5)),
                    ),
                    child:
                        Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.auto_awesome,
                          size: 12, color: Color(0xFFB07DFF)),
                      const SizedBox(width: 4),
                      Text('Requires Attunement',
                          style: GoogleFonts.lato(
                              color: const Color(0xFFB07DFF),
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
              ]),
              const SizedBox(height: 4),
              if (item.itemType != null)
                Text(_formatItemType(item.itemType!),
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 16),
              if (item.rarity != null)
                _DetailRow('Rarity', _capitalize(item.rarity!)),
              if (item.costDisplay != 'free')
                _DetailRow('Cost', item.costDisplay),
              if (item.weight > 0)
                _DetailRow('Weight', '${item.weight.toStringAsFixed(1)} lb'),
              if (item.statSummary.isNotEmpty)
                _DetailRow('Damage / AC', item.statSummary),
              if (item.armorType != null)
                _DetailRow('Armor Type', _capitalize(item.armorType!)),
              if (item.weaponProperties.isNotEmpty)
                _DetailRow('Properties', item.weaponProperties.join(', ')),
              if (item.requiresAttunement)
                _DetailRow('Attunement', 'Required'),
              if (item.description != null &&
                  item.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Description',
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
            ],
          ),
        ),
      ),
    );
  }
}

// Error view

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: AppTheme.accent, size: 40),
        const SizedBox(height: 12),
        Text(error,
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
          style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary)),
        ),
      ]),
    );
  }
}

// Detail row

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
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.lato(
                    color: AppTheme.textPrimary, fontSize: 14)),
          ),
        ]),
      );
}

// Helpers

String _formatItemType(String raw) {
  switch (raw.toUpperCase()) {
    case 'ADVENTURING_GEAR':
      return 'Adventuring Gear';
    case 'MOUNTS_AND_VEHICLES':
      return 'Mounts & Vehicles';
    default:
      return raw
          .toLowerCase()
          .split('_')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ');
  }
}

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}
