import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.qr_code_2_rounded,
      iconBgColors: [const Color(0xFFFF6B35), const Color(0xFFFF8C5A)],
      title: 'Generate Your QR',
      description:
          'Create a unique QR code for your vehicle, bag, keys, or any personal belonging. Attach it as a sticker.',
      bgAccentColor: const Color(0xFFFF6B35),
    ),
    _OnboardingData(
      icon: Icons.shield_rounded,
      iconBgColors: [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
      title: 'Complete Privacy',
      description:
          'When someone scans your QR, they can contact you anonymously. Zero personal information is ever shared.',
      bgAccentColor: const Color(0xFF2ECC71),
    ),
    _OnboardingData(
      icon: Icons.phone_callback_rounded,
      iconBgColors: [const Color(0xFF3498DB), const Color(0xFF2980B9)],
      title: 'Instant Connection',
      description:
          'Strangers can call or chat with you directly. If you miss the call, it auto-escalates to your emergency contacts.',
      bgAccentColor: const Color(0xFF3498DB),
    ),
    _OnboardingData(
      icon: Icons.emergency_rounded,
      iconBgColors: [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
      title: 'Emergency Safety Net',
      description:
          'Set up emergency contacts who get notified automatically if you don\'t respond. Your safety is our priority.',
      bgAccentColor: const Color(0xFFE74C3C),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ),
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container
                        FadeInDown(
                          key: ValueKey(index),
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: page.iconBgColors,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: page.bgAccentColor.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Title
                        FadeInUp(
                          key: ValueKey('title_$index'),
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        FadeInUp(
                          key: ValueKey('desc_$index'),
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 600),
                          child: Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              height: 1.6,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicators + Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? AppColors.accent
                              : (isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider),
                        ),
                      ),
                    ),
                  ),
                  // Next / Get Started button
                  GestureDetector(
                    onTap: _onNext,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: _currentPage == _pages.length - 1 ? 28 : 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final List<Color> iconBgColors;
  final String title;
  final String description;
  final Color bgAccentColor;

  _OnboardingData({
    required this.icon,
    required this.iconBgColors,
    required this.title,
    required this.description,
    required this.bgAccentColor,
  });
}