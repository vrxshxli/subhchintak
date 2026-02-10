import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.user ?? {};

    return AppShell(
      currentIndex: 0,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            FadeInDown(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Center(
                  child: Text(
                    (user['name'] ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text(user['name'] ?? 'User Name', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Text(user['email'] ?? 'user@email.com',
                  style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ),
            const SizedBox(height: 32),
            _menuItem(context, isDark, Icons.person_outline_rounded, 'Edit Profile', 0),
            _menuItem(context, isDark, Icons.local_offer_outlined, 'My Tags', 1, route: '/tag-details'),
            _menuItem(context, isDark, Icons.payment_rounded, 'Payment History', 2),
            _menuItem(context, isDark, Icons.notifications_outlined, 'Notification Settings', 3),
            _menuItem(context, isDark, Icons.shield_outlined, 'Privacy & Security', 4),
            _menuItem(context, isDark, Icons.help_outline_rounded, 'Help & Support', 5),
            _menuItem(context, isDark, Icons.info_outline_rounded, 'About SHUBHCHINTAK', 6),
            const SizedBox(height: 16),
            // Logout button
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                  label: Text('Sign Out', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('SHUBHCHINTAK v1.0.0', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, bool isDark, IconData icon, String title, int index, {String? route}) {
    return FadeInUp(
      delay: Duration(milliseconds: 300 + index * 60),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
        child: ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.accent.withOpacity(0.08)),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          onTap: () {
            if (route != null) Navigator.pushNamed(context, route);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}