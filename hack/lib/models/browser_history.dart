class BrowserHistory {
  final String url;
  final String timestamp;
  final String browserName;
  final bool isSafe;

  BrowserHistory({
    required this.url,
    required this.timestamp,
    required this.browserName,
    required this.isSafe,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'timestamp': timestamp,
        'browserName': browserName,
        'isSafe': isSafe,
      };

  factory BrowserHistory.fromJson(Map<String, dynamic> json) => BrowserHistory(
        url: json['url'],
        timestamp: json['timestamp'],
        browserName: json['browserName'],
        isSafe: json['isSafe'] ?? true,
      );
}
