import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../providers/qr_provider.dart';

class QRCanvasScreen extends StatefulWidget {
  const QRCanvasScreen({super.key});

  @override
  State<QRCanvasScreen> createState() => _QRCanvasScreenState();
}

class _QRCanvasScreenState extends State<QRCanvasScreen> {
  Color _bgColor = Colors.white;
  Color _qrColor = const Color(0xFF1B2838);
  Color _textColor = const Color(0xFF1B2838);
  final String _qrData = 'https://shubhchintak.app/qr/preview';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qrProvider = context.watch<QRProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Canvas', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/payment'),
            icon: const Icon(Icons.check_rounded, color: AppColors.accent),
            label: Text('Done', style: GoogleFonts.poppins(color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ),
              child: Center(
                child: FadeIn(
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand header
                        Text('SHUBHCHINTAK',
                            style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: _textColor, letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text(qrProvider.selectedTemplate ?? qrProvider.customPurpose ?? 'Safety QR',
                            style: GoogleFonts.poppins(fontSize: 11, color: _textColor.withOpacity(0.6))),
                        const SizedBox(height: 16),
                        // QR Code
                      QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 180,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.circle,       // ← Gives rounded eyes (closest to what you probably want)
                        color: _qrColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,  // This one is valid
                        color: _qrColor,
                      ),
                      backgroundColor: _bgColor,
                    ),
                        const SizedBox(height: 16),
                        // Instructions
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _qrColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Scan to contact owner anonymously',
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: _textColor),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 8),
                        Text('\u2122 SHUBHCHINTAK',
                            style: GoogleFonts.poppins(fontSize: 8, color: _textColor.withOpacity(0.4))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Customization panel
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Customize', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    // Background color
                    _colorSection('Background Color', [
                      Colors.white, const Color(0xFFF0F0F0), const Color(0xFFFFF3E0),
                      const Color(0xFFE3F2FD), const Color(0xFFE8F5E9), const Color(0xFFFCE4EC),
                      const Color(0xFF1B2838), Colors.black,
                    ], _bgColor, (c) => setState(() => _bgColor = c)),
                    const SizedBox(height: 16),
                    // QR Code color
                    _colorSection('QR Code Color', [
                      const Color(0xFF1B2838), Colors.black, const Color(0xFFFF6B35),
                      const Color(0xFF3498DB), const Color(0xFF2ECC71), const Color(0xFF9B59B6),
                      const Color(0xFFE74C3C), const Color(0xFF1ABC9C),
                    ], _qrColor, (c) => setState(() => _qrColor = c)),
                    const SizedBox(height: 16),
                    // Text color
                    _colorSection('Text Color', [
                      const Color(0xFF1B2838), Colors.black, Colors.white,
                      const Color(0xFF6B7B8D), const Color(0xFFFF6B35), const Color(0xFF3498DB),
                    ], _textColor, (c) => setState(() => _textColor = c)),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Download as PDF logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PDF download will be available after payment')),
                              );
                            },
                            icon: const Icon(Icons.download_rounded, size: 20),
                            label: Text('Download PDF', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/payment'),
                            icon: const Icon(Icons.local_shipping_rounded, size: 20),
                            label: Text('Order Sticker', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorSection(String title, List<Color> colors, Color selected, ValueChanged<Color> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors.map((c) {
            final isSelected = c.value == selected.value;
            return GestureDetector(
              onTap: () => onSelect(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? AppColors.accent : Colors.grey[300]!, width: isSelected ? 3 : 1),
                  boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 8)] : [],
                ),
                child: isSelected ? const Icon(Icons.check, size: 18, color: AppColors.accent) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}