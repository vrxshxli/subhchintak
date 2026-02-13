import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/qr_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/language_selection_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _avatarEmoji;
  int _avatarIndex = -1;
  final List<Color> _avatarBgs = [
    const Color(0xFFFFE0B2), const Color(0xFFFFF9C4), const Color(0xFFFFCCBC), const Color(0xFFE0E0E0),
    const Color(0xFFD1C4E9), const Color(0xFFFFE082), const Color(0xFFB3E5FC), const Color(0xFFCFD8DC),
    const Color(0xFFB2EBF2), const Color(0xFFFFF176), const Color(0xFFFFAB91), const Color(0xFFB2DFDB),
    const Color(0xFFBBDEFB), const Color(0xFFF8BBD0), const Color(0xFFC8E6C9), const Color(0xFFFFE57F),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QRProvider>().loadQRCodes();
      context.read<AuthProvider>().loadProfile();
      _loadAvatar();
      final lp = context.read<LanguageProvider>();
      if (!lp.hasChosenLanguage) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) LanguageSelectionDialog.show(context, isFirstTime: true);
        });
      }
    });
  }

  Future<void> _loadAvatar() async {
    final p = await SharedPreferences.getInstance();
    setState(() { _avatarEmoji = p.getString('profile_avatar'); _avatarIndex = p.getInt('profile_avatar_index') ?? -1; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final qr = context.watch<QRProvider>();
    final lang = context.watch<LanguageProvider>();
    final userName = auth.user?['name'] ?? 'User';

    return AppShell(
      currentIndex: 1,
      body: Stack(children: [
        RefreshIndicator(
          onRefresh: () async { await qr.loadQRCodes(); await _loadAvatar(); },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FadeInDown(child: Row(children: [
                if (_avatarIndex >= 0 && _avatarEmoji != null)
                  Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: _avatarBgs[_avatarIndex]),
                      child: Center(child: Text(_avatarEmoji!, style: const TextStyle(fontSize: 26))))
                else
                  Container(width: 48, height: 48, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.accent, AppColors.accentLight])),
                      child: Center(child: Text(userName[0].toUpperCase(), style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${lang.t('hello')}, $userName', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                  Text(lang.t('keep_safe'), style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ])),
              ])),
              const SizedBox(height: 24),
              FadeInUp(delay: const Duration(milliseconds: 200), child: _qrCard(context, qr, lang)),
              const SizedBox(height: 20),
              FadeInUp(delay: const Duration(milliseconds: 300), child: Text(lang.t('quick_actions'), style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600))),
              const SizedBox(height: 16),
              FadeInUp(delay: const Duration(milliseconds: 400), child: Row(children: [
                Expanded(child: _act(context, Icons.qr_code_2_rounded, lang.t('order_qr'), lang.t('get_safety_qr'), '/order-qr', AppColors.accent)),
                const SizedBox(width: 12),
                Expanded(child: _act(context, Icons.design_services_rounded, lang.t('design_qr'), lang.t('customize_qr'), '/design-qr-entry', AppColors.info)),
              ])),
              const SizedBox(height: 12),
              FadeInUp(delay: const Duration(milliseconds: 500), child: Row(children: [
                Expanded(child: _act(context, Icons.emergency_rounded, lang.t('emergency'), lang.t('manage_contacts'), '/emergency-contacts', AppColors.danger)),
                const SizedBox(width: 12),
                Expanded(child: _act(context, Icons.local_offer_rounded, lang.t('my_tags'), lang.t('view_all_qr'), '/tag-details', AppColors.success)),
              ])),
              const SizedBox(height: 28),
              FadeInUp(delay: const Duration(milliseconds: 600), child: Text(lang.t('recent_activity'), style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600))),
              const SizedBox(height: 16),
              FadeInUp(delay: const Duration(milliseconds: 700), child: _activity(isDark)),
              const SizedBox(height: 80),
            ]),
          ),
        ),
        Positioned(bottom: 20, right: 20, child: FadeInUp(delay: const Duration(milliseconds: 800), child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/help-support'),
          child: Container(width: 56, height: 56, decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
              boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
              child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 26)),
        ))),
      ]),
    );
  }

  Widget _qrCard(BuildContext context, QRProvider qr, LanguageProvider lang) {
    final a = qr.hasActiveQR;
    return Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: a ? [const Color(0xFF1B3A4B), const Color(0xFF1B2838)] : [const Color(0xFF2D4059), const Color(0xFF1B2838)]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: const Color(0xFF1B2838).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(lang.t('qr_status'), style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(
              color: a ? AppColors.success.withOpacity(0.2) : AppColors.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: a ? AppColors.success.withOpacity(0.4) : AppColors.warning.withOpacity(0.4))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: a ? AppColors.success : AppColors.warning)),
                const SizedBox(width: 8),
                Text(a ? lang.t('active') : lang.t('inactive'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: a ? AppColors.success : AppColors.warning)),
              ])),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white.withOpacity(0.1)),
              child: const Icon(Icons.qr_code_2_rounded, size: 32, color: Colors.white)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a ? '${qr.qrCodes.length} QR Code(s)' : lang.t('no_active_qr'), style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text(a ? lang.t('belongings_protected') : lang.t('generate_to_start'), style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.6))),
          ])),
        ]),
        if (!a) ...[const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/order-qr'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text(lang.t('generate_first_qr'), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white))))],
      ]),
    );
  }

  Widget _act(BuildContext ctx, IconData icon, String title, String sub, String route, Color color) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return GestureDetector(onTap: () => Navigator.pushNamed(ctx, route), child: Container(padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.1)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 14),
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        ])));
  }

  Widget _activity(bool isDark) {
    final items = [
      {'icon': Icons.qr_code_scanner, 'title': 'QR Scanned', 'sub': 'Someone scanned your vehicle QR', 'time': '2h ago', 'color': AppColors.info},
      {'icon': Icons.call_received, 'title': 'Call Received', 'sub': 'Anonymous call - 2 min', 'time': 'Yesterday', 'color': AppColors.success},
      {'icon': Icons.chat_bubble_outline, 'title': 'New Message', 'sub': 'Stranger sent a message', 'time': '2 days', 'color': AppColors.accent},
    ];
    return Column(children: items.map((a) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: (a['color'] as Color).withOpacity(0.1)),
              child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['title'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(a['sub'] as String, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          ])),
          Text(a['time'] as String, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        ]))).toList());
  }
}