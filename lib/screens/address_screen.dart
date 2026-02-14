import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../providers/qr_provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  int _selectedAddressIndex = -1;
  bool _showAddForm = false;

  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _pincodeC = TextEditingController();
  final _cityC = TextEditingController();
  final _stateC = TextEditingController();
  final _line1C = TextEditingController();
  final _line2C = TextEditingController();
  final _landmarkC = TextEditingController();
  bool _isDefault = true;
  bool _isSaving = false;
  bool _isLocating = false;

  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => context.read<QRProvider>().loadAddresses()); }

  @override
  void dispose() { _nameC.dispose(); _phoneC.dispose(); _pincodeC.dispose(); _cityC.dispose(); _stateC.dispose(); _line1C.dispose(); _line2C.dispose(); _landmarkC.dispose(); super.dispose(); }

  Future<void> _useCurrentLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied'))); return; }
    setState(() => _isLocating = true);
    // Simulate geocoding — in production use geolocator + geocoding package
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _isLocating = false; _line1C.text = 'Current Location (auto-detected)'; _cityC.text = 'Mumbai'; _stateC.text = 'Maharashtra'; _pincodeC.text = '400001'; });
  }

  Future<void> _saveAddress() async {
    if (_nameC.text.isEmpty || _phoneC.text.isEmpty || _pincodeC.text.isEmpty || _cityC.text.isEmpty || _stateC.text.isEmpty || _line1C.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields'))); return;
    }
    setState(() => _isSaving = true);
    final addr = { 'id': 'local_addr_${DateTime.now().millisecondsSinceEpoch}', 'fullName': _nameC.text, 'phone': _phoneC.text, 'pincode': _pincodeC.text,
      'city': _cityC.text, 'state': _stateC.text, 'addressLine1': _line1C.text, 'addressLine2': _line2C.text, 'landmark': _landmarkC.text, 'isDefault': _isDefault };
    await context.read<QRProvider>().saveAddress(addr);
    setState(() { _isSaving = false; _showAddForm = false; _nameC.clear(); _phoneC.clear(); _pincodeC.clear(); _cityC.clear(); _stateC.clear(); _line1C.clear(); _line2C.clear(); _landmarkC.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qr = context.watch<QRProvider>();
    final addresses = qr.addresses;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Auto-select default address
    if (_selectedAddressIndex < 0 && addresses.isNotEmpty) {
      final defIdx = addresses.indexWhere((a) => a['isDefault'] == true);
      _selectedAddressIndex = defIdx >= 0 ? defIdx : 0;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Delivery Address', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
          leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FadeInDown(child: Text('Where should we deliver?', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700))),
          const SizedBox(height: 20),

          // Saved addresses
          if (addresses.isNotEmpty && !_showAddForm) ...[
            ...List.generate(addresses.length, (i) {
              final a = addresses[i]; final sel = _selectedAddressIndex == i;
              return FadeInUp(delay: Duration(milliseconds: 60 * i), child: GestureDetector(
                onTap: () => setState(() => _selectedAddressIndex = i),
                child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: sel ? AppColors.accent : (isDark ? AppColors.darkDivider : AppColors.lightDivider), width: sel ? 2 : 1)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 24, height: 24, margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sel ? AppColors.accent : Colors.grey, width: 2)),
                          child: sel ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent))) : null),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(a['fullName'] ?? '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                          if (a['isDefault'] == true) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text('DEFAULT', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accent)))],
                        ]),
                        const SizedBox(height: 4),
                        Text('${a['addressLine1'] ?? ''}${a['addressLine2'] != null && (a['addressLine2'] as String).isNotEmpty ? ', ${a['addressLine2']}' : ''}',
                            style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        Text('${a['city'] ?? ''}, ${a['state'] ?? ''} - ${a['pincode'] ?? ''}', style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        Text(a['phone'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ])),
                    ])),
              ));
            }),
            const SizedBox(height: 8),
          ],

          // Add new address button
          if (!_showAddForm)
            FadeInUp(delay: const Duration(milliseconds: 300), child: SizedBox(width: double.infinity, height: 52,
                child: OutlinedButton.icon(onPressed: () => setState(() => _showAddForm = true),
                    icon: const Icon(Icons.add_rounded, size: 20), label: Text('Add New Address', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600))))),

          // Add address form
          if (_showAddForm) ...[
            FadeInUp(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('New Address', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _showAddForm = false)),
                ]),
                const SizedBox(height: 12),
                // Use current location
                SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
                  onPressed: _isLocating ? null : _useCurrentLocation,
                  icon: _isLocating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location_rounded, size: 20),
                  label: Text(_isLocating ? 'Detecting...' : 'Use Current Location', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.info)),
                )),
                const SizedBox(height: 16),
                _field('Full Name *', _nameC, Icons.person_outline_rounded),
                _field('Phone Number *', _phoneC, Icons.phone_outlined, type: TextInputType.phone),
                Row(children: [
                  Expanded(child: _field('Pincode *', _pincodeC, Icons.pin_drop_outlined, type: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('City *', _cityC, Icons.location_city_rounded)),
                ]),
                _field('State *', _stateC, Icons.map_outlined),
                _field('Address Line 1 *', _line1C, Icons.home_outlined),
                _field('Address Line 2', _line2C, Icons.apartment_rounded),
                _field('Landmark', _landmarkC, Icons.place_outlined),
                const SizedBox(height: 8),
                Row(children: [
                  SizedBox(width: 24, height: 24, child: Checkbox(value: _isDefault, onChanged: (v) => setState(() => _isDefault = v ?? true), activeColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(width: 10),
                  Text('Set as default address', style: GoogleFonts.poppins(fontSize: 13)),
                ]),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _isSaving ? null : _saveAddress,
                    child: _isSaving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Save Address', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)))),
              ]))),
          ],
        ]))),

        // Continue button
        if (!_showAddForm && _selectedAddressIndex >= 0 && addresses.isNotEmpty)
          Container(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  border: Border(top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider))),
              child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
                onPressed: () {
                  final selectedAddr = addresses[_selectedAddressIndex];
                  final orderArgs = {...(args ?? {}), 'address': selectedAddr};
                  Navigator.pushNamed(context, '/sticker-payment', arguments: orderArgs);
                },
                child: Text('Continue to Payment', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ))),
      ]),
    );
  }

  Widget _field(String hint, TextEditingController c, IconData icon, {TextInputType? type}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: c, keyboardType: type,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))));
  }
}