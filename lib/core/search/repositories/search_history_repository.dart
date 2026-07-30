import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryRepository {
  static const _key = 'search_history';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_key) ?? [];
  }

  Future<void> save(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_key, history);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}
