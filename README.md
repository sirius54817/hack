# Secure Multi Browser

A secure and privacy-focused Flutter application that provides access to multiple search engines with built-in safety features to protect users from malicious websites and phishing attempts.

## Features

- **Multi-Engine Search**: Access to popular search engines including Google, Bing, DuckDuckGo, and Yahoo
- **Safe Browsing**: Integrated Google Safe Browsing API to detect and block malicious websites
- **Phishing Detection**: Advanced phishing detection using machine learning algorithms
- **Browser History**: Track and manage your browsing history
- **Modern UI**: Beautiful, animated interface with Material Design 3
- **Cross-Platform**: Runs on Android, iOS, Web, Windows, macOS, and Linux
- **Privacy-Focused**: No tracking or data collection

## Security Features

- **Real-time Threat Detection**: Scans URLs against Google's Safe Browsing database
- **Phishing Protection**: Uses AI-powered detection to identify phishing attempts
- **Malware Blocking**: Prevents access to sites hosting malware or unwanted software
- **Secure WebView**: Isolated browsing environment for enhanced security

## Requirements

- Flutter SDK (^3.5.4)
- Dart SDK (^3.5.4)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sirius54817/hack.git
   cd hack
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Usage

1. Launch the app
2. Choose your preferred search engine from the home screen
3. Enter your search query or URL
4. Browse safely with real-time security monitoring

## Dependencies

- `webview_flutter`: For embedded web browsing
- `phish_detector`: AI-powered phishing detection
- `shared_preferences`: Local data storage for history
- `http`: API communication for safe browsing checks

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── home_screen.dart      # Main screen with search engine selection
│   ├── browser_screen.dart   # Web browsing interface
│   └── history_screen.dart   # Browsing history
├── services/
│   ├── safe_browsing_service.dart  # Google Safe Browsing integration
│   └── history_service.dart        # History management
├── widgets/
│   ├── browser_card.dart      # Search engine selection cards
│   ├── search_bar.dart        # Search input component
│   └── history_title.dart     # History item display
└── models/
    └── browser_history.dart   # History data model
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This application provides security features but cannot guarantee 100% protection against all threats. Users should exercise caution when browsing and avoid suspicious websites.

## Update

- Updated: 2025-09-03 — Comprehensive README with project details, features, and setup instructions.

## Changelog

- 2025-09-03: Complete README overhaul with detailed project information
- 2025-08-18: Add update note and changelog to README.
