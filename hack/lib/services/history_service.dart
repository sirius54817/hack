import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/browser_history.dart';

class HistoryService {
  static const String _historyKey = 'browser_history';

  Future<void> saveToHistory(String url, String browserName,
      {required bool isSafe}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();

    history.insert(
      0,
      BrowserHistory(
        url: url,
        timestamp: DateTime.now().toString(),
        browserName: browserName,
        isSafe: isSafe,
      ),
    );

    await prefs.setString(
      _historyKey,
      json.encode(history.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<BrowserHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson == null) return [];

    final List<dynamic> decodedHistory = json.decode(historyJson);
    return decodedHistory.map((item) => BrowserHistory.fromJson(item)).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> deleteHistoryItem(String url, String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();

    history
        .removeWhere((item) => item.url == url && item.timestamp == timestamp);

    await prefs.setString(
      _historyKey,
      json.encode(history.map((e) => e.toJson()).toList()),
    );
  }
}
