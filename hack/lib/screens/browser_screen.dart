import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/history_service.dart';

class BrowserScreen extends StatefulWidget {
  final String browserName;

  const BrowserScreen({
    Key? key,
    required this.browserName,
  }) : super(key: key);

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late WebViewController controller;
  bool isLoading = true;
  bool canGoBack = false;
  final historyService = HistoryService();

  final Map<String, String> browsers = {
    'Google': 'https://www.google.com',
    'Bing': 'https://www.bing.com',
    'DuckDuckGo': 'https://duckduckgo.com',
    'Yahoo': 'https://www.yahoo.com',
  };

  // Legitimate domains whitelist
  final Map<String, List<String>> legitimateDomains = {
    'google.com': [
      'www.google.com',
      'docs.google.com',
      'drive.google.com',
      'mail.google.com'
    ],
    'facebook.com': ['www.facebook.com', 'm.facebook.com'],
    'twitter.com': ['www.twitter.com', 'mobile.twitter.com'],
    'microsoft.com': [
      'www.microsoft.com',
      'account.microsoft.com',
      'login.microsoft.com'
    ],
    'apple.com': ['www.apple.com', 'id.apple.com', 'support.apple.com'],
    'amazon.com': ['www.amazon.com', 'smile.amazon.com'],
    'netflix.com': ['www.netflix.com'],
    'youtube.com': ['www.youtube.com'],
    'github.com': ['www.github.com', 'api.github.com'],
    'yahoo.com': ['www.yahoo.com', 'mail.yahoo.com', 'search.yahoo.com'],
    'bing.com': ['www.bing.com'],
    'duckduckgo.com': ['duckduckgo.com', 'www.duckduckgo.com'],
  };

  // Safe domain extensions
  final Set<String> safeDomainExtensions = {
    '.com',
    '.org',
    '.edu',
    '.gov',
    '.co',
    '.in',
    '.net',
    '.io',
    '.us',
    '.ca'
  };

  // Keywords that indicate potential risks even on safe domains
  final Set<String> riskKeywords = {
    'free-streaming',
    'movie-download',
    'watch-online-free',
    'crack',
    'keygen',
    'torrent',
    'warez',
    'pirated',
    'free-download',
    'nulled',
    'patch',
    'serial-key',
    'activation-code'
  };

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  bool isLegitimateUrl(String url) {
    try {
      final uri = Uri.parse(url.toLowerCase());
      final host = uri.host;

      // Check legitimate domains whitelist
      for (var entry in legitimateDomains.entries) {
        final mainDomain = entry.key;
        final allowedDomains = entry.value;

        if (host.endsWith(mainDomain) || allowedDomains.contains(host)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isMaliciousUrl(String url) async {
    try {
      if (isLegitimateUrl(url)) {
        return false;
      }

      final uri = Uri.parse(url.toLowerCase());
      final domain = uri.host;
      final fullUrl = url.toLowerCase();

      bool hasSafeExtension = false;
      for (var extension in safeDomainExtensions) {
        if (domain.endsWith(extension)) {
          hasSafeExtension = true;
          break;
        }
      }

      if (!hasSafeExtension) {
        return true;
      }

      if (riskKeywords.any((keyword) => fullUrl.contains(keyword))) {
        return true;
      }

      final maliciousPatterns = [
        'malware',
        'phishing',
        'unwanted',
        'testsafebrowsing',
        'fake-login',
        'crypto_miner',
      ];

      if (maliciousPatterns.any((pattern) => fullUrl.contains(pattern))) {
        return true;
      }

      // Check for domain mimicking
      for (var legitDomain in legitimateDomains.keys) {
        if (domain.contains(legitDomain.replaceAll('.', '')) &&
            !domain.endsWith(legitDomain)) {
          return true;
        }
      }

      // Check for payment/banking related content on non-legitimate domains
      final sensitivePattern = RegExp(
        r'(payment|credit-card|bank|wallet|crypto|bitcoin|ethereum)',
        caseSensitive: false,
      );

      if (sensitivePattern.hasMatch(fullUrl) && !isLegitimateUrl(url)) {
        return true;
      }

      return false;
    } catch (e) {
      return true; 
    }
  }

  Future<void> scanPageContent() async {
    try {
     
      final links = await controller.runJavaScriptReturningResult('''
        Array.from(document.getElementsByTagName('a')).map(a => a.href);
      ''') as List<dynamic>;

      for (var link in links) {
        final isUnsafe = await isMaliciousUrl(link.toString());
        if (isUnsafe) {
          // Mark unsafe links
          await controller.runJavaScript('''
            document.querySelectorAll('a[href="${link.toString()}"]').forEach(link => {
              link.style.backgroundColor = '#ffebee';
              link.style.border = '2px solid #ff5252';
              link.style.padding = '2px 4px';
              link.style.borderRadius = '4px';
              link.style.color = '#d32f2f';
              link.title = '⚠️ Warning: Potentially Unsafe Website';
              link.addEventListener('click', (e) => {
                e.preventDefault();
                window.flutter_inappwebview.callHandler('showWarning', link.href);
              });
            });
          ''');
        }
      }
    } catch (e) {
      print('Error scanning page content: $e');
    }
  }

  Future<void> loadUrlWithSafetyCheck(String url) async {
    setState(() => isLoading = true);

    try {
      // Format URL if needed
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);

      // Allow search engine URLs
      if (browsers.values.any((browserUrl) => url.startsWith(browserUrl))) {
        await _loadUrl(uri, isSafe: true);
        await Future.delayed(const Duration(seconds: 2));
        await scanPageContent();
        return;
      }

   
      final isUnsafe = await isMaliciousUrl(url);

      if (!mounted) return;

      if (isUnsafe) {
        _showWarningDialog(url);
      } else {
        await _loadUrl(uri, isSafe: true);
        await Future.delayed(const Duration(seconds: 2));
        await scanPageContent();
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Invalid URL', 'Please enter a valid web address.');
      setState(() => isLoading = false);
    }
  }

  void _showWarningDialog(String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.red, size: 48),
        title: const Text('⚠️ Warning: Potentially Unsafe Website'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The website "$url" may be unsafe:'),
            const SizedBox(height: 12),
            const Text('• Unverified or suspicious domain'),
            const Text('• May contain harmful content'),
            const Text('• Could be a phishing attempt'),
            const Text('• Risk of malware or viruses'),
            const Text('• Potential security threat'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => isLoading = false);
            },
            child: const Text('Go Back', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadUrl(Uri.parse(url), isSafe: false);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child:
                const Text('Continue Anyway', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUrl(Uri uri, {required bool isSafe}) async {
    try {
      await controller.loadRequest(uri);
      historyService.saveToHistory(uri.toString(), widget.browserName,
          isSafe: isSafe);
    } catch (e) {
      _showErrorDialog(
          'Error', 'Failed to load the webpage. Please try again.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) async {
            if (!mounted) return;
            final canGoBackNow = await controller.canGoBack();
            setState(() {
              isLoading = false;
              canGoBack = canGoBackNow;
            });
            scanPageContent();
          },
          onNavigationRequest: (NavigationRequest request) {
            loadUrlWithSafetyCheck(request.url);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(browsers[widget.browserName]!));

    // Add JavaScript handler for warnings
    controller.addJavaScriptChannel(
      'showWarning',
      onMessageReceived: (JavaScriptMessage message) {
        _showWarningDialog(message.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !canGoBack,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await controller.canGoBack()) {
          controller.goBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.browserName),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              Container(
                color: Colors.white.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
