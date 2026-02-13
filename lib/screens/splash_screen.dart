import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _progressValue = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _progressController, curve: const Interval(0.3, 0.7, curve: Curves.easeIn)));

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final token = await ApiService.getToken();
    if (!mounted) return;
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B2838), Color(0xFF0D1117), Color(0xFF1B3A4B)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background orbs
            Positioned(top: -100, right: -80, child: _glowOrb(220, AppColors.accent.withOpacity(0.08))),
            Positioned(bottom: -120, left: -60, child: _glowOrb(280, AppColors.accent.withOpacity(0.05))),
            Positioned(top: MediaQuery.of(context).size.height * 0.3, left: -40, child: _glowOrb(120, AppColors.info.withOpacity(0.06))),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.accent, AppColors.accentLight]),
                              boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 40, spreadRadius: 5)],
                            ),
                            child: const Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // Brand name
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Text('SHUBHCHINTAK',
                          style: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 4)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tagline
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineOpacity.value,
                        child: Text('Privacy-First Safety Platform',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.5), letterSpacing: 1.5)),
                      );
                    },
                  ),
                  const SizedBox(height: 56),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return SizedBox(
                        width: 140,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressValue.value,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 3,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom text
            Positioned(
              bottom: 50, left: 0, right: 0,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) => Opacity(
                  opacity: _taglineOpacity.value,
                  child: Text('Scan. Connect. Stay Safe.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.3), letterSpacing: 2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  const AnimatedBuilder({super.key, required Animation<double> animation, required this.builder}) : super(listenable: animation);
  @override
  Widget build(BuildContext context) => builder(context, null);
}