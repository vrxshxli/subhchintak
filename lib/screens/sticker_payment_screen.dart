import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class StickerPaymentScreen extends StatefulWidget {
  const StickerPaymentScreen({super.key});
  @override
  State<StickerPaymentScreen> createState() => _StickerPaymentScreenState();
}

class _StickerPaymentScreenState extends State<StickerPaymentScreen> {
  int _selectedMethod = -1;
  bool _isProcessing = false;
  final _methods = [
    {'icon': Icons.account_balance_wallet_rounded, 'title': 'UPI', 'subtitle': 'GPay, PhonePe, Paytm'},
    {'icon': Icons.credit_card_rounded, 'title': 'Card', 'subtitle': 'Visa, Mastercard, RuPay'},
    {'icon': Icons.account_balance_rounded, 'title': 'Net Banking', 'subtitle': 'All major banks'},
  ];

  void _processPayment(Map<String, dynamic> args) async {
    setState(() => _isProcessing = true);
    final items = args['items'] as List<Map<String, dynamic>>? ?? [];
    final address = args['address'] as Map<String, dynamic>? ?? {};
    await Future.delayed(const Duration(seconds: 2));
    try {
      await ApiService.createStickerOrder(
        addressId: address['id'] ?? '',
        items: items.map((i) => {'tagDesignId': i['tagDesignId'], 'quantity': i['quantity']}).toList(),
      );
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showSuccess();
  }

  void _showSuccess() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(0.1)),
            child: const Icon(Icons.local_shipping_rounded, size: 44, color: AppColors.success)),
        const SizedBox(height: 20),
        Text('Order Placed!', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Your stickers will be printed and shipped to your address. Estimated delivery: 5-7 business days.',
            textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          onPressed: () { Navigator.pop(ctx); Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false); },
          child: Text('Back to Dashboard', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
        )),
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final items = args['items'] as List<Map<String, dynamic>>? ?? [];
    final subtotal = (args['subtotal'] as double?) ?? 0;
    final shipping = (args['shipping'] as double?) ?? 49;
    final gst = (subtotal * 0.18).roundToDouble();
    final grandTotal = subtotal + shipping + gst;
    final address = args['address'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      appBar: AppBar(title: Text('Payment', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Summary card
          FadeInDown(child: Container(width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B3A4B), Color(0xFF1B2838)]), borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order Summary', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 12),
                ...items.map((i) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text('${i['purpose']} x${i['quantity']}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white), overflow: TextOverflow.ellipsis)),
                  Text('\u20B9${(i['quantity'] as int) * 99}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
                ]))),
                const SizedBox(height: 8), Container(height: 1, color: Colors.white.withOpacity(0.15)), const SizedBox(height: 8),
                _summaryRow('Subtotal', '\u20B9${subtotal.toInt()}', 0.7),
                _summaryRow('Shipping', '\u20B9${shipping.toInt()}', 0.7),
                _summaryRow('GST (18%)', '\u20B9${gst.toInt()}', 0.7),
                const SizedBox(height: 8), Container(height: 1, color: Colors.white.withOpacity(0.15)), const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Total', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text('\u20B9${grandTotal.toInt()}', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ]),
              ]))),
          const SizedBox(height: 16),

          // Delivery address
          FadeInUp(delay: const Duration(milliseconds: 100), child: Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Deliver to: ${address['fullName'] ?? ''}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${address['addressLine1'] ?? ''}, ${address['city'] ?? ''} - ${address['pincode'] ?? ''}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ])),
              ]))),
          const SizedBox(height: 24),

          // Payment methods
          FadeInUp(delay: const Duration(milliseconds: 200), child: Text('Payment Method', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ...List.generate(_methods.length, (i) {
            final m = _methods[i]; final sel = _selectedMethod == i;
            return FadeInUp(delay: Duration(milliseconds: 300 + i * 80), child: GestureDetector(
              onTap: () => setState(() => _selectedMethod = i),
              child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: sel ? AppColors.accent : (isDark ? AppColors.darkDivider : AppColors.lightDivider), width: sel ? 2 : 1)),
                  child: Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.accent.withOpacity(0.1)),
                        child: Icon(m['icon'] as IconData, color: AppColors.accent, size: 22)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m['title'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(m['subtitle'] as String, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ])),
                    Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sel ? AppColors.accent : Colors.grey, width: 2)),
                        child: sel ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent))) : null),
                  ])),
            ));
          }),
        ]))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: SizedBox(width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: (_selectedMethod >= 0 && !_isProcessing) ? () => _processPayment(args) : null,
              child: _isProcessing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text('Pay \u20B9${grandTotal.toInt()}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            ))),
      ]),
    );
  }

  Widget _summaryRow(String label, String value, double opacity) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(opacity))),
      Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(opacity))),
    ]));
  }
}