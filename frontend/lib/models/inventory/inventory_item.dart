import 'package:flutter/widgets.dart' show IconData;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InventoryItem {
  final int id;         // CharacterInventory id (la relación)
  final int itemId;
  final String name;
  final String? itemType;
  final int quantity;
  final double weight;
  final double totalWeight;
  final bool equipped;
  final bool attuned;
  final String? notes;
  final bool requiresAttunement;

  const InventoryItem({
    required this.id,
    required this.itemId,
    required this.name,
    this.itemType,
    required this.quantity,
    required this.weight,
    required this.totalWeight,
    required this.equipped,
    required this.attuned,
    this.notes,
    this.requiresAttunement = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
        id:                 (j['id'] as num).toInt(),
        itemId:             (j['itemId'] as num).toInt(),
        name:               j['itemName'] as String? ?? '',
        itemType:           j['itemType'] as String?,
        quantity:           (j['quantity'] as num?)?.toInt() ?? 1,
        weight:             (j['weight'] as num?)?.toDouble() ?? 0,
        totalWeight:        (j['totalWeight'] as num?)?.toDouble() ?? 0,
        equipped:           j['equipped'] as bool? ?? false,
        attuned:            j['attuned'] as bool? ?? false,
        notes:              j['notes'] as String?,
        requiresAttunement: j['requiresAttunement'] as bool? ?? false,
      );

  // Icono por tipo
  IconData get typeIcon {
    switch (itemType?.toLowerCase()) {
      case 'weapon':      return MdiIcons.sword;
      case 'armor':       return FontAwesomeIcons.shieldHalved;
      case 'potion':      return FontAwesomeIcons.flaskVial;
      case 'wand':        return FontAwesomeIcons.wandMagicSparkles;
      case 'staff':       return FontAwesomeIcons.staffSnake;
      case 'rod':         return FontAwesomeIcons.wandMagic;
      case 'ring':        return FontAwesomeIcons.ring;
      case 'scroll':      return FontAwesomeIcons.scroll;
      case 'tool':        return FontAwesomeIcons.screwdriverWrench;
      case 'gear':        return MdiIcons.bagPersonal;
      case 'mount':       return FontAwesomeIcons.horse;
      default:            return FontAwesomeIcons.boxOpen;
    }
  }

  String get costDisplay {
    return '';   // Se puede enriquecer si el backend devuelve costInCopper
  }
}

// Modelo para buscar items en el catálogo (wizard + manage)
class ItemCatalogEntry {
  final int id;
  final String name;
  final String? itemType;
  final String? category;
  final double weight;
  final int costInCopper;
  final String? description;
  final String? damageDice;
  final String? damageType;
  final String? weaponRange;
  final List<String> weaponProperties;
  final int? armorClass;
  final String? armorType;
  final String? rarity;
  final bool requiresAttunement;

  const ItemCatalogEntry({
    required this.id,
    required this.name,
    this.itemType,
    this.category,
    required this.weight,
    required this.costInCopper,
    this.description,
    this.damageDice,
    this.damageType,
    this.weaponRange,
    this.weaponProperties = const [],
    this.armorClass,
    this.armorType,
    this.rarity,
    this.requiresAttunement = false,
  });

  factory ItemCatalogEntry.fromJson(Map<String, dynamic> j) => ItemCatalogEntry(
        id:                 (j['id'] as num).toInt(),
        name:               j['name'] as String? ?? '',
        itemType:           j['itemType'] as String?,
        category:           j['category'] as String?,
        weight:             (j['weight'] as num?)?.toDouble() ?? 0,
        costInCopper:       (j['costInCopper'] as num?)?.toInt() ?? 0,
        description:        j['description'] as String?,
        damageDice:         j['damageDice'] as String?,
        damageType:         j['damageType'] as String?,
        weaponRange:        j['weaponRange'] as String?,
        weaponProperties:   List<String>.from(j['weaponProperties'] ?? []),
        armorClass:         (j['armorClass'] as num?)?.toInt(),
        armorType:          j['armorType'] as String?,
        rarity:             j['rarity'] as String?,
        requiresAttunement: j['requiresAttunement'] as bool? ?? false,
      );

  // "25 gp" desde copper
  String get costDisplay {
    if (costInCopper == 0) return 'free';
    if (costInCopper % 1000 == 0) return '${costInCopper ~/ 1000} pp';
    if (costInCopper % 100 == 0)  return '${costInCopper ~/ 100} gp';
    if (costInCopper % 10 == 0)   return '${costInCopper ~/ 10} sp';
    return '$costInCopper cp';
  }

  String get statSummary {
    if (damageDice != null && damageDice!.isNotEmpty) {
      return '$damageDice ${damageType ?? ''}'.trim();
    }
    if (armorClass != null) return 'AC $armorClass';
    return '';
  }
}