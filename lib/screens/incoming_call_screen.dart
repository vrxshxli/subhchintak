import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
          child: Column(
            children: [
              const SizedBox(height: 60),
              FadeInDown(
                child: Text('Incoming Call', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.6), letterSpacing: 2)),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text('Someone scanned your QR',
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.accent)),
              ),
              const Spacer(),
              // Avatar with pulse
              ScaleTransition(
                scale: Tween(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)),
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.1),
                    border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 3),
                  ),
                  child: const Icon(Icons.person_rounded, size: 64, color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 24),
              FadeIn(child: Text('Anonymous Caller', style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
              const SizedBox(height: 8),
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('Four-Wheeler QR  •  Vehicle', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                ),
              ),
              const Spacer(),
              // Call actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Decline
                    FadeInLeft(
                      delay: const Duration(milliseconds: 400),
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/missed-call'),
                        child: Column(
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.danger.withOpacity(0.2)),
                              child: const Icon(Icons.call_end_rounded, color: AppColors.danger, size: 32),
                            ),
                            const SizedBox(height: 10),
                            Text('Decline', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.7))),
                          ],
                        ),
                      ),
                    ),
                    // Accept
                    FadeInRight(
                      delay: const Duration(milliseconds: 400),
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/live-call'),
                        child: Column(
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(0.2)),
                              child: const Icon(Icons.call_rounded, color: AppColors.success, size: 32),
                            ),
                            const SizedBox(height: 10),
                            Text('Accept', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.7))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}