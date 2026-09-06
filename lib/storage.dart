import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UtiliaStorage {
  static const _favoritesKey = 'favorites';
  static const _historyKey = 'history';
  static const _darkModeKey = 'dark_mode';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<Set<String>> loadFavorites() async {
    final prefs = await _prefs;
    return (prefs.getStringList(_favoritesKey) ?? <String>[]).toSet();
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await _prefs;
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_historyKey) ?? <String>[];
    return raw.map((item) {
      try {
        return Map<String, dynamic>.from(jsonDecode(item) as Map);
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((item) => item.isNotEmpty).toList();
  }

  Future<void> addHistory(Map<String, dynamic> entry) async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_historyKey) ?? <String>[];
    raw.insert(0, jsonEncode(entry));
    if (raw.length > 50) raw.removeRange(50, raw.length);
    await prefs.setStringList(_historyKey, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await _prefs;
    await prefs.remove(_historyKey);
  }

  Future<bool> loadDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkModeKey, enabled);
  }
}
