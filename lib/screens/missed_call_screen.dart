import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class MissedCallScreen extends StatelessWidget {
  const MissedCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF1B2838), Color(0xFF0D1B2A)]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                FadeInDown(
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.warning.withOpacity(0.15),
                    ),
                    child: const Icon(Icons.phone_missed_rounded, size: 48, color: AppColors.warning),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text('Missed Call', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Text('You missed a call from a QR scanner',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.6)), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 40),
                // Escalation status
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emergency_rounded, color: AppColors.danger, size: 20),
                            const SizedBox(width: 10),
                            Text('Emergency Escalation', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _escalationStep('Calling Emergency Contact #1', 'Mom (+91 98765 43210)', 'In Progress', AppColors.warning),
                        _escalationStep('Emergency Contact #2', 'Dad (+91 98765 43211)', 'Pending', Colors.grey),
                        _escalationStep('Chat Fallback', 'Opens chat interface for stranger', 'Standby', Colors.grey),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Actions
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/chat'),
                      icon: const Icon(Icons.chat_rounded),
                      label: Text('Open Chat', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.3))),
                      child: Text('Go to Dashboard', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _escalationStep(String title, String subtitle, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }
}