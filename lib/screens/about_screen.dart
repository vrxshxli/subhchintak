import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Logo
            FadeInDown(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
                  boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.qr_code_2_rounded, size: 52, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text('SHUBHCHINTAK', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 2)),
            ),
            const SizedBox(height: 4),
            FadeInDown(
              delay: const Duration(milliseconds: 150),
              child: Text('Version 1.0.0', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('Privacy-First Safety Platform', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
              ),
            ),
            const SizedBox(height: 32),

            // Mission
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.accent.withOpacity(0.1)),
                            child: const Icon(Icons.flag_rounded, color: AppColors.accent, size: 20)),
                        const SizedBox(width: 12),
                        Text('Our Mission', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'SHUBHCHINTAK is built to create a world where lost belongings find their way back home — safely and privately. We believe that helping a stranger should never compromise your personal information.',
                      style: GoogleFonts.poppins(fontSize: 14, height: 1.7, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // How it works
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.info.withOpacity(0.1)),
                            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.info, size: 20)),
                        const SizedBox(width: 12),
                        Text('Key Features', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _featureItem(Icons.shield_rounded, AppColors.success, 'Zero personal data exposure'),
                    _featureItem(Icons.call_rounded, AppColors.info, 'Anonymous calling & chat'),
                    _featureItem(Icons.emergency_rounded, AppColors.danger, 'Auto emergency escalation'),
                    _featureItem(Icons.qr_code_2_rounded, AppColors.accent, 'Custom QR designs'),
                    _featureItem(Icons.analytics_rounded, AppColors.warning, 'Real-time admin analytics'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Links
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Column(
                children: [
                  _linkTile(isDark, 'Privacy Policy', Icons.privacy_tip_outlined, () async {
                    final uri = Uri.parse('https://shubhchintak.app/privacy');
                    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            FadeIn(
              delay: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Text('Made with \u2764 in India', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('\u00A9 2026 SHUBHCHINTAK. All rights reserved.', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _linkTile(bool isDark, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}