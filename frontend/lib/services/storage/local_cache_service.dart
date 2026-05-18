import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_personajes_dnd/models/character/player_character.dart';
import 'package:gestor_personajes_dnd/models/character/player_character_summary.dart';
import 'package:gestor_personajes_dnd/models/inventory/inventory_item.dart';

/// Caché local de JSON crudo guardado en SharedPreferences.
/// Claves con prefijo 'lc_' para evitar colisiones con otras prefs.
/// Cada entrada guarda también su timestamp ISO-8601 bajo 'lc_ts_<clave>'.
class LocalCacheService {
  static const _kPfx   = 'lc_';
  static const _kTsPfx = 'lc_ts_';

  // ── Primitivas ─────────────────────────────────────────────────────────────

  static Future<void> saveRaw(String key, String json) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('$_kPfx$key', json);
    await p.setString('$_kTsPfx$key', DateTime.now().toIso8601String());
  }

  static Future<String?> loadRaw(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getString('$_kPfx$key');
  }

  static Future<DateTime?> savedAt(String key) async {
    final p = await SharedPreferences.getInstance();
    final ts = p.getString('$_kTsPfx$key');
    return ts != null ? DateTime.tryParse(ts) : null;
  }

  // ── Claves internas ───────────────────────────────────────────────────────

  static String _charKey(int id) => 'char_$id';
  static String _invKey(int id)  => 'inv_$id';
  static const  _listKey         = 'char_list';

  // ── Personaje ─────────────────────────────────────────────────────────────

  static Future<void> saveCharacter(int id, String rawJson) =>
      saveRaw(_charKey(id), rawJson);

  static Future<PlayerCharacter?> loadCharacter(int id) async {
    final raw = await loadRaw(_charKey(id));
    if (raw == null) return null;
    try {
      return PlayerCharacter.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<DateTime?> characterSavedAt(int id) => savedAt(_charKey(id));

  // ── Inventario ────────────────────────────────────────────────────────────

  static Future<void> saveInventory(int characterId, String rawJson) =>
      saveRaw(_invKey(characterId), rawJson);

  static Future<List<InventoryItem>?> loadInventory(int characterId) async {
    final raw = await loadRaw(_invKey(characterId));
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── Lista de personajes ───────────────────────────────────────────────────

  static Future<void> saveCharacterList(String rawJson) =>
      saveRaw(_listKey, rawJson);

  static Future<List<PlayerCharacterSummary>?> loadCharacterList() async {
    final raw = await loadRaw(_listKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) =>
              PlayerCharacterSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<DateTime?> characterListSavedAt() => savedAt(_listKey);
}
