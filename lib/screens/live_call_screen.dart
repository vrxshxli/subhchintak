import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class LiveCallScreen extends StatefulWidget {
  const LiveCallScreen({super.key});

  @override
  State<LiveCallScreen> createState() => _LiveCallScreenState();
}

class _LiveCallScreenState extends State<LiveCallScreen> {
  bool _isMuted = false;
  bool _isSpeaker = false;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _seconds++);
      return true;
    });
  }

  String get _duration {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
              const SizedBox(height: 40),
              FadeIn(child: Text('Connected', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.success, letterSpacing: 1))),
              const SizedBox(height: 4),
              Text(_duration, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.7))),
              const Spacer(),
              // Avatar
              FadeIn(
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withOpacity(0.1),
                    border: Border.all(color: AppColors.success.withOpacity(0.3), width: 3),
                  ),
                  child: const Icon(Icons.person_rounded, size: 56, color: AppColors.success),
                ),
              ),
              const SizedBox(height: 20),
              Text('Anonymous Caller', style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Secure & Anonymous Call', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.5))),
              const Spacer(),
              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _controlButton(Icons.mic_off_rounded, 'Mute', _isMuted, () => setState(() => _isMuted = !_isMuted)),
                    _controlButton(Icons.volume_up_rounded, 'Speaker', _isSpeaker, () => setState(() => _isSpeaker = !_isSpeaker)),
                    _controlButton(Icons.chat_bubble_outline_rounded, 'Chat', false, () {
                      Navigator.pushReplacementNamed(context, '/chat');
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // End call
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                child: Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.danger),
                  child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: 12),
              Text('End Call', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.08),
            ),
            child: Icon(icon, color: active ? AppColors.accent : Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.6))),
        ],
      ),
    );
  }
}