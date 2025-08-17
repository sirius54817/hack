import 'package:flutter/material.dart';
import '../widgets/browser_card.dart';
import 'history_screen.dart';
import 'browser_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late List<AnimationController> _cardControllers;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Individual card animations
    _cardControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500 + (index * 100)),
        vsync: this,
      )..forward(),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: FadeTransition(
        opacity: _fadeController,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              floating: true,
              pinned: true,
              expandedHeight: 160,
              backgroundColor: const Color(0xFF6C63FF),
              flexibleSpace: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _scaleController,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: FlexibleSpaceBar(
                  title: const Text(
                    'Secure Multi Browser',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6C63FF),
                                Color(0xFF9795F0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                AnimatedBuilder(
                  animation: _scaleController,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleController.value,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history, color: Colors.white),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const HistoryScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate(
                  [
                    _buildAnimatedCard(
                      0,
                      'Google',
                      'The world\'s most popular search engine',
                      const Color(0xFF4285F4).withOpacity(0.8),
                      Icons.search,
                    ),
                    _buildAnimatedCard(
                      1,
                      'Bing',
                      'Microsoft\'s intelligent search engine',
                      const Color(0xFF00A4EF).withOpacity(0.7),
                      Icons.public,
                    ),
                    _buildAnimatedCard(
                      2,
                      'DuckDuckGo',
                      'Private search engine that doesn\'t track you',
                      const Color(0xFFDE5833).withOpacity(0.7),
                      Icons.privacy_tip,
                    ),
                    _buildAnimatedCard(
                      3,
                      'Yahoo',
                      'Comprehensive search and news platform',
                      const Color(0xFF7B0099).withOpacity(0.7),
                      Icons.language,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(
    int index,
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return AnimatedBuilder(
      animation: _cardControllers[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0.0,
            50 * (1 - _cardControllers[index].value),
          ),
          child: Opacity(
            opacity: _cardControllers[index].value,
            child: _buildBrowserCard(
              context,
              title,
              description,
              color,
              icon,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrowserCard(
    BuildContext context,
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Hero(
      tag: 'browser_$title',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Add tap animation
            _cardControllers[0]
                .reverse()
                .then((_) => _cardControllers[0].forward());
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    BrowserScreen(browserName: title),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 200),
            tween: Tween<double>(begin: 1, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: color.withOpacity(0.5),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
