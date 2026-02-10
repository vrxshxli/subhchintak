import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class DesignQREntryScreen extends StatelessWidget {
  const DesignQREntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Design Your QR', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text('Choose a Template', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text('Select a predefined template or create a custom design',
                  style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ),
            const SizedBox(height: 32),
            // Template button
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _entryCard(
                context: context,
                icon: Icons.grid_view_rounded,
                title: 'Use Predefined Template',
                description: 'Choose from vehicle, bag, key, and other purpose-specific templates',
                color: AppColors.accent,
                onTap: () => Navigator.pushNamed(context, '/design-qr-templates'),
              ),
            ),
            const SizedBox(height: 16),
            // Custom button
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _entryCard(
                context: context,
                icon: Icons.brush_rounded,
                title: 'Custom Design Canvas',
                description: 'Create your own unique QR design with colors, images, and icons',
                color: AppColors.info,
                onTap: () => Navigator.pushNamed(context, '/qr-canvas'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: color.withOpacity(0.1)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(description, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}