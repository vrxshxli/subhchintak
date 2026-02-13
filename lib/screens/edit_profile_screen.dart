import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isSaving = false;
  bool _hasChanges = false;
  String? _localImagePath;
  String? _selectedAvatar;
  int _selectedAvatarIndex = -1;

  final List<Map<String, dynamic>> _avatars = [
    {'emoji': '😎', 'bg': const Color(0xFFFFE0B2), 'label': 'Cool'},
    {'emoji': '🦁', 'bg': const Color(0xFFFFF9C4), 'label': 'Lion'},
    {'emoji': '🦊', 'bg': const Color(0xFFFFCCBC), 'label': 'Fox'},
    {'emoji': '🐼', 'bg': const Color(0xFFE0E0E0), 'label': 'Panda'},
    {'emoji': '🦉', 'bg': const Color(0xFFD1C4E9), 'label': 'Owl'},
    {'emoji': '🐯', 'bg': const Color(0xFFFFE082), 'label': 'Tiger'},
    {'emoji': '🦅', 'bg': const Color(0xFFB3E5FC), 'label': 'Eagle'},
    {'emoji': '🐺', 'bg': const Color(0xFFCFD8DC), 'label': 'Wolf'},
    {'emoji': '🦋', 'bg': const Color(0xFFB2EBF2), 'label': 'Butterfly'},
    {'emoji': '🌟', 'bg': const Color(0xFFFFF176), 'label': 'Star'},
    {'emoji': '🔥', 'bg': const Color(0xFFFFAB91), 'label': 'Fire'},
    {'emoji': '💎', 'bg': const Color(0xFFB2DFDB), 'label': 'Diamond'},
    {'emoji': '🚀', 'bg': const Color(0xFFBBDEFB), 'label': 'Rocket'},
    {'emoji': '🎯', 'bg': const Color(0xFFF8BBD0), 'label': 'Target'},
    {'emoji': '🛡️', 'bg': const Color(0xFFC8E6C9), 'label': 'Shield'},
    {'emoji': '👑', 'bg': const Color(0xFFFFE57F), 'label': 'Crown'},
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user ?? {};
    _nameController = TextEditingController(text: user['name'] ?? '');
    _emailController = TextEditingController(text: user['email'] ?? '');
    _phoneController = TextEditingController(text: user['phone'] ?? '');
    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localImagePath = prefs.getString('profile_image_path');
      _selectedAvatar = prefs.getString('profile_avatar');
      _selectedAvatarIndex = prefs.getInt('profile_avatar_index') ?? -1;
      final savedName = prefs.getString('user_name');
      final savedPhone = prefs.getString('user_phone');
      if (savedName != null && savedName.isNotEmpty) _nameController.text = savedName;
      if (savedPhone != null && savedPhone.isNotEmpty) _phoneController.text = savedPhone;
      _hasChanges = false;
    });
  }

  void _onChanged() => setState(() => _hasChanges = true);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Choose Profile Picture', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _optionTile(Icons.emoji_emotions_rounded, AppColors.accent, 'Choose Creative Avatar', 'Pick from fun emoji avatars', () {
              Navigator.pop(ctx);
              _showAvatarPicker();
            }),
            const SizedBox(height: 8),
            if (_localImagePath != null || _selectedAvatarIndex >= 0)
              _optionTile(Icons.delete_outline_rounded, AppColors.danger, 'Remove Photo', 'Use default initial avatar', () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('profile_image_path');
                await prefs.remove('profile_avatar');
                await prefs.remove('profile_avatar_index');
                setState(() {
                  _localImagePath = null;
                  _selectedAvatar = null;
                  _selectedAvatarIndex = -1;
                  _hasChanges = true;
                });
                if (mounted) Navigator.pop(ctx);
              }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(IconData icon, Color color, String title, String sub, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.1)),
                child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(sub, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        int tempSelected = _selectedAvatarIndex;
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text('Choose Your Avatar', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Express yourself with a fun avatar', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 20),
                // Preview
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tempSelected >= 0 ? _avatars[tempSelected]['bg'] as Color : AppColors.accent.withOpacity(0.1),
                    boxShadow: [BoxShadow(color: (tempSelected >= 0 ? _avatars[tempSelected]['bg'] as Color : AppColors.accent).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Center(child: Text(tempSelected >= 0 ? _avatars[tempSelected]['emoji'] as String : '?', style: const TextStyle(fontSize: 44))),
                ),
                if (tempSelected >= 0) ...[
                  const SizedBox(height: 8),
                  Text(_avatars[tempSelected]['label'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent)),
                ],
                const SizedBox(height: 20),
                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12),
                    itemCount: _avatars.length,
                    itemBuilder: (ctx, index) {
                      final a = _avatars[index];
                      final isSelected = tempSelected == index;
                      return GestureDetector(
                        onTap: () => setSheetState(() => tempSelected = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: a['bg'] as Color,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: isSelected ? AppColors.accent : Colors.transparent, width: isSelected ? 3 : 0),
                            boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withOpacity(0.2), blurRadius: 12)] : [],
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(a['emoji'] as String, style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 2),
                            Text(a['label'] as String, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.black54)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                // Confirm
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: tempSelected >= 0 ? () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('profile_avatar', _avatars[tempSelected]['emoji'] as String);
                        await prefs.setInt('profile_avatar_index', tempSelected);
                        await prefs.remove('profile_image_path');
                        setState(() {
                          _selectedAvatar = _avatars[tempSelected]['emoji'] as String;
                          _selectedAvatarIndex = tempSelected;
                          _localImagePath = null;
                          _hasChanges = true;
                        });
                        if (mounted) Navigator.pop(ctx);
                      } : null,
                      child: Text('Set Avatar', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_hasChanges) return;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_phone', _phoneController.text.trim());
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      auth.user!['name'] = _nameController.text.trim();
      auth.user!['phone'] = _phoneController.text.trim();
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() { _isSaving = false; _hasChanges = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: const [Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), SizedBox(width: 10), Text('Profile updated successfully')]),
        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    }
  }

  Widget _buildAvatar(Map<String, dynamic> user) {
    if (_selectedAvatarIndex >= 0 && _selectedAvatar != null) {
      return Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: _avatars[_selectedAvatarIndex]['bg'] as Color,
          boxShadow: [BoxShadow(color: (_avatars[_selectedAvatarIndex]['bg'] as Color).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
        child: Center(child: Text(_selectedAvatar!, style: const TextStyle(fontSize: 52))));
    }
    if (_localImagePath != null && File(_localImagePath!).existsSync()) {
      return Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
          image: DecorationImage(image: FileImage(File(_localImagePath!)), fit: BoxFit.cover)));
    }
    return Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
        boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Center(child: Text((user['name'] ?? 'U')[0].toUpperCase(),
          style: GoogleFonts.spaceGrotesk(fontSize: 44, fontWeight: FontWeight.w700, color: Colors.white))));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FadeInDown(child: Center(child: Stack(children: [
              _buildAvatar(user),
              Positioned(bottom: 0, right: 0, child: GestureDetector(
                onTap: _showProfilePictureOptions,
                child: Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent,
                    border: Border.all(color: isDark ? AppColors.darkCard : Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 8)]),
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white)),
              )),
            ]))),
            const SizedBox(height: 10),
            FadeInDown(delay: const Duration(milliseconds: 50), child: TextButton.icon(
              onPressed: _showAvatarPicker,
              icon: const Icon(Icons.emoji_emotions_rounded, size: 18, color: AppColors.accent),
              label: Text('Choose Creative Avatar', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
            )),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 100), child: _buildField('Full Name', _nameController, Icons.person_outline_rounded, enabled: true)),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 200), child: _buildField('Email', _emailController, Icons.email_outlined, enabled: false, helperText: 'Email cannot be changed')),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 300), child: _buildField('Phone Number', _phoneController, Icons.phone_outlined, enabled: true, keyboardType: TextInputType.phone)),
            const SizedBox(height: 36),
            FadeInUp(delay: const Duration(milliseconds: 400), child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
              onPressed: (_hasChanges && !_isSaving) ? _saveProfile : null,
              child: _isSaving ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text('Save Changes', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            ))),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 500), child: TextButton(
              onPressed: () => showDialog(context: context, builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Delete Account?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
                content: Text('This will permanently delete your account, QR codes, and all data. This cannot be undone.', style: GoogleFonts.poppins(fontSize: 14)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), child: const Text('Delete Account')),
                ],
              )),
              child: Text('Delete Account', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.danger)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool enabled = true, String? helperText, TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
      const SizedBox(height: 8),
      TextField(controller: controller, enabled: enabled, keyboardType: keyboardType,
        decoration: InputDecoration(prefixIcon: Icon(icon), helperText: helperText, helperStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey))),
    ]);
  }
}