import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../providers/qr_provider.dart';

class DesignQRTemplatesScreen extends StatefulWidget {
  const DesignQRTemplatesScreen({super.key});

  @override
  State<DesignQRTemplatesScreen> createState() => _DesignQRTemplatesScreenState();
}

class _DesignQRTemplatesScreenState extends State<DesignQRTemplatesScreen> {
  int _selectedIndex = -1;
  final _customPurposeController = TextEditingController();

  final _templates = [
    {'icon': Icons.directions_car_rounded, 'title': 'Four-Wheeler', 'subtitle': 'Car, SUV, Truck', 'color': const Color(0xFF3498DB)},
    {'icon': Icons.two_wheeler_rounded, 'title': 'Two-Wheeler', 'subtitle': 'Bike, Scooter', 'color': const Color(0xFFFF6B35)},
    {'icon': Icons.backpack_rounded, 'title': 'Bag', 'subtitle': 'Backpack, Purse, Luggage', 'color': const Color(0xFF9B59B6)},
    {'icon': Icons.key_rounded, 'title': 'Key', 'subtitle': 'House, Car, Office Keys', 'color': const Color(0xFFF39C12)},
    {'icon': Icons.child_care_rounded, 'title': 'Child Safety', 'subtitle': 'Bracelet, Badge', 'color': const Color(0xFFE74C3C)},
    {'icon': Icons.elderly_rounded, 'title': 'Elderly Care', 'subtitle': 'ID Band, Pendant', 'color': const Color(0xFF2ECC71)},
    {'icon': Icons.pets_rounded, 'title': 'Pet Tag', 'subtitle': 'Collar, Harness', 'color': const Color(0xFF1ABC9C)},
    {'icon': Icons.add_circle_outline_rounded, 'title': 'Custom', 'subtitle': 'Define your own purpose', 'color': const Color(0xFF95A5A6)},
  ];

  @override
  void dispose() {
    _customPurposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Templates', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Text('What is this QR for?',
                        style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text('Select the purpose to get the best template',
                        style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: _templates.length,
                      itemBuilder: (context, index) {
                        final t = _templates[index];
                        final isSelected = _selectedIndex == index;
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedIndex = index);
                              if (t['title'] == 'Custom') {
                                _showCustomPurposeDialog();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? (t['color'] as Color) : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: (t['color'] as Color).withOpacity(0.15), blurRadius: 16)]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: (t['color'] as Color).withOpacity(0.1),
                                    ),
                                    child: Icon(t['icon'] as IconData, color: t['color'] as Color, size: 24),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(t['title'] as String,
                                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 2),
                                  Text(t['subtitle'] as String,
                                      style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedIndex >= 0
                    ? () {
                        final qrProvider = context.read<QRProvider>();
                        final template = _templates[_selectedIndex];
                        qrProvider.setTemplate(template['title'] as String);
                        Navigator.pushNamed(context, '/qr-canvas');
                      }
                    : null,
                child: Text('Continue to Canvas', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomPurposeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Custom Purpose', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: _customPurposeController,
          decoration: const InputDecoration(hintText: 'e.g., Laptop, Camera, Wallet...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_customPurposeController.text.isNotEmpty) {
                context.read<QRProvider>().setCustomPurpose(_customPurposeController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Set Purpose'),
          ),
        ],
      ),
    );
  }
}