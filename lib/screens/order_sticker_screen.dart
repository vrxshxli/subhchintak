import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../providers/qr_provider.dart';

class OrderStickerScreen extends StatefulWidget {
  const OrderStickerScreen({super.key});
  @override
  State<OrderStickerScreen> createState() => _OrderStickerScreenState();
}

class _OrderStickerScreenState extends State<OrderStickerScreen> {
  final Map<int, int> _quantities = {}; // index → quantity (0 = not selected)

  int get _totalStickers => _quantities.values.fold(0, (a, b) => a + b);
  double get _subtotal => _totalStickers * 99.0;
  double get _shipping => _totalStickers > 0 ? 49.0 : 0;
  double get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qr = context.watch<QRProvider>();
    final tags = qr.tagDesigns;

    return Scaffold(
      appBar: AppBar(title: Text('Order Stickers', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FadeInDown(child: Text('Select stickers to order', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700))),
          const SizedBox(height: 8),
          FadeInDown(delay: const Duration(milliseconds: 100), child: Text('Choose which designs you want as physical waterproof stickers',
              style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
          const SizedBox(height: 24),

          if (tags.isEmpty) ...[
            Center(child: Column(children: [const SizedBox(height: 40), Icon(Icons.design_services_rounded, size: 56, color: Colors.grey[400]), const SizedBox(height: 16),
              Text('No designs yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)), const SizedBox(height: 8),
              Text('Create a sticker design first', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]))]))
          ] else
            ...List.generate(tags.length, (i) {
              final tag = tags[i];
              final qty = _quantities[i] ?? 0;
              final purpose = tag['customPurpose'] ?? tag['purpose'] ?? tag['templateType'] ?? 'Custom';
              final thumbB64 = tag['thumbnailBase64'] as String?;
              Uint8List? thumbBytes; if (thumbB64 != null) try { thumbBytes = base64Decode(thumbB64); } catch (_) {}

              return FadeInUp(delay: Duration(milliseconds: 80 * i), child: Container(
                margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: qty > 0 ? AppColors.accent.withOpacity(0.4) : (isDark ? AppColors.darkDivider : AppColors.lightDivider), width: qty > 0 ? 2 : 1)),
                child: Row(children: [
                  // Thumbnail
                  Container(width: 64, height: 64, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.accent.withOpacity(0.05),
                      border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                      child: thumbBytes != null ? ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.memory(thumbBytes, fit: BoxFit.cover))
                          : const Icon(Icons.qr_code_2_rounded, color: AppColors.accent, size: 28)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(purpose, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('\u20B999 per sticker', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500)),
                  ])),
                  // Quantity selector
                  Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: isDark ? AppColors.darkBg : AppColors.lightBg),
                      child: Row(children: [
                        IconButton(icon: const Icon(Icons.remove_rounded, size: 20), onPressed: qty > 0 ? () => setState(() => _quantities[i] = qty - 1) : null,
                            color: qty > 0 ? AppColors.accent : Colors.grey, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
                        Container(width: 32, alignment: Alignment.center,
                            child: Text('$qty', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: qty > 0 ? AppColors.accent : Colors.grey))),
                        IconButton(icon: const Icon(Icons.add_rounded, size: 20), onPressed: () => setState(() => _quantities[i] = qty + 1),
                            color: AppColors.accent, constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
                      ])),
                ])));
            }),

          const SizedBox(height: 16),
          // Design new button
          FadeInUp(delay: const Duration(milliseconds: 400), child: SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/design-qr-templates'),
            icon: const Icon(Icons.add_rounded, size: 20), label: Text('Design a New Sticker', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ))),
        ]))),

        // Order summary + Continue
        if (_totalStickers > 0)
          Container(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  border: Border(top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$_totalStickers sticker(s) × \u20B999', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)), Text('\u20B9${_subtotal.toInt()}', style: GoogleFonts.poppins(fontSize: 13))]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Flat shipping', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)), Text('\u20B9${_shipping.toInt()}', style: GoogleFonts.poppins(fontSize: 13))]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)), Text('\u20B9${_total.toInt()}', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.accent))]),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                  onPressed: () {
                    // Build items list and pass to address screen
                    final items = <Map<String, dynamic>>[];
                    _quantities.forEach((idx, qty) { if (qty > 0 && idx < tags.length) items.add({'tagDesignId': tags[idx]['id'], 'quantity': qty, 'purpose': tags[idx]['customPurpose'] ?? tags[idx]['purpose'] ?? 'Custom'}); });
                    Navigator.pushNamed(context, '/address', arguments: {'items': items, 'subtotal': _subtotal, 'shipping': _shipping, 'total': _total});
                  },
                  child: Text('Continue to Address', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                )),
              ])),
      ]),
    );
  }
}