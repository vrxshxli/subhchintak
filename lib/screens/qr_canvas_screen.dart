import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/qr_provider.dart';

class QRCanvasScreen extends StatefulWidget {
  const QRCanvasScreen({super.key});

  @override
  State<QRCanvasScreen> createState() => _QRCanvasScreenState();
}

class _QRCanvasScreenState extends State<QRCanvasScreen> {
  // ==================== STATE ====================
  final String _qrData = 'https://shubhchintak.app/qr/preview';
  final ImagePicker _picker = ImagePicker();

  // Colors
  Color _bgColor = Colors.white;
  Color _textColor = const Color(0xFF1B2838);

  // Gradient colors for QR (multi-stop)
  List<Color> _gradientColors = [const Color(0xFF1B2838)];
  bool _useGradient = false;

  // Custom text
  final TextEditingController _customTextCtrl = TextEditingController();
  String _customText = '';

  // Background image (from gallery)
  File? _bgImageFile;
  double _bgOpacity = 0.12;
  double _bgRotation = -12.0; // degrees

  // Logo (from gallery)
  File? _logoFile;

  // Active tab
  int _tab = 0;

  @override
  void dispose() {
    _customTextCtrl.dispose();
    super.dispose();
  }

  // ==================== IMAGE PICKERS ====================
  Future<void> _pickBgImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _bgImageFile = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 90,
      );
      if (image != null) {
        setState(() => _logoFile = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  // ==================== GRADIENT HELPERS ====================
  void _addGradientColor(Color c) {
    if (_gradientColors.length >= 5) return;
    setState(() {
      _gradientColors = [..._gradientColors, c];
      _useGradient = _gradientColors.length > 1;
    });
  }

  void _removeGradientColor(int index) {
    if (_gradientColors.length <= 1) return;
    setState(() {
      _gradientColors = List.from(_gradientColors)..removeAt(index);
      _useGradient = _gradientColors.length > 1;
    });
  }

  void _updateGradientColor(int index, Color c) {
    setState(() {
      _gradientColors = List.from(_gradientColors)..[index] = c;
    });
  }

  Color get _primaryQrColor => _gradientColors.first;

  // ==================== QR PREVIEW ====================
  Widget _buildQRPreview() {
    return Container(
      width: 300,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          // ===== Background image (slanted, asymmetric) =====
          if (_bgImageFile != null)
            Positioned.fill(
              child: Transform.rotate(
                angle: _bgRotation * pi / 180,
                child: Transform.scale(
                  scale: 1.4, // slightly larger to fill corners when rotated
                  child: Opacity(
                    opacity: _bgOpacity,
                    child: Image.file(
                      _bgImageFile!,
                      fit: BoxFit.cover,
                      color: _bgColor.computeLuminance() > 0.5
                          ? Colors.black.withOpacity(0.05)
                          : Colors.white.withOpacity(0.05),
                      colorBlendMode: BlendMode.overlay,
                    ),
                  ),
                ),
              ),
            ),

          // ===== Main content =====
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand
                Text('SHUBHCHINTAK',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 15, fontWeight: FontWeight.w800, color: _textColor, letterSpacing: 2)),
                const SizedBox(height: 14),

                // QR Code with gradient overlay + logo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // QR
                    QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 180,
                      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle, color: _primaryQrColor),
                      dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: _primaryQrColor),
                      backgroundColor: Colors.transparent,
                    ),

                    // Gradient overlay (doesn't block scan — semi-transparent)
                    if (_useGradient && _gradientColors.length >= 2)
                      IgnorePointer(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _gradientColors
                                  .map((c) => c.withOpacity(0.25))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),

                    // Logo center
                    if (_logoFile != null)
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(_logoFile!, fit: BoxFit.contain),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bold default text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _primaryQrColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'SCAN TO CONTACT OWNER',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _textColor,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Custom user text
                if (_customText.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _customText,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: _textColor.withOpacity(0.65)),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),
                Text('\u2122 SHUBHCHINTAK',
                    style: GoogleFonts.poppins(fontSize: 8, color: _textColor.withOpacity(0.25))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = ['Colors', 'Text', 'Image', 'Logo'];
    final tabIcons = [Icons.palette_rounded, Icons.text_fields_rounded, Icons.image_rounded, Icons.add_photo_alternate_rounded];

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
          // ===== Preview =====
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: FadeIn(child: _buildQRPreview()),
                ),
              ),
            ),
          ),

          // ===== Tab bar =====
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final active = _tab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: active ? Border.all(color: AppColors.accent.withOpacity(0.3)) : null,
                      ),
                      child: Column(children: [
                        Icon(tabIcons[i], size: 20, color: active ? AppColors.accent : Colors.grey),
                        const SizedBox(height: 2),
                        Text(tabs[i], style: GoogleFonts.poppins(fontSize: 10,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? AppColors.accent : Colors.grey)),
                      ]),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),

          // ===== Panel =====
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: SingleChildScrollView(
                child: [_colorsTab, _textTab, _imageTab, _logoTab][_tab](isDark),
              ),
            ),
          ),
        ],
      ),

      // ===== Bottom buttons =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        child: Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF download available after payment'))),
            icon: const Icon(Icons.download_rounded, size: 20),
            label: Text('Download PDF', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/payment'),
            icon: const Icon(Icons.local_shipping_rounded, size: 20),
            label: Text('Order Sticker', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
          )),
        ]),
      ),
    );
  }

  // ==================== TAB: COLORS ====================
  Widget _colorsTab(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _colorRow('Background', [
        Colors.white, const Color(0xFFF0F0F0), const Color(0xFFFFF3E0), const Color(0xFFE3F2FD),
        const Color(0xFFE8F5E9), const Color(0xFFFCE4EC), const Color(0xFF1B2838), Colors.black,
      ], _bgColor, (c) => setState(() => _bgColor = c)),
      const SizedBox(height: 14),

      // QR gradient section
      Row(children: [
        Text('QR Color', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('Gradient', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        const SizedBox(width: 4),
        SizedBox(height: 26, child: Switch(
          value: _useGradient, activeColor: AppColors.accent,
          onChanged: (v) {
            setState(() {
              _useGradient = v;
              if (v && _gradientColors.length < 2) {
                _gradientColors = [..._gradientColors, const Color(0xFFFF6B35)];
              }
            });
          },
        )),
      ]),
      const SizedBox(height: 8),

      // Gradient stops
      ...List.generate(_gradientColors.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Text('${_useGradient ? "Stop ${i + 1}" : "Color"}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            const SizedBox(width: 10),
            Expanded(child: _colorPalette([
              const Color(0xFF1B2838), Colors.black, const Color(0xFFFF6B35), const Color(0xFF3498DB),
              const Color(0xFF2ECC71), const Color(0xFF9B59B6), const Color(0xFFE74C3C), const Color(0xFF1ABC9C),
              const Color(0xFFF39C12), const Color(0xFF2980B9),
            ], _gradientColors[i], (c) => _updateGradientColor(i, c), small: true)),
            if (_useGradient && _gradientColors.length > 1)
              GestureDetector(
                onTap: () => _removeGradientColor(i),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.remove_circle_rounded, size: 20, color: AppColors.danger.withOpacity(0.7)),
                ),
              ),
          ]),
        );
      }),

      if (_useGradient && _gradientColors.length < 5)
        GestureDetector(
          onTap: () => _addGradientColor(const Color(0xFF2ECC71)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.accent.withOpacity(0.08)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: 4),
              Text('Add Color Stop', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
            ]),
          ),
        ),

      // Gradient preview
      if (_useGradient && _gradientColors.length >= 2) ...[
        const SizedBox(height: 10),
        Container(height: 20, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: _gradientColors))),
      ],
      const SizedBox(height: 14),

      _colorRow('Text', [
        const Color(0xFF1B2838), Colors.black, Colors.white,
        const Color(0xFF6B7B8D), const Color(0xFFFF6B35), const Color(0xFF3498DB),
      ], _textColor, (c) => setState(() => _textColor = c)),
    ]);
  }

  // ==================== TAB: TEXT ====================
  Widget _textTab(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Custom Text', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('Add your own message below the QR code', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 12),
      TextField(
        controller: _customTextCtrl,
        maxLength: 60,
        maxLines: 2,
        decoration: InputDecoration(
          hintText: 'e.g., If found, please scan this QR...',
          prefixIcon: const Icon(Icons.edit_rounded),
          suffixIcon: _customText.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear_rounded, size: 20), onPressed: () { _customTextCtrl.clear(); setState(() => _customText = ''); })
              : null,
        ),
        onChanged: (v) => setState(() => _customText = v),
      ),
      const SizedBox(height: 14),
      Text('Quick Add', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _quickText('If found, please scan'),
        _quickText('Return to owner'),
        _quickText('Emergency - Scan for help'),
        _quickText('Contact me anonymously'),
        _quickText('Lost? Scan this QR'),
        _quickText('Help return this item'),
      ]),
    ]);
  }

  Widget _quickText(String t) {
    final active = _customText == t;
    return GestureDetector(
      onTap: () { _customTextCtrl.text = t; setState(() => _customText = t); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.accent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.accent : AppColors.accent.withOpacity(0.2)),
        ),
        child: Text(t, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.accent)),
      ),
    );
  }

  // ==================== TAB: IMAGE ====================
  Widget _imageTab(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Background Image', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('Upload from gallery — rendered behind QR, won\'t affect scanability', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
        onPressed: _pickBgImage,
        icon: Icon(_bgImageFile != null ? Icons.swap_horiz_rounded : Icons.photo_library_rounded, size: 20),
        label: Text(_bgImageFile != null ? 'Change Image' : 'Pick from Gallery', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      )),
      if (_bgImageFile != null) ...[
        const SizedBox(height: 14),
        // Thumbnail
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(_bgImageFile!, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Image loaded', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('Adjust opacity and rotation below', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
          ])),
        ]),
        const SizedBox(height: 12),
        // Opacity
        Row(children: [
          Text('Opacity', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          Expanded(child: Slider(value: _bgOpacity, min: 0.03, max: 0.35, activeColor: AppColors.accent,
              onChanged: (v) => setState(() => _bgOpacity = v))),
          Text('${(_bgOpacity * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ]),
        // Rotation
        Row(children: [
          Text('Rotation', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          Expanded(child: Slider(value: _bgRotation, min: -45, max: 45, activeColor: AppColors.accent,
              onChanged: (v) => setState(() => _bgRotation = v))),
          Text('${_bgRotation.toInt()}°', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ]),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => setState(() => _bgImageFile = null),
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
          label: Text('Remove Image', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.danger)),
        ),
      ],
    ]);
  }

  // ==================== TAB: LOGO ====================
  Widget _logoTab(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Center Logo', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('Upload your logo — placed at the center of the QR code', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
        onPressed: _pickLogo,
        icon: Icon(_logoFile != null ? Icons.swap_horiz_rounded : Icons.photo_library_rounded, size: 20),
        label: Text(_logoFile != null ? 'Change Logo' : 'Pick Logo from Gallery', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      )),
      if (_logoFile != null) ...[
        const SizedBox(height: 14),
        Row(children: [
          Container(
            width: 56, height: 56,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_logoFile!, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Logo loaded', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('Shown at QR center with safe padding', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
          ])),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('Keep logo small and simple for best QR scanability.',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.info))),
          ]),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => setState(() => _logoFile = null),
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
          label: Text('Remove Logo', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.danger)),
        ),
      ] else ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('Upload your brand logo, company symbol, or any image to personalize your QR.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))),
          ]),
        ),
      ],
    ]);
  }

  // ==================== SHARED WIDGETS ====================
  Widget _colorRow(String label, List<Color> colors, Color selected, ValueChanged<Color> onSelect) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      _colorPalette(colors, selected, onSelect),
    ]);
  }

  Widget _colorPalette(List<Color> colors, Color selected, ValueChanged<Color> onSelect, {bool small = false}) {
    final size = small ? 28.0 : 34.0;
    return Wrap(
      spacing: small ? 6 : 10,
      runSpacing: small ? 6 : 10,
      children: colors.map((c) {
        final sel = c.value == selected.value;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size, height: size,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(color: sel ? AppColors.accent : Colors.grey.shade300, width: sel ? 3 : 1),
              boxShadow: sel ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 6)] : [],
            ),
            child: sel ? Icon(Icons.check, size: small ? 14 : 16, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }
}

