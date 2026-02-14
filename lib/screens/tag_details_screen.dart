import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../providers/qr_provider.dart';
import '../services/qr_export_service.dart';

class TagDetailsScreen extends StatelessWidget {
  const TagDetailsScreen({super.key});

  static const _icons = <String, IconData>{
    'FOUR_WHEELER': Icons.directions_car_rounded, 'Four-Wheeler': Icons.directions_car_rounded,
    'TWO_WHEELER': Icons.two_wheeler_rounded, 'Two-Wheeler': Icons.two_wheeler_rounded,
    'BAG': Icons.backpack_rounded, 'Bag': Icons.backpack_rounded,
    'KEY': Icons.key_rounded, 'Key': Icons.key_rounded,
    'CHILD': Icons.child_care_rounded, 'Child Safety': Icons.child_care_rounded,
    'ELDERLY': Icons.elderly_rounded, 'Elderly Care': Icons.elderly_rounded,
    'PET': Icons.pets_rounded, 'Pet Tag': Icons.pets_rounded,
    'CUSTOM': Icons.qr_code_2_rounded, 'Custom': Icons.qr_code_2_rounded,
  };
  static const _colors = <String, Color>{
    'FOUR_WHEELER': Color(0xFF3498DB), 'Four-Wheeler': Color(0xFF3498DB),
    'TWO_WHEELER': Color(0xFFFF6B35), 'Two-Wheeler': Color(0xFFFF6B35),
    'BAG': Color(0xFF9B59B6), 'Bag': Color(0xFF9B59B6), 'KEY': Color(0xFFF39C12), 'Key': Color(0xFFF39C12),
    'CHILD': Color(0xFFE74C3C), 'Child Safety': Color(0xFFE74C3C),
    'ELDERLY': Color(0xFF2ECC71), 'Elderly Care': Color(0xFF2ECC71),
    'PET': Color(0xFF1ABC9C), 'Pet Tag': Color(0xFF1ABC9C),
    'CUSTOM': Color(0xFF95A5A6), 'Custom': Color(0xFF95A5A6),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qr = context.watch<QRProvider>();
    final tags = qr.tagDesigns;

    return Scaffold(
      appBar: AppBar(title: Text('My Tags', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
          actions: [if (qr.hasActiveSubscription) TextButton.icon(onPressed: () => Navigator.pushNamed(context, '/design-qr-templates'),
              icon: const Icon(Icons.add_rounded, color: AppColors.accent, size: 20),
              label: Text('New', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.accent)))]),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // QR info header
        if (qr.hasQR) ...[
          FadeInDown(child: Container(width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.accent.withOpacity(0.2))),
              child: Row(children: [const Icon(Icons.qr_code_2_rounded, color: AppColors.accent, size: 24), const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your QR: ${qr.uniqueCode}', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent)),
                  Text('${qr.scansCount} scan(s)  •  All tags use this same QR', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                ]))]))),
          const SizedBox(height: 16),
        ],
        FadeInDown(delay: const Duration(milliseconds: 100), child: Text('${tags.length} sticker design(s)',
            style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
        const SizedBox(height: 16),

        if (tags.isEmpty)
          Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.design_services_rounded, size: 64, color: Colors.grey[400]), const SizedBox(height: 16),
            Text('No sticker designs yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)), const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, qr.hasQR ? '/design-qr-templates' : '/order-qr'),
                icon: const Icon(Icons.add_rounded), label: Text(qr.hasQR ? 'Design Sticker' : 'Subscribe')),
          ])))
        else
          Expanded(child: RefreshIndicator(onRefresh: () => qr.loadQRCodes(), child: ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, i) {
              final t = tags[i];
              final purpose = t['customPurpose'] ?? t['purpose'] ?? t['templateType'] ?? 'Custom';
              final icon = _icons[t['purpose']] ?? _icons[purpose] ?? Icons.qr_code_2_rounded;
              final color = _colors[t['purpose']] ?? _colors[purpose] ?? AppColors.accent;
              final created = t['createdAt'] != null ? DateTime.tryParse(t['createdAt'].toString())?.toLocal().toString().split(' ')[0] ?? '' : '';
              final thumbB64 = t['thumbnailBase64'] as String?;
              Uint8List? thumbBytes; if (thumbB64 != null) try { thumbBytes = base64Decode(thumbB64); } catch (_) {}

              return FadeInUp(delay: Duration(milliseconds: 80 * i), child: Container(
                  margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                  child: Row(children: [
                    // Thumbnail or icon
                    Container(width: 64, height: 64, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                        color: color.withOpacity(0.05), border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                        child: thumbBytes != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.memory(thumbBytes, fit: BoxFit.cover))
                            : Icon(icon, color: color, size: 28)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(purpose, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${t['templateType'] ?? 'custom'}  •  $created', style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ])),
                    // Download
                    PopupMenuButton<String>(icon: const Icon(Icons.download_rounded, color: AppColors.accent, size: 22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (fmt) => _download(context, qr.qrDataUrl, t, fmt),
                        itemBuilder: (_) => [_mi('PNG', Icons.image_rounded, AppColors.info), _mi('JPEG', Icons.photo_rounded, AppColors.success), _mi('JPG', Icons.photo_camera_rounded, AppColors.warning)]),
                    // Delete
                    IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20), onPressed: () => qr.deleteTag(i)),
                  ])));
            },
          ))),
      ])),
    );
  }

  PopupMenuItem<String> _mi(String f, IconData ic, Color c) => PopupMenuItem(value: f, child: Row(children: [Icon(ic, color: c, size: 20), const SizedBox(width: 12), Text('Download $f', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500))]));

  void _download(BuildContext ctx, String url, Map<String, dynamic> tag, String fmt) async {
    final name = 'SHUBHCHINTAK_${tag['purpose'] ?? 'QR'}_${DateTime.now().millisecondsSinceEpoch}';
    final bytes = await QRExportService.generateSimpleQRImage(url, size: 800);
    if (bytes == null) return;
    dynamic file;
    switch (fmt) { case 'PNG': file = await QRExportService.saveAsPNG(bytes, name); break;
      case 'JPEG': file = await QRExportService.saveAsJPEG(bytes, name); break;
      case 'JPG': file = await QRExportService.saveAsJPG(bytes, name); break; }
    if (file != null && ctx.mounted) await Share.shareXFiles([XFile(file.path)], text: 'SHUBHCHINTAK QR - ${tag['purpose'] ?? 'Scan to contact owner'}');
  }
}