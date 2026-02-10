import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class TagDetailsScreen extends StatelessWidget {
  const TagDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tags = [
      {'id': 'QR-001', 'purpose': 'Four-Wheeler', 'status': 'Active', 'created': '2025-01-15', 'icon': Icons.directions_car_rounded, 'color': AppColors.info},
      {'id': 'QR-002', 'purpose': 'Backpack', 'status': 'Active', 'created': '2025-01-20', 'icon': Icons.backpack_rounded, 'color': AppColors.accent},
      {'id': 'QR-003', 'purpose': 'Keys', 'status': 'Inactive', 'created': '2025-02-01', 'icon': Icons.key_rounded, 'color': AppColors.warning},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tags', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(child: Text('All QR Codes', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700))),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text('${tags.length} tags created',
                  style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final t = tags[index];
                  final isActive = t['status'] == 'Active';
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
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: (t['color'] as Color).withOpacity(0.1)),
                            child: Icon(t['icon'] as IconData, color: t['color'] as Color, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(t['purpose'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(t['status'] as String,
                                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? AppColors.success : AppColors.warning)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('ID: ${t['id']}  •  ${t['created']}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.download_rounded, color: AppColors.accent, size: 22),
                            tooltip: 'Download PDF',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}