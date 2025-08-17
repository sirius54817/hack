import 'package:flutter/material.dart';
import 'package:hack/screens/browser_screen.dart';
import 'package:hack/widgets/history_title.dart';
import '../models/browser_history.dart';
import '../services/history_service.dart';
import '../widgets/history_title.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final historyService = HistoryService();
  List<BrowserHistory> history = [];
  String filterBrowser = 'All';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final loadedHistory = await historyService.loadHistory();
    setState(() => history = loadedHistory);
  }

  List<BrowserHistory> get filteredHistory {
    if (filterBrowser == 'All') return history;
    return history.where((h) => h.browserName == filterBrowser).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browsing History'),
        actions: [
          PopupMenuButton<String>(
            initialValue: filterBrowser,
            onSelected: (value) {
              setState(() => filterBrowser = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Browsers'),
              ),
              ...['Google', 'Bing', 'DuckDuckGo', 'Yahoo'].map(
                (browser) => PopupMenuItem(
                  value: browser,
                  child: Text(browser),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredHistory.length,
        itemBuilder: (context, index) {
          final entry = filteredHistory[index];
          return HistoryTile(
            history: entry,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BrowserScreen(
                    browserName: entry.browserName,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
