import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _locationSharing = false;
  bool _chatHistory = true;
  bool _callRecording = false;
  bool _anonymousMode = true;
  bool _twoFactor = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy & Security', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy shield banner
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1B3A4B), Color(0xFF1B2838)]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.success.withOpacity(0.2)),
                      child: const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Privacy is Protected', style: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('SHUBHCHINTAK never shares your personal contact details with strangers.',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Privacy Settings
            FadeInDown(delay: const Duration(milliseconds: 100), child: Text('Privacy', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700))),
            const SizedBox(height: 16),

            FadeInUp(delay: const Duration(milliseconds: 150), child: _toggle(isDark, 'Anonymous Mode', 'Your identity is hidden from strangers by default', Icons.visibility_off_rounded, AppColors.accent, _anonymousMode, (v) => setState(() => _anonymousMode = v))),
            FadeInUp(delay: const Duration(milliseconds: 200), child: _toggle(isDark, 'Location Sharing', 'Allow temporary location sharing in chat', Icons.location_on_outlined, AppColors.info, _locationSharing, (v) => setState(() => _locationSharing = v))),
            FadeInUp(delay: const Duration(milliseconds: 250), child: _toggle(isDark, 'Save Chat History', 'Keep chat messages after session ends', Icons.history_rounded, AppColors.warning, _chatHistory, (v) => setState(() => _chatHistory = v))),
            FadeInUp(delay: const Duration(milliseconds: 300), child: _toggle(isDark, 'Call Recording', 'Record calls for safety (notifies both parties)', Icons.fiber_manual_record_rounded, AppColors.danger, _callRecording, (v) => setState(() => _callRecording = v))),

            const SizedBox(height: 28),

            // Security
            FadeInDown(delay: const Duration(milliseconds: 350), child: Text('Security', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700))),
            const SizedBox(height: 16),

            FadeInUp(delay: const Duration(milliseconds: 400), child: _toggle(isDark, 'Two-Factor Authentication', 'Add extra security to your account', Icons.security_rounded, AppColors.success, _twoFactor, (v) => setState(() => _twoFactor = v))),
            const SizedBox(height: 16),

            // Action buttons
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _actionTile(isDark, 'Change Password', 'Update your account password', Icons.lock_outline_rounded, () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change password feature coming soon')));
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _toggle(bool isDark, String title, String sub, IconData icon, Color color, bool val, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
      ),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color.withOpacity(0.1)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(sub, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
          ])),
          Switch(value: val, onChanged: onChanged, activeColor: AppColors.accent),
        ],
      ),
    );
  }

  Widget _actionTile(bool isDark, String title, String sub, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.accent.withOpacity(0.08)), child: Icon(icon, color: AppColors.accent, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(sub, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}