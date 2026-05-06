import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestor_personajes_dnd/config/app_theme.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';
import 'package:gestor_personajes_dnd/services/inventory/inventory_service.dart';
import 'package:gestor_personajes_dnd/viewmodels/characters/character_sheet_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class TabInventory extends StatefulWidget {
  final PlayerCharacter character;
  final CharacterSheetViewModel vm;
  const TabInventory({super.key, required this.character, required this.vm});

  @override
  State<TabInventory> createState() => _TabInventoryState();
}

class _TabInventoryState extends State<TabInventory> {
  final _service = InventoryService();
  List<InventoryItem> _items = [];
  bool _loading = true;
  String? _error;

  bool _isDragging = false; // Para evitar que el scroll interfiera con el drag

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

  //Equipa/desequipa. Tras la llamada recarga tanto el inventario como
  // el personaje completo (para actualizar AC en el header)
  Future<void> _toggleEquipped(InventoryItem item) async {
    try {
      await _service.toggleEquipped(widget.character.id, item.id);
      await Future.wait([_load(), widget.vm.load()]);
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _equipWithUndo(InventoryItem item) async {
    await _toggleEquipped(item);
    if (!mounted) return;
    final wasEquipped = !item.equipped; // after toggle it's the opposite
    final action = wasEquipped ? 'Equipped' : 'Unequipped';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$action "${item.name}"',
          style: GoogleFonts.lato(color: Colors.white)),
      backgroundColor: AppTheme.surface.withOpacity(0.95),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppTheme.primary,
        onPressed: () => _toggleEquipped(item),
      ),
    ));
  }

  Future<void> _attuneWithUndo(InventoryItem item) async {
    if (!item.requiresAttunement) {
      _showCannotAttuneMessage(item.name);
      return;
    }
    await _toggleAttuned(item);
    if (!mounted) return;
    final wasAttuned = !item.attuned;
    final action = wasAttuned ? 'Attuned' : 'Removed attunement for';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$action "${item.name}"',
          style: GoogleFonts.lato(color: Colors.white)),
      backgroundColor: AppTheme.surface.withOpacity(0.95),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppTheme.primary,
        onPressed: () => _toggleAttuned(item),
      ),
    ));
  }

  Future<void> _toggleAttuned(InventoryItem item) async {
    try {
      await _service.toggleAttuned(widget.character.id, item.id);
      await Future.wait([_load(), widget.vm.load()]);
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _removeItem(InventoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text ('Remove item?',
          style: GoogleFonts.cinzel(color: AppTheme.primary)),
        content: Text('Remove "${item.name}" from inventory?',
          style: GoogleFonts.lato(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
              style: GoogleFonts.lato(color: AppTheme.textSecondary))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white),
              child: const Text('Remove')),
        ],
      ),
    );
    if(confirm == true){
      await _service.removeItem(widget.character.id, item.itemId);
      await _load();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.accent,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _changeQuantity(InventoryItem item, int delta) async {
    final newQty = (item.quantity + delta).clamp(1, 9999);
    if (newQty == item.quantity) return;
    try {
      final updated = await _service.updateQuantity(
          widget.character.id, item.id, newQty);
      if (!mounted) return;
      if (updated != null) {
        setState(() {
          final idx = _items.indexWhere((i) => i.id == item.id);
          if (idx != -1) _items[idx] = updated;
        });
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showCannotAttuneMessage(String itemName) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.block, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '"$itemName" does not require attunement and cannot be attuned.',
            style: GoogleFonts.lato(color: Colors.white, fontSize: 13),
          ),
        ),
      ]),
      backgroundColor: AppTheme.accent,
      duration: const Duration(seconds: 3),
    ));
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

          //  Attuned (DragTarget) 
          _AttunedDropZone(
            items: attuned,
            isDragging: _isDragging,
            showWeight: useEncumbrance,
            onDropped: (item) => _attuneWithUndo(item),
            onRemoveAttuned: (item) => _toggleAttuned(item),
            onRemove: (item) => _removeItem(item),
            onQuantityChanged: (item, delta) => _changeQuantity(item, delta),
          ),
          const SizedBox(height: 24),

          //  Equipped (DragTarget) 
          _EquippedDropZone(
            items: equipped,
            isDragging: _isDragging,
            showWeight: useEncumbrance,
            onDropped: (item) => _equipWithUndo(item),
            onUnequip: (item) => _toggleEquipped(item),
            onRemove: (item) => _removeItem(item),
            onQuantityChanged: (item, delta) => _changeQuantity(item, delta),
          ),
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
          const SizedBox(height: 6),
          //Hint de drag (visible siempre que hay items en la mochila)
          if(backpack.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              const Icon(Icons.drag_indicator,
                color: AppTheme.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text('Long-press an item to drag it to Equipped or Attuned',
                style: GoogleFonts.lato(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic)),
            ]),
          ),
          if (backpack.isEmpty)
            _EmptySlot(message: 'Backpack is empty')
          else
          ...backpack.map((item) => _DraggableItemTile(
            item: item,
            showWeight: useEncumbrance,
            onRemove: () => _removeItem(item),
            onDragStarted: () => setState(() => _isDragging = true),
            onDragEnded: () => setState(() => _isDragging = false),
            onQuantityChanged: (delta) => _changeQuantity(item, delta),
          )),
        const SizedBox(height: 16),
        ]),
      ),
    );
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

//Drop Zone: Equipped

class _EquippedDropZone extends StatefulWidget {
  final List<InventoryItem> items;
  final bool isDragging;
  final bool showWeight;
  final void Function(InventoryItem) onDropped;
  final void Function(InventoryItem) onUnequip;
  final void Function(InventoryItem) onRemove;
  final void Function(InventoryItem, int delta)? onQuantityChanged;

  const _EquippedDropZone({
    required this.items,
    required this.isDragging,
    required this.showWeight,
    required this.onDropped,
    required this.onUnequip,
    required this.onRemove,
    this.onQuantityChanged,
  });

  @override
  State<_EquippedDropZone> createState() => _EquippedDropZoneState();
}

class _EquippedDropZoneState extends State<_EquippedDropZone> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<InventoryItem>(
      onWillAcceptWithDetails: (details) {
        //Solo acepta items del backpack (no equipados, no attuend)
        return !details.data.equipped && !details.data.attuned;
      },
      onAcceptWithDetails: (details) {
        setState(() => _hovering = false);
        widget.onDropped(details.data);
      },
      onMove: (_) => setState(() => _hovering = true),
      onLeave: (_) => setState(() => _hovering = false),
      builder: (_, candidateData, __){
        final isHovering = _hovering || candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering
                  ? AppTheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            color: isHovering
                ? AppTheme.primary.withOpacity(0.06)
                : Colors.transparent,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Equipped'),
                if (widget.isDragging)
                  _DropHint(
                    label: 'Drop here to equip',
                    active: isHovering,
                    icon: Icons.shield_outlined,
                  ),
                const SizedBox(height: 8),
                if (widget.items.isEmpty && !widget.isDragging)
                  _EmptySlot(message: 'No equipped items'),
                ...widget.items.map((item) => _EquippedItemTile(
                      item: item,
                      showWeight: widget.showWeight,
                      onUnequip: () => widget.onUnequip(item),
                      onRemove: () => widget.onRemove(item),
                      onQuantityChanged: widget.onQuantityChanged != null
                          ? (delta) => widget.onQuantityChanged!(item, delta)
                          : null,
                    )),
              ]),
        );
      },
    );
  }
}

//Drop Zone: Attuned
class _AttunedDropZone extends StatefulWidget {
  final List<InventoryItem> items;
  final bool isDragging;
  final bool showWeight;
  final void Function(InventoryItem) onDropped;
  final void Function(InventoryItem) onRemoveAttuned;
  final void Function(InventoryItem) onRemove;
  final void Function(InventoryItem, int delta)? onQuantityChanged;

  const _AttunedDropZone({
    required this.items,
    required this.isDragging,
    required this.showWeight,
    required this.onDropped,
    required this.onRemoveAttuned,
    required this.onRemove,
    this.onQuantityChanged,
  });

  @override
  State<_AttunedDropZone> createState() => _AttunedDropZoneState();
}

class _AttunedDropZoneState extends State<_AttunedDropZone>{
  bool _hovering = false;

  @override
  Widget build(BuildContext context){
    return DragTarget<InventoryItem>(
      //Aceptamos TODOS para poder dar feedback - la validación real va en onAccept
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        setState(() => _hovering = false);
        widget.onDropped(details.data); //la validación se hace en el padre
      },
      onMove: (_) => setState(() => _hovering = true),
      onLeave: (_) => setState(() => _hovering = false),
      builder: (_, candidateData, __) {
        final isHovering = _hovering || candidateData.isNotEmpty;
        //Si hay algo hovering que NO puede ser attuned, mostramos un flash rojo
        final invalidHover = isHovering &&
            candidateData.isNotEmpty &&
            candidateData.first != null &&
            !candidateData.first!.requiresAttunement;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: invalidHover
                  ? AppTheme.accent
                  : isHovering
                      ? const Color(0xFFB07DFF)
                      : Colors.transparent,
              width: 2,
            ),
            color: invalidHover
                ? AppTheme.accent.withOpacity(0.06)
                : isHovering
                    ? const Color(0xFFB07DFF).withOpacity(0.06)
                    : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: _SectionTitle(
                    'Attuned (${widget.items.length}/3)'),
                  ),
                  if (invalidHover)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.block,
                          color: AppTheme.accent, size: 14),
                        const SizedBox(width: 4),
                        Text('Cannot attune',
                          style: GoogleFonts.lato(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                      ]),
                    ),
              ]),
              if (widget.isDragging)
                _DropHint(
                  label: invalidHover
                    ? 'This item cannot be attuned'
                    : 'Drop here to attune',
                  active: isHovering,
                  isError: invalidHover,
                  icon: Icons.auto_awesome_outlined,
                ),
              const SizedBox(height: 8),
              if (widget.items.isEmpty && !widget.isDragging)
                _EmptySlot(message: 'No attuned items'),
              ...widget.items.map((item) => _AttunedItemTile(
                    item: item,
                    showWeight: widget.showWeight,
                    onRemoveAttuned: () => widget.onRemoveAttuned(item),
                    onRemove: () => widget.onRemove(item),
                    onQuantityChanged: widget.onQuantityChanged != null
                        ? (delta) => widget.onQuantityChanged!(item, delta)
                        : null,
                  )),
          ]),
        );
      },
    );
  }
}

//Draggable item tile (Backpack)
class _DraggableItemTile extends StatelessWidget{
  final InventoryItem item;
  final bool showWeight;
  final VoidCallback onRemove;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final void Function(int delta)? onQuantityChanged;

  const _DraggableItemTile({
    required this.item,
    required this.showWeight,
    required this.onRemove,
    required this.onDragStarted,
    required this.onDragEnded,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tile = _ItemTileContent(
      item: item,
      showWeight: showWeight,
      dimmed: false,
      onIncrement: onQuantityChanged != null ? () => onQuantityChanged!(1) : null,
      onDecrement: onQuantityChanged != null ? () => onQuantityChanged!(-1) : null,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert,
          color: AppTheme.textSecondary, size: 18),
        color: AppTheme.surface,
        onSelected: (v) { if (v == 'remove') onRemove(); },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'remove',
            child: Text('Remove',
              style: GoogleFonts.lato(color: AppTheme.accent)),
          ),
        ],
      ),
    );

    return LongPressDraggable<InventoryItem>(
      data: item,
      delay: const Duration(milliseconds: 300),
      onDragStarted: () {
        HapticFeedback.lightImpact();
        onDragStarted();
      },
      onDragEnd: (_) => onDragEnded(),
      onDraggableCanceled: (_, __) => onDragEnded(),
      //Widget "fantasma" que sigue al dedo
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9,
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(children: [
            Icon(item.typeIcon,
              size: 18,
              color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item.name,
                style: GoogleFonts.cinzel(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ),
    ),
    //El item original se vuelve semitransparente mientras se arrastra
    childWhenDragging: Opacity(
      opacity: 0.35,
      child: tile,      
    ),
    child: tile,
    );
  }
}

// Equipped item tile (tiene botón Unequip)
class _EquippedItemTile extends StatelessWidget {
  final InventoryItem item;
  final bool showWeight;
  final VoidCallback onUnequip;
  final VoidCallback onRemove;
  final void Function(int delta)? onQuantityChanged;

  const _EquippedItemTile({
    required this.item,
    required this.showWeight,
    required this.onUnequip,
    required this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemTileContent(
      item: item,
      showWeight: showWeight,
      accentBorder: true,
      onIncrement: onQuantityChanged != null ? () => onQuantityChanged!(1) : null,
      onDecrement: onQuantityChanged != null ? () => onQuantityChanged!(-1) : null,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert,
          color: AppTheme.textSecondary, size: 18),
        color: AppTheme.surface,
        onSelected: (v) {
          if (v == 'unequip') onUnequip();
          if (v == 'remove') onRemove();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'unequip',
            child: Text('Unequip',
              style: GoogleFonts.lato(color: AppTheme.primary)),
          ),
          PopupMenuItem(
            value: 'remove',
            child: Text('Remove',
              style: GoogleFonts.lato(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}


//Attuned item tile
class _AttunedItemTile extends StatelessWidget {
  final InventoryItem item;
  final bool showWeight;
  final VoidCallback onRemoveAttuned;
  final VoidCallback onRemove;
  final void Function(int delta)? onQuantityChanged;
  const _AttunedItemTile({
    required this.item,
    required this.showWeight,
    required this.onRemoveAttuned,
    required this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemTileContent(
      item: item,
      showWeight: showWeight,
      attunedBorder: true,
      onIncrement: onQuantityChanged != null ? () => onQuantityChanged!(1) : null,
      onDecrement: onQuantityChanged != null ? () => onQuantityChanged!(-1) : null,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert,
            color: AppTheme.textSecondary, size: 18),
        color: AppTheme.surface,
        onSelected: (v) {
          if (v == 'unattune') onRemoveAttuned();
          if (v == 'remove') onRemove();
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'unattune',
            child: Text('Remove attunement',
                style: GoogleFonts.lato(color: AppTheme.textPrimary)),
          ),
          PopupMenuItem(
            value: 'remove',
            child: Text('Remove',
                style: GoogleFonts.lato(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

//Contenido visual compartido de un tile de item
class _ItemTileContent extends StatelessWidget {
  final InventoryItem item;
  final bool showWeight;
  final bool dimmed;
  final bool accentBorder;   // equipped
  final bool attunedBorder;  // attuned
  final Widget trailing;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const _ItemTileContent({
    required this.item,
    required this.showWeight,
    this.dimmed = false,
    this.accentBorder = false,
    this.attunedBorder = false,
    required this.trailing,
    this.onIncrement,
    this.onDecrement,
  });

  void _showDescription(BuildContext context) {
    final desc = item.description;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(children: [
              Icon(item.typeIcon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.name,
                    style: GoogleFonts.cinzel(
                        color: AppTheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 4),
            if (item.itemType != null)
              Text(_formatItemType(item.itemType!),
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            if (desc != null && desc.isNotEmpty)
              Text(desc,
                  style: GoogleFonts.lato(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      height: 1.6))
            else
              Text('No description available.',
                  style: GoogleFonts.lato(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = attunedBorder
        ? const Color(0xFFB07DFF)
        : accentBorder
            ? AppTheme.primary.withOpacity(0.6)
            : AppTheme.surfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(children: [
        Icon(item.typeIcon,
          size: 18,
          color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name,
                style: GoogleFonts.cinzel(
                    color: dimmed
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Row(children: [
              if (item.itemType != null)
                Text(_formatItemType(item.itemType!),
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 11)),
              if (showWeight)
                Text('  ·  ${item.totalWeight.toStringAsFixed(1)} lb',
                    style: GoogleFonts.lato(
                        color: AppTheme.textSecondary, fontSize: 11)),
              if (item.attuned) ...[
                const Text('  ·  ',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
                Text('Attuned',
                    style: GoogleFonts.lato(
                        color: const Color(0xFFB07DFF),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ]),
          ]),
        ),
        // Quantity controls
        if (onIncrement != null || onDecrement != null)
          Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: item.quantity > 1 ? onDecrement : null,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.remove, size: 12,
                    color: item.quantity > 1
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary.withOpacity(0.3)),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${item.quantity}',
                  style: GoogleFonts.lato(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: onIncrement,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add, size: 12,
                    color: AppTheme.textSecondary),
              ),
            ),
          ])
        else
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
        IconButton(
          icon: Icon(Icons.info_outline,
              size: 18, color: AppTheme.textSecondary),
          splashRadius: 18,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          tooltip: 'Description',
          onPressed: () => _showDescription(context),
        ),
        trailing,
      ]),
    );
  }
}


// Drop hint - se muestra mientras hay un drag activo

class _DropHint extends StatelessWidget{
  final String label;
  final bool active;
  final bool isError;
  final IconData icon;

  const _DropHint({
    required this.label,
    required this.active,
    this.isError = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppTheme.accent : AppTheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: active
            ? color.withOpacity(0.12)
            : color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? color : color.withOpacity(0.3),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.lato(
                color: color,
                fontSize: 12,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}


// Add Item Sheet (sin)




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
class _CurrencyRow extends StatefulWidget {
  final PlayerCharacter character;
  const _CurrencyRow({required this.character});

  @override
  State<_CurrencyRow> createState() => _CurrencyRowState();
}

class _CurrencyRowState extends State<_CurrencyRow> {
  static const _coins = [
    ('CP', Colors.brown),
    ('SP', Colors.grey),
    ('EP', Color(0xFF7FAACC)),
    ('GP', Color(0xFFC8A45A)),
    ('PP', Color(0xFFB0A0C8)),
  ];
  static const _keys = ['copper', 'silver', 'electrum', 'gold', 'platinum'];

  late List<int> _values;
  final _svc = InventoryService();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _values = [
      widget.character.copperPieces,
      widget.character.silverPieces,
      widget.character.electrumPieces,
      widget.character.goldPieces,
      widget.character.platinumPieces,
    ];
  }

  Future<void> _update(Map<String, int> newValues) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result = await _svc.setMoney(widget.character.id, newValues);
      if (mounted) {
        setState(() {
          _values = [
            result['copper']!,
            result['silver']!,
            result['electrum']!,
            result['gold']!,
            result['platinum']!,
          ];
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _adjust(int index, int delta) {
    final newVal = (_values[index] + delta).clamp(0, 999999);
    final updated = List<int>.from(_values)..[index] = newVal;
    final body = {for (var i = 0; i < _keys.length; i++) _keys[i]: updated[i]};
    setState(() => _values = updated);
    _update(body);
  }

  void _editDialog(BuildContext context, int index) {
    final ctrl = TextEditingController(text: '${_values[index]}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Set ${_coins[index].$1}',
            style: GoogleFonts.cinzel(color: AppTheme.primary, fontSize: 14)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.lato(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.surfaceVariant,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_),
              child: Text('Cancel',
                  style: GoogleFonts.lato(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? _values[index];
              Navigator.pop(_);
              final updated = List<int>.from(_values)..[index] = v.clamp(0, 999999);
              final body = {for (var i = 0; i < _keys.length; i++) _keys[i]: updated[i]};
              setState(() => _values = updated);
              _update(body);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: Text('Set',
                style: GoogleFonts.cinzel(color: AppTheme.background)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_coins.length, (i) {
        final label = _coins[i].$1;
        final color = _coins[i].$2;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Column(children: [
              // + button
              GestureDetector(
                onTap: () => _adjust(i, 1),
                onLongPress: () => _adjust(i, 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                  ),
                  child: Icon(Icons.add, color: color, size: 14),
                ),
              ),
              // Value (tap to edit)
              GestureDetector(
                onTap: () => _editDialog(context, i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(children: [
                    Text('${_values[i]}',
                        style: GoogleFonts.cinzel(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(label,
                        style: GoogleFonts.lato(
                            color: AppTheme.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              // - button
              GestureDetector(
                onTap: () => _adjust(i, -1),
                onLongPress: () => _adjust(i, -10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
                  ),
                  child: Icon(Icons.remove, color: color.withOpacity(0.7), size: 14),
                ),
              ),
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
