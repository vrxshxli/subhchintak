import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class OrderQRScreen extends StatefulWidget {
  const OrderQRScreen({super.key});

  @override
  State<OrderQRScreen> createState() => _OrderQRScreenState();
}

class _OrderQRScreenState extends State<OrderQRScreen> {
  int _selectedOption = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order QR Code', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text('Choose Your Plan',
                  style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text('Select how you want to receive your QR code',
                  style: GoogleFonts.poppins(fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ),
            const SizedBox(height: 32),
            // Option 1: Download PDF
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildPlanCard(
                context: context,
                index: 0,
                icon: Icons.picture_as_pdf_rounded,
                title: 'Download QR as PDF',
                description: 'Instantly download your QR code. Print at home or any print shop.',
                price: 199,
                originalPrice: 499,
                badge: 'INSTANT',
                badgeColor: AppColors.info,
                features: ['Instant download', 'High-resolution PDF', 'Print-ready format', 'Unlimited reprints'],
              ),
            ),
            const SizedBox(height: 16),
            // Option 2: Physical Sticker
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildPlanCard(
                context: context,
                index: 1,
                icon: Icons.local_shipping_rounded,
                title: 'Physical QR Sticker',
                description: 'Premium waterproof sticker delivered to your door.',
                price: 299,
                originalPrice: 599,
                badge: 'POPULAR',
                badgeColor: AppColors.accent,
                features: ['Waterproof sticker', 'UV resistant', 'Free delivery', 'Durable material'],
              ),
            ),
            const Spacer(),
            // Continue Button
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedOption >= 0
                      ? () => Navigator.pushNamed(context, '/design-qr-entry')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption >= 0 ? AppColors.accent : Colors.grey,
                  ),
                  child: Text('Continue to Design',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required int price,
    required int originalPrice,
    required String badge,
    required Color badgeColor,
    required List<String> features,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedOption == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.accent : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.accent.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: badgeColor.withOpacity(0.1),
                  ),
                  child: Icon(icon, color: badgeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(badge, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(description, style: GoogleFonts.poppins(fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
                // Radio indicator
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? AppColors.accent : Colors.grey, width: 2),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12, height: 12,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price
            Row(
              children: [
                Text('\u20B9$price', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accent)),
                const SizedBox(width: 10),
                Text('\u20B9$originalPrice',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('${((originalPrice - price) / originalPrice * 100).toInt()}% OFF',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Features
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: features.map((f) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text(f, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}