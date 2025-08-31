import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/settings_service.dart';

class HeroSection extends StatefulWidget {
  @override
  _HeroSectionState createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  final LanguageService _languageService = LanguageService();
  final SettingsService _settingsService = SettingsService();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onChanged);
    _settingsService.addListener(_onChanged);
    if (!_settingsService.hasLoaded) {
      _settingsService.load();
    }
    // Auto slide every 5 seconds
    Future.delayed(Duration(seconds: 5), _autoSlide);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onChanged);
    _settingsService.removeListener(_onChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _autoSlide() {
    if (_pageController.hasClients) {
      final total = _settingsService.heroes.isNotEmpty ? _settingsService.heroes.length : 1;
      final nextPage = (_currentPage + 1) % total;
      _pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(Duration(seconds: 5), _autoSlide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroes = _settingsService.heroes;
    final hasHeroes = heroes.isNotEmpty;

    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      double h = 300;
      if (w >= 1200) h = 520; else if (w >= 900) h = 420; else h = 320;

      return ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: SizedBox(
          height: h,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: hasHeroes ? heroes.length : 1,
                itemBuilder: (context, index) {
                  final slide = hasHeroes ? heroes[index] : {'url': '',};
                  final imageUrl = (slide['url'] ?? '') as String;
                  final title = _settingsService.heroText;
                  final sub = _settingsService.subtitle;

                  return Container(
                    decoration: BoxDecoration(
                      image: imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: imageUrl.isEmpty ? Colors.black12 : null,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (title.isNotEmpty)
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 350),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  child: Text(
                                    title,
                                    key: ValueKey(title + _currentPage.toString()),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black,
                                          offset: Offset(2.0, 2.0),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              if (sub.isNotEmpty) const SizedBox(height: 10),
                              if (sub.isNotEmpty)
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    sub,
                                    key: ValueKey(sub + _currentPage.toString()),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 5.0,
                                          color: Colors.black,
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: 22),
                              Wrap(
                                spacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Scroll to categories section via a provided ScrollController/GlobalKey
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: Text(
                                      _settingsService.viewMenuLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/cart');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white70, width: 1.2),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: Text(
                                      _settingsService.orderNowLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Page indicators
              Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(hasHeroes ? heroes.length : 1, (i) => i).map((entry) {
                    final isActive = _currentPage == entry;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      width: isActive ? 22 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(isActive ? 0.95 : 0.4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}