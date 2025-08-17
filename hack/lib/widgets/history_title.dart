import 'package:flutter/material.dart';
import '../models/browser_history.dart';

class HistoryTile extends StatelessWidget {
  final BrowserHistory history;
  final VoidCallback onTap;

  const HistoryTile({
    Key? key,
    required this.history,
    required this.onTap,
  }) : super(key: key);

  Widget _getBrowserIcon(String browserName) {
    IconData iconData;
    Color color;

    switch (browserName) {
      case 'Google':
        iconData = Icons.search;
        color = Colors.blue;
        break;
      case 'Bing':
        iconData = Icons.book_online;
        color = Colors.teal;
        break;
      case 'DuckDuckGo':
        iconData = Icons.privacy_tip;
        color = Colors.orange;
        break;
      case 'Yahoo':
        iconData = Icons.yard;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.public;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getBrowserIcon(history.browserName),
      title: Row(
        children: [
          Expanded(
            child: Text(
              Uri.parse(history.url).host,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: history.isSafe ? null : Colors.red,
              ),
            ),
          ),
          if (!history.isSafe)
            Tooltip(
              message: 'This site was flagged as unsafe',
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            history.url,
            style: TextStyle(
              color: history.isSafe ? null : Colors.red.withOpacity(0.7),
            ),
          ),
          Text(
            DateTime.parse(history.timestamp).toString(),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
