import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final updates = [
      {'title': 'New Feature: Pet Tags!', 'body': 'Now protect your furry friends with dedicated pet QR tags.', 'date': 'Feb 8, 2026', 'type': 'feature', 'icon': Icons.pets_rounded, 'color': AppColors.success},
      {'title': 'Flat 40% Off on Physical Stickers', 'body': 'Limited time offer. Order your premium waterproof stickers now!', 'date': 'Feb 5, 2026', 'type': 'offer', 'icon': Icons.local_offer_rounded, 'color': AppColors.accent},
      {'title': 'App Update v1.2.0', 'body': 'Performance improvements, bug fixes, and a refreshed chat interface.', 'date': 'Jan 28, 2026', 'type': 'update', 'icon': Icons.system_update_rounded, 'color': AppColors.info},
      {'title': 'Community Milestone', 'body': 'SHUBHCHINTAK has helped reunite 10,000+ items with their owners!', 'date': 'Jan 15, 2026', 'type': 'community', 'icon': Icons.celebration_rounded, 'color': AppColors.warning},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Updates', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: updates.length,
        itemBuilder: (context, index) {
          final u = updates[index];
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: (u['color'] as Color).withOpacity(0.1)),
                    child: Icon(u['icon'] as IconData, color: u['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u['title'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(u['body'] as String, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        const SizedBox(height: 8),
                        Text(u['date'] as String, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}