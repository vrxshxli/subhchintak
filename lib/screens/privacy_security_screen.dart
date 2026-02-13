import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sample payment data - in production, fetch from API
    final payments = [
      {'id': 'ORD-2026-001', 'type': 'PDF Download', 'amount': 235, 'status': 'Paid', 'date': '10 Feb 2026', 'qr': 'Four-Wheeler QR', 'icon': Icons.picture_as_pdf_rounded, 'color': AppColors.info},
      {'id': 'ORD-2026-002', 'type': 'Physical Sticker', 'amount': 353, 'status': 'Delivered', 'date': '05 Feb 2026', 'qr': 'Backpack QR', 'icon': Icons.local_shipping_rounded, 'color': AppColors.accent},
      {'id': 'ORD-2025-048', 'type': 'PDF Download', 'amount': 235, 'status': 'Paid', 'date': '20 Jan 2026', 'qr': 'Key QR', 'icon': Icons.picture_as_pdf_rounded, 'color': AppColors.info},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: payments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No payments yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Your payment history will appear here', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400])),
                ],
              ),
            )
          : Column(
              children: [
                // Summary card
                FadeInDown(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1B3A4B), Color(0xFF1B2838)]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem('Total Spent', '\u20B9823', Icons.payments_rounded),
                        Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                        _summaryItem('Orders', '${payments.length}', Icons.shopping_bag_rounded),
                        Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                        _summaryItem('Active QRs', '3', Icons.qr_code_2_rounded),
                      ],
                    ),
                  ),
                ),
                // Payment list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final p = payments[index];
                      final statusColor = (p['status'] as String) == 'Delivered'
                          ? AppColors.success
                          : (p['status'] as String) == 'Paid'
                              ? AppColors.info
                              : AppColors.warning;

                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: (p['color'] as Color).withOpacity(0.1),
                                    ),
                                    child: Icon(p['icon'] as IconData, color: p['color'] as Color, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p['type'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                                        Text(p['qr'] as String, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('\u20B9${p['amount']}', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                        child: Text(p['status'] as String, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider, height: 1),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(p['id'] as String, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                                  Text(p['date'] as String, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                                ],
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
    );
  }

  Widget _summaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.6))),
      ],
    );
  }
}