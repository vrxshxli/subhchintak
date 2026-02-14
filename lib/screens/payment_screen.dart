import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../providers/qr_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = -1;
  bool _isProcessing = false;
  final _methods = [
    {'icon': Icons.account_balance_wallet_rounded, 'title': 'UPI', 'subtitle': 'GPay, PhonePe, Paytm'},
    {'icon': Icons.credit_card_rounded, 'title': 'Card', 'subtitle': 'Visa, Mastercard, RuPay'},
    {'icon': Icons.account_balance_rounded, 'title': 'Net Banking', 'subtitle': 'All major banks'},
  ];

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    final qr = context.read<QRProvider>();
    await qr.generateQR();
    await qr.saveTagDesign(); // Save the first tag design they just made on canvas
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showSuccess();
  }

  void _showSuccess() {
    final qr = context.read<QRProvider>();
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(0.1)),
            child: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success)),
        const SizedBox(height: 20),
        Text('Subscription Active!', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Your QR code has been generated and your first sticker design is saved.',
            textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('QR: ${qr.uniqueCode}', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent))),
        const SizedBox(height: 4),
        Text('Valid for 1 year  •  Unlimited designs', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
          onPressed: () { qr.reset(); Navigator.pop(ctx); Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false); },
          child: Text('Go to Dashboard', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
        )),
        const SizedBox(height: 8),
        TextButton(onPressed: () { qr.reset(); Navigator.pop(ctx); Navigator.pushReplacementNamed(context, '/tag-details'); },
            child: Text('View in My Tags', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.accent))),
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text('Subscribe', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FadeInDown(child: Container(width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B3A4B), Color(0xFF1B2838)]), borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.stars_rounded, color: AppColors.accent, size: 24), const SizedBox(width: 10),
                  Text('Yearly Subscription', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))]),
                const SizedBox(height: 16),
                _f('One QR code linked to your contact'), _f('Unlimited sticker designs'), _f('Anonymous calling & chat'),
                _f('Emergency auto-escalation'), _f('Download as PDF, PNG, JPEG'), _f('Real-time scan notifications'),
                const SizedBox(height: 16), Container(height: 1, color: Colors.white.withOpacity(0.2)), const SizedBox(height: 16),
                Row(children: [
                  Text('\u20B9199', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Text('\u20B9499', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                  const SizedBox(width: 10),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                      child: Text('60% OFF', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success))),
                ]),
                const SizedBox(height: 4), Text('per year', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Subscription', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)), Text('\u20B9199', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white))]),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('GST (18%)', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.6))), Text('\u20B936', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.6)))]),
                const SizedBox(height: 10), Container(height: 1, color: Colors.white.withOpacity(0.2)), const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text('\u20B9235', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.accent))]),
              ]))),
          const SizedBox(height: 28),
          FadeInUp(delay: const Duration(milliseconds: 200), child: Text('Payment Method', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ...List.generate(_methods.length, (i) { final m = _methods[i]; final sel = _selectedMethod == i;
            return FadeInUp(delay: Duration(milliseconds: 300 + i * 80), child: GestureDetector(onTap: () => setState(() => _selectedMethod = i),
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
            )); }),
        ]))),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: SizedBox(width: double.infinity, height: 56,
            child: ElevatedButton(onPressed: (_selectedMethod >= 0 && !_isProcessing) ? _processPayment : null,
              child: _isProcessing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text('Subscribe \u20B9235/year', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600))))),
      ]),
    );
  }

  Widget _f(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18), const SizedBox(width: 10),
    Expanded(child: Text(t, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.8))))]));
}