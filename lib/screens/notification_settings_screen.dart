import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _qrScanned = true;
  bool _callReceived = true;
  bool _missedCall = true;
  bool _emergencyEscalation = true;
  bool _chatMessages = true;
  bool _paymentUpdates = true;
  bool _appUpdates = false;
  bool _promotions = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Critical alerts section
            FadeInDown(
              child: Text('Critical Alerts', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 4),
            FadeInDown(
              delay: const Duration(milliseconds: 50),
              child: Text('These notifications are essential for your safety',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
            ),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 100), child: _buildToggle(isDark, 'QR Scanned', 'Get notified when someone scans your QR code', Icons.qr_code_scanner_rounded, AppColors.info, _qrScanned, (v) => setState(() => _qrScanned = v))),
            FadeInUp(delay: const Duration(milliseconds: 150), child: _buildToggle(isDark, 'Call Received', 'Incoming call notifications from strangers', Icons.call_received_rounded, AppColors.success, _callReceived, (v) => setState(() => _callReceived = v))),
            FadeInUp(delay: const Duration(milliseconds: 200), child: _buildToggle(isDark, 'Missed Call', 'Alert when you miss a call from a QR scan', Icons.phone_missed_rounded, AppColors.warning, _missedCall, (v) => setState(() => _missedCall = v))),
            FadeInUp(delay: const Duration(milliseconds: 250), child: _buildToggle(isDark, 'Emergency Escalation', 'When calls are escalated to emergency contacts', Icons.emergency_rounded, AppColors.danger, _emergencyEscalation, (v) => setState(() => _emergencyEscalation = v))),

            const SizedBox(height: 28),

            // General section
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: Text('General', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 350), child: _buildToggle(isDark, 'Chat Messages', 'New message notifications', Icons.chat_bubble_outline_rounded, AppColors.accent, _chatMessages, (v) => setState(() => _chatMessages = v))),
            FadeInUp(delay: const Duration(milliseconds: 400), child: _buildToggle(isDark, 'Payment Updates', 'Order and payment confirmations', Icons.payment_rounded, AppColors.info, _paymentUpdates, (v) => setState(() => _paymentUpdates = v))),
            FadeInUp(delay: const Duration(milliseconds: 450), child: _buildToggle(isDark, 'App Updates', 'New features and improvements', Icons.system_update_rounded, Colors.teal, _appUpdates, (v) => setState(() => _appUpdates = v))),
            FadeInUp(delay: const Duration(milliseconds: 500), child: _buildToggle(isDark, 'Promotions & Offers', 'Discounts and special offers', Icons.local_offer_rounded, Colors.purple, _promotions, (v) => setState(() => _promotions = v))),

            const SizedBox(height: 28),

            // Sound & Vibration
            FadeInDown(
              delay: const Duration(milliseconds: 550),
              child: Text('Sound & Vibration', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 16),
            FadeInUp(delay: const Duration(milliseconds: 600), child: _buildToggle(isDark, 'Sound', 'Play sound for notifications', Icons.volume_up_rounded, AppColors.accent, _soundEnabled, (v) => setState(() => _soundEnabled = v))),
            FadeInUp(delay: const Duration(milliseconds: 650), child: _buildToggle(isDark, 'Vibration', 'Vibrate for notifications', Icons.vibration_rounded, AppColors.accent, _vibrationEnabled, (v) => setState(() => _vibrationEnabled = v))),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(bool isDark, String title, String subtitle, IconData icon, Color color, bool value, ValueChanged<bool> onChanged) {
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
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color.withOpacity(0.1)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}