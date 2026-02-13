import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_translations.dart';
import '../widgets/app_shell.dart';
import '../widgets/language_selection_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _avatarEmoji;
  int _avatarIndex = -1;
  final List<Color> _avatarBgs = [
    const Color(0xFFFFE0B2), const Color(0xFFFFF9C4), const Color(0xFFFFCCBC), const Color(0xFFE0E0E0),
    const Color(0xFFD1C4E9), const Color(0xFFFFE082), const Color(0xFFB3E5FC), const Color(0xFFCFD8DC),
    const Color(0xFFB2EBF2), const Color(0xFFFFF176), const Color(0xFFFFAB91), const Color(0xFFB2DFDB),
    const Color(0xFFBBDEFB), const Color(0xFFF8BBD0), const Color(0xFFC8E6C9), const Color(0xFFFFE57F),
  ];

  @override
  void initState() { super.initState(); _loadAvatar(); }

  Future<void> _loadAvatar() async {
    final p = await SharedPreferences.getInstance();
    setState(() { _avatarEmoji = p.getString('profile_avatar'); _avatarIndex = p.getInt('profile_avatar_index') ?? -1; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final user = auth.user ?? {};

    return AppShell(currentIndex: 0, body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
      const SizedBox(height: 10),
      FadeInDown(child: _avatarIndex >= 0 && _avatarEmoji != null
          ? Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: _avatarBgs[_avatarIndex],
              boxShadow: [BoxShadow(color: _avatarBgs[_avatarIndex].withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
              child: Center(child: Text(_avatarEmoji!, style: const TextStyle(fontSize: 48))))
          : Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
              boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
              child: Center(child: Text((user['name'] ?? 'U')[0].toUpperCase(), style: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white))))),
      const SizedBox(height: 16),
      FadeInDown(delay: const Duration(milliseconds: 100), child: Text(user['name'] ?? 'User', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700))),
      FadeInDown(delay: const Duration(milliseconds: 200), child: Text(user['email'] ?? '', style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
      const SizedBox(height: 32),
      _item(context, isDark, Icons.person_outline_rounded, lang.t('edit_profile'), 0, '/edit-profile'),
      _item(context, isDark, Icons.local_offer_outlined, lang.t('my_tags'), 1, '/tag-details'),
      _item(context, isDark, Icons.payment_rounded, lang.t('payment_history'), 2, '/payment-history'),
      _item(context, isDark, Icons.notifications_outlined, lang.t('notification_settings'), 3, '/notification-settings'),
      _item(context, isDark, Icons.shield_outlined, lang.t('privacy_security'), 4, '/privacy-security'),
      _item(context, isDark, Icons.help_outline_rounded, lang.t('help_support'), 5, '/help-support'),
      _item(context, isDark, Icons.info_outline_rounded, lang.t('about'), 6, '/about'),
      // Language change option
      FadeInUp(delay: const Duration(milliseconds: 720), child: Container(margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
          child: ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.info.withOpacity(0.08)),
                child: const Icon(Icons.translate_rounded, color: AppColors.info, size: 22)),
            title: Text(lang.t('language'), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(AppTranslations.languageNames[lang.currentLanguage] ?? 'English', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ]),
            onTap: () => LanguageSelectionDialog.show(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ))),
      const SizedBox(height: 16),
      FadeInUp(delay: const Duration(milliseconds: 780), child: SizedBox(width: double.infinity, height: 52,
          child: OutlinedButton.icon(
            onPressed: () async { await auth.logout(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false); },
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: Text(lang.t('sign_out'), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.danger)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
          ))),
      const SizedBox(height: 24),
      Text('SHUBHCHINTAK v1.0.0', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 20),
    ])));
  }

  Widget _item(BuildContext ctx, bool isDark, IconData icon, String title, int i, String route) {
    return FadeInUp(delay: Duration(milliseconds: 300 + i * 60), child: Container(margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
        child: ListTile(
          leading: Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.accent.withOpacity(0.08)),
              child: Icon(icon, color: AppColors.accent, size: 22)),
          title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          onTap: () async { await Navigator.pushNamed(ctx, route); _loadAvatar(); },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        )));
  }
}