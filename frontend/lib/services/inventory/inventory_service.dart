import 'dart:convert';
import 'dart:core';

import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';
import 'package:gestor_personajes_dnd/services/http/api_client.dart';

class InventoryService {
  final ApiClient _api;
  InventoryService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  // - Inventario del personaje
  Future<List<InventoryItem>> getInventory(int characterId) async {
    final res = await _api.get('/api/characters/$characterId/inventory');
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (res.statusCode == 401) throw Exception('Unauthorized');
    throw Exception('Failed to load inventory (${res.statusCode})');
  }

  Future<InventoryItem> addItem(int characterId, int itemId, {int quantity = 1}) async {
    final res = await _api.post(
      '/api/characters/$characterId/inventory/add',
      body: {'itemId': itemId, 'quantity': quantity},
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return InventoryItem.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>);
    }
    if (res.statusCode == 404) throw Exception('Item not found');
    throw Exception('Failed to add item (${res.statusCode})');
  }

  Future<void> removeItem(int characterId, int itemId) async {
    final res =
        await _api.delete('/api/characters/$characterId/inventory/item/$itemId');
    if (res.statusCode == 200 || res.statusCode == 204) return;
    throw Exception('Failed to remove item (${res.statusCode})');
  }

  Future<InventoryItem?> updateQuantity(
    int characterId, int inventoryId, int quantity) async {
      final res = await _api.patch(
        '/api/characters/$characterId/inventory/$inventoryId/quantity',
        body: {'quantity': quantity},
      );
      if (res.statusCode == 200) {
        return InventoryItem.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
      }
      // quantity = 0 -> el backend borra el item y devuelve el null/204
      if (res.statusCode == 204) return null;
      throw Exception('Failed to update quantity (${res.statusCode})');
    }

    Future<InventoryItem> toggleAttuned(
        int characterId, int inventoryId) async {
      final res = await _api.post(
        '/api/characters/$characterId/inventory/$inventoryId/toggle-attuned',
      );
      if (res.statusCode == 200) {
        return InventoryItem.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
      }
      if (res.statusCode == 409) throw Exception('Attunement limit reached (max 3 items)');
      if (res.statusCode == 404) throw Exception('Item not found');
      throw Exception('Failed to toggle attunement (${res.statusCode})');
    }

    // - Catálogo de items (para wizard y manage)
    Future<List<ItemCatalogEntry>> searchItems({
      String? type,
      String? name,
    }) async {
      final params = <String, String>{};
      if (type != null && type.isNotEmpty) params['type'] = type;
      if (name != null && name.isNotEmpty) params['name'] = name;
      final query = params.isNotEmpty
          ? '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '';
      final res = await _api.get('/api/items$query');
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((e) => ItemCatalogEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load items (${res.statusCode})');
    }

    Future<InventoryItem> toggleEquipped(int characterId, int inventoryId) async {
      final res = await _api.post(
        '/api/characters/$characterId/inventory/$inventoryId/toggle-equipped',
      );
      if (res.statusCode == 200) {
        return InventoryItem.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      throw Exception('Failed to toggle equipped (${res.statusCode})');
    }

    // ── Money ──────────────────────────────────────────────────
    /// Returns updated money map: {'platinum':0,'gold':0,'electrum':0,'silver':0,'copper':0}
    Future<Map<String, int>> getMoney(int characterId) async {
      final res = await _api.get('/api/characters/$characterId/money');
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'platinum': (j['platinum'] as num?)?.toInt() ?? 0,
          'gold':     (j['gold']     as num?)?.toInt() ?? 0,
          'electrum': (j['electrum'] as num?)?.toInt() ?? 0,
          'silver':   (j['silver']   as num?)?.toInt() ?? 0,
          'copper':   (j['copper']   as num?)?.toInt() ?? 0,
        };
      }
      throw Exception('Failed to load money (${res.statusCode})');
    }

    Future<Map<String, int>> setMoney(int characterId, Map<String, int> values) async {
      final res = await _api.post(
        '/api/characters/$characterId/money/set',
        body: values,
      );
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'platinum': (j['platinum'] as num?)?.toInt() ?? 0,
          'gold':     (j['gold']     as num?)?.toInt() ?? 0,
          'electrum': (j['electrum'] as num?)?.toInt() ?? 0,
          'silver':   (j['silver']   as num?)?.toInt() ?? 0,
          'copper':   (j['copper']   as num?)?.toInt() ?? 0,
        };
      }
      throw Exception('Failed to set money (${res.statusCode})');
    }

    Future<Map<String, int>> addMoney(int characterId, Map<String, int> values) async {
      final res = await _api.post(
        '/api/characters/$characterId/money/add',
        body: values,
      );
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'platinum': (j['platinum'] as num?)?.toInt() ?? 0,
          'gold':     (j['gold']     as num?)?.toInt() ?? 0,
          'electrum': (j['electrum'] as num?)?.toInt() ?? 0,
          'silver':   (j['silver']   as num?)?.toInt() ?? 0,
          'copper':   (j['copper']   as num?)?.toInt() ?? 0,
        };
      }
      throw Exception('Failed to add money (${res.statusCode})');
    }
}
