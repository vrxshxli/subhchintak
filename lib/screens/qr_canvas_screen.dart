import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _qrKey = GlobalKey();
  Color _bgColor = Colors.white;
  Color _textColor = const Color(0xFF1B2838);
  List<Color> _gradientColors = [const Color(0xFF1B2838)];
  bool _useGradient = false;
  final TextEditingController _customTextCtrl = TextEditingController();
  String _customText = '';
  File? _bgImageFile; double _bgOpacity = 0.12; double _bgRotation = -12.0;
  File? _logoFile;
  int _tab = 0;
  bool _isSaving = false;

  Color get _primaryQrColor => _gradientColors.first;
  String get _qrData { final qr = context.read<QRProvider>(); return qr.qrDataUrl.isNotEmpty ? qr.qrDataUrl : 'https://shubhchintak.app/qr/preview'; }

  @override
  void dispose() { _customTextCtrl.dispose(); super.dispose(); }

  Future<void> _captureAndSave() async {
    setState(() => _isSaving = true);
    final qrProvider = context.read<QRProvider>();

    // Capture thumbnail
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) qrProvider.setPendingThumbnail(byteData.buffer.asUint8List());
      }
    } catch (_) {}

    qrProvider.updateCustomization({
      'bgColor': _bgColor.value.toString(), 'textColor': _textColor.value.toString(),
      'gradientColors': _gradientColors.map((c) => c.value.toString()).toList(),
      'useGradient': _useGradient, 'customText': _customText, 'bgOpacity': _bgOpacity, 'bgRotation': _bgRotation,
    });

    // If first time (no subscription) → go to payment
    if (!qrProvider.hasActiveSubscription) {
      setState(() => _isSaving = false);
      if (mounted) Navigator.pushNamed(context, '/payment');
      return;
    }

    // Already subscribed → save directly to My Tags
    final tag = await qrProvider.saveTagDesign();
    setState(() => _isSaving = false);
    if (tag != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: const [Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), SizedBox(width: 10), Text('Sticker saved to My Tags!')]),
        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      qrProvider.reset();
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false);
    }
  }

  Future<void> _pickBgImage() async { try { final f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80); if (f != null) setState(() => _bgImageFile = File(f.path)); } catch (_) {} }
  Future<void> _pickLogo() async { try { final f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 200, maxHeight: 200, imageQuality: 90); if (f != null) setState(() => _logoFile = File(f.path)); } catch (_) {} }
  void _addGC(Color c) { if (_gradientColors.length >= 5) return; setState(() { _gradientColors = [..._gradientColors, c]; _useGradient = _gradientColors.length > 1; }); }
  void _removeGC(int i) { if (_gradientColors.length <= 1) return; setState(() { _gradientColors = List.from(_gradientColors)..removeAt(i); _useGradient = _gradientColors.length > 1; }); }
  void _updateGC(int i, Color c) { setState(() { _gradientColors = List.from(_gradientColors)..[i] = c; }); }

  Widget _buildQRPreview() {
    return RepaintBoundary(key: _qrKey, child: Container(width: 300, clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 10))]),
      child: Stack(children: [
        if (_bgImageFile != null) Positioned.fill(child: Transform.rotate(angle: _bgRotation * pi / 180,
            child: Transform.scale(scale: 1.4, child: Opacity(opacity: _bgOpacity, child: Image.file(_bgImageFile!, fit: BoxFit.cover))))),
        Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('SHUBHCHINTAK', style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: _textColor, letterSpacing: 2)),
          const SizedBox(height: 14),
          Stack(alignment: Alignment.center, children: [
            QrImageView(data: _qrData, version: QrVersions.auto, size: 180, eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle, color: _primaryQrColor),
                dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: _primaryQrColor), backgroundColor: Colors.transparent),
            if (_useGradient && _gradientColors.length >= 2) IgnorePointer(child: Container(width: 180, height: 180,
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: _gradientColors.map((c) => c.withOpacity(0.25)).toList())))),
            if (_logoFile != null) Container(width: 44, height: 44, padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)]),
                child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(_logoFile!, fit: BoxFit.contain))),
          ]),
          const SizedBox(height: 14),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: _primaryQrColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: Text('SCAN TO CONTACT OWNER', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w800, color: _textColor, letterSpacing: 1.5), textAlign: TextAlign.center)),
          if (_customText.trim().isNotEmpty) ...[const SizedBox(height: 8), Text(_customText, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: _textColor.withOpacity(0.65)), textAlign: TextAlign.center, maxLines: 2)],
          const SizedBox(height: 8),
          Text('\u2122 SHUBHCHINTAK', style: GoogleFonts.poppins(fontSize: 8, color: _textColor.withOpacity(0.25))),
        ])),
      ])));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qr = context.watch<QRProvider>();
    final isFirstTime = !qr.hasActiveSubscription;
    final tabs = ['Colors', 'Text', 'Image', 'Logo'];
    final tabIcons = [Icons.palette_rounded, Icons.text_fields_rounded, Icons.image_rounded, Icons.add_photo_alternate_rounded];

    return Scaffold(
      appBar: AppBar(title: Text('QR Canvas', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Expanded(flex: 5, child: Container(width: double.infinity, margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            decoration: BoxDecoration(color: isDark ? AppColors.darkCard : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
            child: Center(child: SingleChildScrollView(child: FadeIn(child: _buildQRPreview()))))),
        Container(margin: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: List.generate(tabs.length, (i) {
          final a = _tab == i;
          return Expanded(child: GestureDetector(onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 8), margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(color: a ? AppColors.accent.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12),
                      border: a ? Border.all(color: AppColors.accent.withOpacity(0.3)) : null),
                  child: Column(children: [Icon(tabIcons[i], size: 20, color: a ? AppColors.accent : Colors.grey), const SizedBox(height: 2),
                    Text(tabs[i], style: GoogleFonts.poppins(fontSize: 10, fontWeight: a ? FontWeight.w700 : FontWeight.w500, color: a ? AppColors.accent : Colors.grey))]))));
        }))),
        const SizedBox(height: 6),
        Expanded(flex: 4, child: Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))]),
            child: SingleChildScrollView(child: [_colorsTab, _textTab, _imageTab, _logoTab][_tab](isDark)))),
      ]),
      bottomNavigationBar: Container(padding: const EdgeInsets.fromLTRB(16, 6, 16, 22), color: isDark ? AppColors.darkCard : AppColors.lightCard,
          child: SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _captureAndSave,
            icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(isFirstTime ? Icons.payment_rounded : Icons.save_rounded, size: 20),
            label: Text(isFirstTime ? 'Continue to Payment' : 'Save to My Tags', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
          ))),
    );
  }

  // ─── TABS ────────────────────────────────────────────────────
  Widget _colorsTab(bool isDark) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _colorRow('Background', [Colors.white,const Color(0xFFF0F0F0),const Color(0xFFFFF3E0),const Color(0xFFE3F2FD),const Color(0xFFE8F5E9),const Color(0xFFFCE4EC),const Color(0xFF1B2838),Colors.black], _bgColor, (c) => setState(() => _bgColor = c)),
    const SizedBox(height: 14),
    Row(children: [Text('QR Color', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),const Spacer(),Text('Gradient', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),const SizedBox(width: 4),
      SizedBox(height: 26, child: Switch(value: _useGradient, activeColor: AppColors.accent, onChanged: (v) { setState(() { _useGradient = v; if (v && _gradientColors.length < 2) _gradientColors = [..._gradientColors, const Color(0xFFFF6B35)]; }); }))]),
    const SizedBox(height: 8),
    ...List.generate(_gradientColors.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      Text(_useGradient ? "Stop ${i+1}" : "Color", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),const SizedBox(width: 10),
      Expanded(child: _colorPalette([const Color(0xFF1B2838),Colors.black,const Color(0xFFFF6B35),const Color(0xFF3498DB),const Color(0xFF2ECC71),const Color(0xFF9B59B6),const Color(0xFFE74C3C),const Color(0xFF1ABC9C),const Color(0xFFF39C12),const Color(0xFF2980B9)], _gradientColors[i], (c) => _updateGC(i, c), small: true)),
      if (_useGradient && _gradientColors.length > 1) GestureDetector(onTap: () => _removeGC(i), child: Padding(padding: const EdgeInsets.only(left: 6), child: Icon(Icons.remove_circle_rounded, size: 20, color: AppColors.danger.withOpacity(0.7)))),
    ]))),
    if (_useGradient && _gradientColors.length < 5) GestureDetector(onTap: () => _addGC(const Color(0xFF2ECC71)),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.accent.withOpacity(0.08)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.add_rounded, size: 16, color: AppColors.accent),const SizedBox(width: 4),Text('Add Stop', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent))]))),
    if (_useGradient && _gradientColors.length >= 2) ...[const SizedBox(height: 10), Container(height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(colors: _gradientColors)))],
    const SizedBox(height: 14),
    _colorRow('Text', [const Color(0xFF1B2838),Colors.black,Colors.white,const Color(0xFF6B7B8D),const Color(0xFFFF6B35),const Color(0xFF3498DB)], _textColor, (c) => setState(() => _textColor = c)),
  ]);

  Widget _textTab(bool isDark) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Custom Text', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700)),const SizedBox(height: 4),
    Text('Add your own message below the QR', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),const SizedBox(height: 12),
    TextField(controller: _customTextCtrl, maxLength: 60, maxLines: 2, decoration: InputDecoration(hintText: 'e.g., If found, please scan...', prefixIcon: const Icon(Icons.edit_rounded),
        suffixIcon: _customText.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded, size: 20), onPressed: () { _customTextCtrl.clear(); setState(() => _customText = ''); }) : null), onChanged: (v) => setState(() => _customText = v)),
    const SizedBox(height: 14),Text('Quick Add', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8, children: ['If found, please scan','Return to owner','Emergency - Scan for help','Contact me anonymously','Lost? Scan this QR'].map((t) { final a = _customText == t;
      return GestureDetector(onTap: () { _customTextCtrl.text = t; setState(() => _customText = t); },
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: a ? AppColors.accent : AppColors.accent.withOpacity(0.06), borderRadius: BorderRadius.circular(20), border: Border.all(color: a ? AppColors.accent : AppColors.accent.withOpacity(0.2))),
              child: Text(t, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: a ? Colors.white : AppColors.accent)))); }).toList()),
  ]);

  Widget _imageTab(bool isDark) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Background Image', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700)),const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(onPressed: _pickBgImage, icon: Icon(_bgImageFile != null ? Icons.swap_horiz_rounded : Icons.photo_library_rounded, size: 20), label: Text(_bgImageFile != null ? 'Change Image' : 'Pick from Gallery', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)))),
    if (_bgImageFile != null) ...[const SizedBox(height: 12),
      Row(children: [Text('Opacity', style: GoogleFonts.poppins(fontSize: 13)),Expanded(child: Slider(value: _bgOpacity, min: 0.03, max: 0.35, activeColor: AppColors.accent, onChanged: (v) => setState(() => _bgOpacity = v))),Text('${(_bgOpacity*100).toInt()}%', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))]),
      Row(children: [Text('Rotation', style: GoogleFonts.poppins(fontSize: 13)),Expanded(child: Slider(value: _bgRotation, min: -45, max: 45, activeColor: AppColors.accent, onChanged: (v) => setState(() => _bgRotation = v))),Text('${_bgRotation.toInt()}°', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))]),
      TextButton.icon(onPressed: () => setState(() => _bgImageFile = null), icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18), label: Text('Remove', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.danger)))],
  ]);

  Widget _logoTab(bool isDark) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Center Logo', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700)),const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(onPressed: _pickLogo, icon: Icon(_logoFile != null ? Icons.swap_horiz_rounded : Icons.photo_library_rounded, size: 20), label: Text(_logoFile != null ? 'Change Logo' : 'Pick Logo', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)))),
    if (_logoFile != null) TextButton.icon(onPressed: () => setState(() => _logoFile = null), icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18), label: Text('Remove', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.danger))),
  ]);

  Widget _colorRow(String l, List<Color> c, Color s, ValueChanged<Color> o) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),const SizedBox(height: 8),_colorPalette(c, s, o)]);
  Widget _colorPalette(List<Color> colors, Color sel, ValueChanged<Color> onSel, {bool small = false}) { final sz = small ? 28.0 : 34.0;
    return Wrap(spacing: small ? 6 : 10, runSpacing: small ? 6 : 10, children: colors.map((c) { final s = c.value == sel.value;
      return GestureDetector(onTap: () => onSel(c), child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: sz, height: sz,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: s ? AppColors.accent : Colors.grey.shade300, width: s ? 3 : 1), boxShadow: s ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 6)] : []),
          child: s ? Icon(Icons.check, size: small ? 14 : 16, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null)); }).toList()); }
}