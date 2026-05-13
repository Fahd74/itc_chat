import 'package:flutter/material.dart';
import 'package:itc_chat/features/auth/ui/screens/auth_guard.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── animation controllers ──
  late final AnimationController _dotController; // dot width pulse
  late final AnimationController _fadeController; // content fade/slide
  late final AnimationController _btnController; // button scale

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _btnScaleAnim;

  // ── data ──
  static const _pages = [
    _PageData(
      image: 'assets/Rectangle 160672.png',
      titleParts: [
        _TextPart('Stop ', Color(0xFF0F766E)),
        _TextPart('Drowning In ', Color(0xFF1AB5A9)),
        _TextPart('Research', Color(0xFF0F766E)),
      ],
      body:
          "Don't let endless PDFs and sources overwhelm you. Get instant summaries and find exactly what you need in seconds",
    ),
    _PageData(
      image: 'assets/Rectangle 160672 (1).png',
      titleParts: [
        _TextPart('Your ', Color(0xFF0F766E)),
        _TextPart('AI-Powered Study ', Color(0xFF1AB5A9)),
        _TextPart('Partner', Color(0xFF0F766E)),
      ],
      body:
          "From complex coding bugs to tricky academic theories, get clear explanations backed by transparent, reliable sources.",
    ),
    _PageData(
      image: 'assets/Rectangle 160684.png',
      titleParts: [
        _TextPart('Your ', Color(0xFF0F766E)),
        _TextPart('Personal Academic ', Color(0xFF1AB5A9)),
        _TextPart('Guide', Color(0xFF0F766E)),
      ],
      body:
          "Think of me as your 24/7 Class Rep. I'm here to organize your schedule, answer your academic queries, and keep you on track for success.",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _btnScaleAnim = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dotController.dispose();
    _fadeController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  // ── navigate to next page ──
  void _next() async {
    if (_currentPage < _pages.length - 1) {
      // content fade out
      await _fadeController.reverse();

      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGuard()),
      );
    }
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ──
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24, top: 4),
                child: AnimatedOpacity(
                  opacity: _currentPage < _pages.length - 1 ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF1AB5A9),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) async {
                  setState(() => _currentPage = index);
                  _dotController.forward(from: 0);
                  _fadeController.reset();
                  _fadeController.forward();
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _PageContent(page: _pages[index]);
                },
              ),
            ),

            // ── Dots ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final isActive = i == _currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _AnimatedDot(isActive: isActive, controller: _dotController),
                  );
                }),
              ),
            ),

            // ── Text content (fade + slide) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Public Sans',
                          ),
                          children: _pages[_currentPage].titleParts
                              .map(
                                (p) => TextSpan(
                                  text: p.text,
                                  style: TextStyle(color: p.color),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Body
                      Text(
                        _pages[_currentPage].body,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF9C9C9C),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Next / Get Started button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTapDown: (_) => _btnController.forward(),
                onTapUp: (_) {
                  _btnController.reverse();
                  _next();
                },
                onTapCancel: () => _btnController.reverse(),
                child: ScaleTransition(
                  scale: _btnScaleAnim,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1AB5A9).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.2, 0),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                            key: ValueKey(_currentPage == _pages.length - 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Dot ──────────────────────────────────────────────────
class _AnimatedDot extends StatelessWidget {
  final bool isActive;
  final AnimationController controller;

  const _AnimatedDot({required this.isActive, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      width: isActive ? 80 : 40,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isActive ? const Color(0xFF1AB5A9) : Colors.white.withOpacity(0.5),
        // glow on active dot
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF1AB5A9).withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }
}

// ─── Page image (zooms in on enter) ───────────────────────────────
class _PageContent extends StatefulWidget {
  final _PageData page;
  const _PageContent({required this.page});

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent> with SingleTickerProviderStateMixin {
  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnim;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _zoomAnim = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _zoomController, curve: Curves.easeOutCubic));
    _zoomController.forward();
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ScaleTransition(
        scale: _zoomAnim,
        child: Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(image: AssetImage(widget.page.image), fit: BoxFit.fill),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1AB5A9).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data models ───────────────────────────────────────────────────
class _PageData {
  final String image;
  final List<_TextPart> titleParts;
  final String body;
  const _PageData({required this.image, required this.titleParts, required this.body});
}

class _TextPart {
  final String text;
  final Color color;
  const _TextPart(this.text, this.color);
}
