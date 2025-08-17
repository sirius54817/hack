import 'package:http/http.dart' as http;
import 'dart:convert';

class SafeBrowsingService {
  final String apiKey = 'AIzaSyDRc-q9PWJbFn6aSYrzHsra85Qbbjne2SM';

  Future<bool> isUrlSafe(String url) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=${apiKey};'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'client': {'clientId': 'your-client-id', 'clientVersion': '1.0.0'},
          'threatInfo': {
            'threatTypes': [
              'MALWARE',
              'SOCIAL_ENGINEERING',
              'UNWANTED_SOFTWARE',
              'POTENTIALLY_HARMFUL_APPLICATION'
            ],
            'platformTypes': ['ANY_PLATFORM'],
            'threatEntryTypes': ['URL'],
            'threatEntries': [
              {'url': url}
            ]
          }
        }),
      );

      final data = json.decode(response.body);
      return !data.containsKey('matches'); // URL is safe if no matches found
    } catch (e) {
      print('Safe Browsing API Error: $e');
      return false; // Treat as unsafe if API call fails
    }
  }
}
