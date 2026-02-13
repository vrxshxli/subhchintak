import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/language_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  final _icons = [Icons.qr_code_2_rounded, Icons.shield_rounded, Icons.phone_callback_rounded, Icons.emergency_rounded];
  final _colors = [
    [AppColors.accent, AppColors.accentLight],
    [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
    [const Color(0xFF3498DB), const Color(0xFF2980B9)],
    [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
  ];
  final _titleKeys = ['onboard_title_1', 'onboard_title_2', 'onboard_title_3', 'onboard_title_4'];
  final _subKeys = ['onboard_sub_1', 'onboard_sub_2', 'onboard_sub_3', 'onboard_sub_4'];
  final _descKeys = ['onboard_desc_1', 'onboard_desc_2', 'onboard_desc_3', 'onboard_desc_4'];

  @override
  void dispose() { _pc.dispose(); super.dispose(); }

  void _next() {
    if (_page < 3) _pc.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    else Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(alignment: Alignment.topRight, child: Padding(padding: const EdgeInsets.all(16),
              child: TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(lang.t('skip'), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.accent))))),
          Expanded(child: PageView.builder(
            controller: _pc, itemCount: 4, onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                TweenAnimationBuilder<double>(tween: Tween(begin: 0.8, end: 1.0), duration: const Duration(milliseconds: 500), curve: Curves.elasticOut,
                    builder: (ctx, v, c) => Transform.scale(scale: v, child: c),
                    child: Container(width: 130, height: 130, decoration: BoxDecoration(borderRadius: BorderRadius.circular(36),
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _colors[i]),
                        boxShadow: [BoxShadow(color: _colors[i][0].withOpacity(0.3), blurRadius: 32, offset: const Offset(0, 12))]),
                        child: Icon(_icons[i], size: 60, color: Colors.white))),
                const SizedBox(height: 44),
                Text(lang.t(_titleKeys[i]), textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: _colors[i][0].withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(lang.t(_subKeys[i]), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _colors[i][0]))),
                const SizedBox(height: 20),
                Text(lang.t(_descKeys[i]), textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 15, height: 1.6, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ])),
          )),
          Padding(padding: const EdgeInsets.fromLTRB(36, 0, 36, 36), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: List.generate(4, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.only(right: 8),
                width: _page == i ? 28 : 8, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                    color: _page == i ? _colors[_page][0] : (isDark ? AppColors.darkDivider : AppColors.lightDivider))))),
            GestureDetector(onTap: _next, child: AnimatedContainer(duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: _page == 3 ? 28 : 20, vertical: 16),
                decoration: BoxDecoration(gradient: LinearGradient(colors: _colors[_page]), borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: _colors[_page][0].withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_page == 3 ? lang.t('get_started') : lang.t('next'), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(width: 8), const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ]))),
          ])),
        ]),
      ),
    );
  }
}