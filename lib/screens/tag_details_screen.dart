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

  static const _purposeIcons = <String, IconData>{
    'FOUR_WHEELER': Icons.directions_car_rounded,
    'Four-Wheeler': Icons.directions_car_rounded,
    'TWO_WHEELER': Icons.two_wheeler_rounded,
    'Two-Wheeler': Icons.two_wheeler_rounded,
    'BAG': Icons.backpack_rounded,
    'Bag': Icons.backpack_rounded,
    'KEY': Icons.key_rounded,
    'Key': Icons.key_rounded,
    'CHILD': Icons.child_care_rounded,
    'Child Safety': Icons.child_care_rounded,
    'ELDERLY': Icons.elderly_rounded,
    'Elderly Care': Icons.elderly_rounded,
    'PET': Icons.pets_rounded,
    'Pet Tag': Icons.pets_rounded,
    'CUSTOM': Icons.qr_code_2_rounded,
    'Custom': Icons.qr_code_2_rounded,
  };

  static const _purposeColors = <String, Color>{
    'FOUR_WHEELER': Color(0xFF3498DB), 'Four-Wheeler': Color(0xFF3498DB),
    'TWO_WHEELER': Color(0xFFFF6B35), 'Two-Wheeler': Color(0xFFFF6B35),
    'BAG': Color(0xFF9B59B6), 'Bag': Color(0xFF9B59B6),
    'KEY': Color(0xFFF39C12), 'Key': Color(0xFFF39C12),
    'CHILD': Color(0xFFE74C3C), 'Child Safety': Color(0xFFE74C3C),
    'ELDERLY': Color(0xFF2ECC71), 'Elderly Care': Color(0xFF2ECC71),
    'PET': Color(0xFF1ABC9C), 'Pet Tag': Color(0xFF1ABC9C),
    'CUSTOM': Color(0xFF95A5A6), 'Custom': Color(0xFF95A5A6),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qrProvider = context.watch<QRProvider>();
    final tags = qrProvider.qrCodes;

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
            FadeInDown(delay: const Duration(milliseconds: 100),
                child: Text('${tags.length} tag(s) created',
                    style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
            const SizedBox(height: 20),
            if (tags.isEmpty)
              Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No QR codes yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Generate your first QR from the dashboard', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400])),
                const SizedBox(height: 24),
                ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/order-qr'),
                    icon: const Icon(Icons.add_rounded), label: const Text('Create QR')),
              ])))
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => qrProvider.loadQRCodes(),
                  child: ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final t = tags[index];
                      final purpose = t['purpose'] ?? t['templateType'] ?? 'Custom';
                      final isActive = t['status'] == 'ACTIVE' || t['status'] == 'active';
                      final icon = _purposeIcons[purpose] ?? Icons.qr_code_2_rounded;
                      final color = _purposeColors[purpose] ?? AppColors.accent;
                      final qrId = t['uniqueCode'] ?? t['id'] ?? '';
                      final created = t['createdAt'] != null
                          ? DateTime.tryParse(t['createdAt'].toString())?.toLocal().toString().split(' ')[0] ?? ''
                          : '';

                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                          child: Column(children: [
                            Row(children: [
                              Container(width: 52, height: 52,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: color.withOpacity(0.1)),
                                  child: Icon(icon, color: color, size: 26)),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Flexible(child: Text(t['customPurpose'] ?? purpose,
                                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                                  const SizedBox(width: 8),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6)),
                                      child: Text(isActive ? 'Active' : 'Inactive',
                                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600,
                                              color: isActive ? AppColors.success : AppColors.warning))),
                                ]),
                                const SizedBox(height: 4),
                                Text('ID: $qrId  •  $created',
                                    style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                                if (t['scansCount'] != null && (t['scansCount'] as int) > 0)
                                  Text('${t['scansCount']} scan(s)',
                                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w500)),
                              ])),
                              // Download menu
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.download_rounded, color: AppColors.accent, size: 22),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                onSelected: (format) => _downloadQR(context, t, format),
                                itemBuilder: (ctx) => [
                                  _menuItem('PDF', Icons.picture_as_pdf_rounded, AppColors.danger),
                                  _menuItem('PNG', Icons.image_rounded, AppColors.info),
                                  _menuItem('JPEG', Icons.photo_rounded, AppColors.success),
                                  _menuItem('JPG', Icons.photo_camera_rounded, AppColors.warning),
                                ],
                              ),
                            ]),
                            // Re-design button for active QRs
                            if (isActive) ...[
                              const SizedBox(height: 12),
                              SizedBox(width: double.infinity, height: 40, child: OutlinedButton.icon(
                                onPressed: () {
                                  final qp = context.read<QRProvider>();
                                  qp.setCurrentQR(t);
                                  Navigator.pushNamed(context, '/design-qr-entry');
                                },
                                icon: const Icon(Icons.brush_rounded, size: 18),
                                label: Text('Re-design', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              )),
                            ],
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String format, IconData icon, Color color) {
    return PopupMenuItem(
      value: format,
      child: Row(children: [
        Icon(icon, color: color, size: 20), const SizedBox(width: 12),
        Text('Download $format', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  void _downloadQR(BuildContext context, Map<String, dynamic> qr, String format) async {
    final qrUrl = qr['qrDataUrl'] ?? 'https://shubhchintak.app/scan/${qr['uniqueCode'] ?? qr['id']}';
    final name = 'SHUBHCHINTAK_QR_${qr['uniqueCode'] ?? 'code'}';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        const SizedBox(width: 12),
        Text('Generating $format...'),
      ]),
      backgroundColor: AppColors.info, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));

    // Generate QR image
    final bytes = await QRExportService.generateSimpleQRImage(qrUrl, size: 800);
    if (bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate QR image')));
      }
      return;
    }

    // Save in requested format
    dynamic file;
    switch (format) {
      case 'PDF':
        // For PDF, save as PNG first then share (full PDF generation needs platform plugin)
        file = await QRExportService.saveAsPNG(bytes, name);
        break;
      case 'PNG':
        file = await QRExportService.saveAsPNG(bytes, name);
        break;
      case 'JPEG':
        file = await QRExportService.saveAsJPEG(bytes, name);
        break;
      case 'JPG':
        file = await QRExportService.saveAsJPG(bytes, name);
        break;
    }

    if (file != null && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // Share the file so user can save/print
      await Share.shareXFiles([XFile(file.path)], text: 'SHUBHCHINTAK QR Code - Scan to contact owner');
    }
  }
}