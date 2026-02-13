import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_selection_dialog.dart';

class AppShell extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const AppShell({super.key, required this.body, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('SHUBHCHINTAK', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.accent)),
        actions: [
          // Language icon
          IconButton(
            onPressed: () => LanguageSelectionDialog.show(context),
            icon: Icon(Icons.translate_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            tooltip: lang.t('language'),
          ),
          // Help icon
          IconButton(
            onPressed: () => _showHelpDialog(context, lang),
            icon: Icon(Icons.help_outline_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
          // Theme toggle
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
          // Notifications
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/updates'),
                icon: Icon(Icons.notifications_outlined, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(right: 8, top: 8, child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                  child: Text('${notifProvider.unreadCount}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                )),
            ],
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider))),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0: Navigator.pushReplacementNamed(context, '/profile'); break;
              case 1: Navigator.pushReplacementNamed(context, '/dashboard'); break;
              case 2: Navigator.pushReplacementNamed(context, '/chat'); break;
              case 3: Navigator.pushReplacementNamed(context, '/emergency-contacts'); break;
            }
          },
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), activeIcon: const Icon(Icons.person_rounded), label: lang.t('edit_profile').split(' ').first),
            BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), activeIcon: const Icon(Icons.dashboard_rounded), label: lang.t('hello').split(',').first),
            BottomNavigationBarItem(icon: const Icon(Icons.chat_bubble_outline_rounded), activeIcon: const Icon(Icons.chat_bubble_rounded), label: 'Chat'),
            BottomNavigationBarItem(icon: const Icon(Icons.emergency_outlined), activeIcon: const Icon(Icons.emergency_rounded), label: lang.t('emergency')),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, minChildSize: 0.3, maxChildSize: 0.85, expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text('How SHUBHCHINTAK Works', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  _helpStep('1', lang.t('onboard_title_1'), lang.t('onboard_desc_1')),
                  _helpStep('2', 'Print & Attach', 'Download as PDF or order a physical sticker. Attach to your belongings.'),
                  _helpStep('3', 'Someone Scans', 'When someone finds your item and scans the QR, they can instantly contact you.'),
                  _helpStep('4', lang.t('onboard_title_2'), lang.t('onboard_desc_2')),
                  _helpStep('5', lang.t('onboard_title_4'), lang.t('onboard_desc_4')),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _helpStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(num, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
        ])),
      ]),
    );
  }
}