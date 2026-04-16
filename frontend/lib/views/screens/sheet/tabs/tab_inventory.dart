import 'package:flutter/material.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';
import 'package:gestor_personajes_dnd/services/inventory/inventory_service.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class TabInventory extends StatefulWidget {
  final PlayerCharacter character;
  const TabInventory({super.key, required this.character});

  @override
  State<TabInventory> createState() => _TabInventoryState();
}

class _TabInventoryState extends State<TabInventory> {
  final _service = InventoryService();
  List<InventoryItem> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _items = await _service.getInventory(widget.character.id);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppTheme.accent, size: 40),
          const SizedBox(height: 12),
          Text(_error!,
              style: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary)),
          ),
        ]),
      );
    }

    final attuned = _items.where((i) => i.attuned).toList();
    final equipped = _items.where((i) => i.equipped && !i.attuned).toList();
    final backpack = _items.where((i) => !i.equipped && !i.attuned).toList();
    final totalWeight = _items.fold<double>(0, (s, i) => s + i.totalWeight);
    final useEncumbrance = widget.character.useEncumbrance;
    final maxCarry = (widget.character.abilityScores['STR'] ?? 10) * 15.0;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          
          //Weight bar (only when encumbrance is enabled)
          if (useEncumbrance) ...[
            _WeightBar(current: totalWeight, max: maxCarry),
            const SizedBox(height: 20),
          ],

          //Currency
          _SectionTitle('Currency'),
          const SizedBox(height: 10),
          _CurrencyRow(character: widget.character),
          const SizedBox(height: 24),

          //Attuned
          _SectionTitle('Attuned Items'),
          const SizedBox(height: 4),
          Text('${attuned.length}/3 slots used.',
              style: GoogleFonts.lato(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontStyle: FontStyle.italic)),
          const SizedBox(height: 10),
          if (attuned.isEmpty)
            _EmptySlot(message: 'No attuned items')
          else
            ...attuned.map((item) => _InventoryItemTile(
                item: item,
                showWeight: useEncumbrance,
                onRemove: () => _removeItem(item),
                onToggleAttuned: () => _toggleAttuned(item),            
            )),
          const SizedBox(height: 24),

          //Equipped
          _SectionTitle('Equipped'),
          const SizedBox(height: 10),
          if (equipped.isEmpty)
            _EmptySlot(message: 'No equipped items')
          else
            ...equipped.map((item) => _InventoryItemTile(
                item: item,
                showWeight: useEncumbrance,
                onRemove: () => _removeItem(item),
                onToggleAttuned: () => _toggleAttuned(item),
            )),
          const SizedBox(height: 24),

          //Backpack
          Row(children: [
            const Expanded(child: _SectionTitleInline('Backpack')),
            // Add item button
            GestureDetector(
              onTap: () => _showAddItemSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.add,
                  color: AppTheme.primary, size: 14),
                  const SizedBox(width: 4),
                  Text('Add item',
                  style: GoogleFonts.lato(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          if(backpack.isEmpty)
            _EmptySlot(message: 'Backpack is empty')
          else
            ...backpack.map((item) => _InventoryItemTile(
                item: item,
                showWeight: useEncumbrance,
                onRemove: () => _removeItem(item),
                onToggleAttuned: () => _toggleAttuned(item),
            )),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Future<void> _removeItem(InventoryItem item) async{
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Remove item?',
          style: GoogleFonts.cinzel(color: AppTheme.primary)),
        content: Text('Remove "${item.name}" from inventory?',
          style: GoogleFonts.lato(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
              style:
                GoogleFonts.lato(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent),
            child: const Text('Remove')),
        ],
      ),
    );
    if (confirm == true) {
      await _service.removeItem(widget.character.id, item.id);
      await _load();
    }
  }

  Future<void> _toggleAttuned(InventoryItem item) async {
    try {
      await _service.toggleAttuned(widget.character.id, item.id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppTheme.accent,
        ));
      }
    }
  }

  Future<void> _showAddItemSheet(BuildContext context) async {
    final totalWeight = _items.fold<double>(0, (s, i) => s + i.totalWeight);
    final maxCarry = (widget.character.abilityScores['STR'] ?? 10) * 15.0;
    await showModalBottomSheet(
      context: context, 
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddItemSheet(
        characterId: widget.character.id,
        service: _service,
        useEncumbrance: widget.character.useEncumbrance,
        currentWeight: totalWeight,
        maxCarry: maxCarry,
        onAdded: _load,
      ),
    );
  }
}

// Weight bar widget
class _WeightBar extends StatelessWidget {
  final double current;
  final double max;
  const _WeightBar({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final pct = (max == 0 ? 0.0 : (current / max)).clamp(0.0, 1.0);
    final color = pct > 0.8
        ? AppTheme.accent
        : pct > 0.5
            ? Colors.orange
            : AppTheme.primary;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row (children: [
        Text('Carry Weight',
          style: GoogleFonts.lato(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.bold)),
        const Spacer(),
        Text('${current.toStringAsFixed(1)} / ${max.toStringAsFixed(0)} lb',
            style: GoogleFonts.lato(
                color: AppTheme.textSecondary, fontSize: 11)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 6,
          backgroundColor: AppTheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ]);
  }
}

// Inventory Item Tile
class _InventoryItemTile extends StatelessWidget{
  final InventoryItem item;
  final bool showWeight;
  final VoidCallback onRemove;
  final VoidCallback onToggleAttuned;
  const _InventoryItemTile({
    required this.item,
    required this.showWeight,
    required this.onRemove,
    required this.onToggleAttuned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.attuned
              ? AppTheme.primary.withOpacity(0.5)
              : AppTheme.surfaceVariant,
        ),
      ),
      child: Row(children: [
        //Tipo icon
        Text(item.typeIcon,
          style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),

        //Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                style: GoogleFonts.cinzel(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Row(children: [
                if(item.itemType !=null)
                  Text(_formatItemType(item.itemType!),
                    style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 11)),
                if (showWeight)
                  Text('·  ${item.totalWeight.toStringAsFixed(1)} lb',
                    style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 11)),
                if (item.attuned) ...[
                  const Text('  ·  ',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11)),
                    Text('Attuned',
                        style: GoogleFonts.lato(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ]),
              ]),
        ),

        // Qty badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('x${item.quantity}',
            style: GoogleFonts.lato(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 6),

            //Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                color: AppTheme.textSecondary, size: 18),
              color: AppTheme.surface,
              onSelected: (v) {
                if (v == 'attune') onToggleAttuned();
                if (v == 'remove') onRemove();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'attune',
                  child: Text(
                    item.attuned ? 'Remove attunement' : 'Attune',
                    style: 
                      GoogleFonts.lato(color: AppTheme.textPrimary)),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove',
                      style: GoogleFonts.lato(color: AppTheme.accent)),
                ),
              ],
            ),
      ]),
    );       
  }
}
// Add Item Sheet

class _AddItemSheet extends StatefulWidget {
  final int characterId;
  final InventoryService service;
  final bool useEncumbrance;
  final double currentWeight;
  final double maxCarry;
  final VoidCallback onAdded;
  const _AddItemSheet({
    required this.characterId,
    required this.service,
    required this.useEncumbrance,
    required this.currentWeight,
    required this.maxCarry,
    required this.onAdded,
  });

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _searchCtrl = TextEditingController();
  List<ItemCatalogEntry> _results = [];
  bool _searching = false;

  Future<void> _search(String q) async {
    if(q.length < 2) {
      setState(() => _results = []); return;
    }
    setState(() => _searching = true);
    try {
      _results = await widget.service.searchItems(name: q);
    } catch (_) {
      _results = [];
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Add Item',
              style: GoogleFonts.cinzel(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _search,
              style: GoogleFonts.lato(
                color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: GoogleFonts.lato(
                  color: AppTheme.textSecondary, fontSize: 13),
                prefixIcon: const Icon(Icons.search,
                  color: AppTheme.textSecondary, size: 18),
                filled: true,
                fillColor: AppTheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
                ),
              ),
            ),
            if (_searching)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppTheme.primary),
                )
            else Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final item = _results[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                    title: Text(item.name,
                      style: GoogleFonts.cinzel(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      [if (item.itemType != null) _formatItemType(item.itemType!), item.statSummary]
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      style: GoogleFonts.lato(
                        color: AppTheme.textSecondary,
                        fontSize: 11)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle,
                        color: AppTheme.primary),
                      onPressed: () async {
                        // Block if encumbrance is enabled and adding this item would exceed max carry
                        if (widget.useEncumbrance) {
                          final newTotal = widget.currentWeight + item.weight;
                          if (newTotal > widget.maxCarry) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  'Cannot add "${item.name}": would exceed carry capacity '
                                  '(${newTotal.toStringAsFixed(1)} / ${widget.maxCarry.toStringAsFixed(0)} lb)'),
                                backgroundColor: AppTheme.accent,
                                duration: const Duration(seconds: 3)));
                            }
                            return;
                          }
                        }
                        await widget.service.addItem(
                          widget.characterId, item.id);
                        widget.onAdded();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
        ]),
      ),
    );
  }        
}

// Currency Row
class _CurrencyRow extends StatelessWidget {
  final PlayerCharacter character;
  static const _coins = [
    ('CP', Colors.brown),
    ('SP', Colors.grey),
    ('EP', Color(0xFF7FAACC)),
    ('GP', Color(0xFFC8A45A)),
    ('PP', Color(0xFFB0A0C8)),
  ];

  const _CurrencyRow({required this.character});

  @override
  Widget build(BuildContext context) {
    final values = [
      character.copperPieces,
      character.silverPieces,
      character.electrumPieces,
      character.goldPieces,
      character.platinumPieces,
    ];
    return Row(
      children: List.generate(_coins.length, (i) {
        final label = _coins[i].$1;
        final color = _coins[i].$2;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text ('${values[i]}',
                  style: GoogleFonts.cinzel(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(label,
                  style: GoogleFonts.lato(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
           ]),
          ),
        );
      }),
    );
  }
}

//Widgets auxiliares
class _EmptySlot extends StatelessWidget {
  final String message;
  const _EmptySlot({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.surfaceVariant),
    ),
    child: Column(children: [
      const Icon(Icons.inventory_2_outlined,
        color: AppTheme.surfaceVariant, size: 36),
      const SizedBox(height: 8),
      Text(message,
        style: GoogleFonts.lato(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontStyle: FontStyle.italic)),
    ]),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title,
      style: GoogleFonts.cinzel(
        color: AppTheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1)),
    const SizedBox(width: 10),
    const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
  ]);
}

class _SectionTitleInline extends StatelessWidget {
  final String title;
  const _SectionTitleInline(this.title);

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(title,
      style: GoogleFonts.cinzel(
        color: AppTheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1)),
    const SizedBox(width: 10),
    const Expanded(child: Divider(color: AppTheme.surfaceVariant)),
  ]);
}

/// Converts raw backend itemType (e.g. ADVENTURING_GEAR) to a readable label.
String _formatItemType(String raw) {
  switch (raw.toUpperCase()) {
    case 'ADVENTURING_GEAR': return 'Adventuring Gear';
    case 'MOUNTS_AND_VEHICLES': return 'Mounts & Vehicles';
    default:
      return raw
          .toLowerCase()
          .split('_')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ');
  }
}
