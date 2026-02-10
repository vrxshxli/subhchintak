import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/qr_provider.dart';
import '../widgets/app_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QRProvider>().loadQRCodes();
      context.read<AuthProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final qr = context.watch<QRProvider>();
    final userName = auth.user?['name'] ?? 'User';

    return AppShell(
      currentIndex: 1,
      body: RefreshIndicator(
        onRefresh: () async => await qr.loadQRCodes(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text('Hello, $userName',
                    style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              ),
              const SizedBox(height: 4),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text('Keep your belongings safe with SHUBHCHINTAK',
                    style: GoogleFonts.poppins(fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ),
              const SizedBox(height: 28),
              // QR Status Card
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildQRStatusCard(context, qr),
              ),
              const SizedBox(height: 20),
              // Quick Actions
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Text('Quick Actions',
                    style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    Expanded(child: _actionCard(context, Icons.qr_code_2_rounded, 'Order QR', 'Get your safety QR', '/order-qr', AppColors.accent)),
                    const SizedBox(width: 12),
                    Expanded(child: _actionCard(context, Icons.design_services_rounded, 'Design QR', 'Customize your QR', '/design-qr-entry', AppColors.info)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Expanded(child: _actionCard(context, Icons.emergency_rounded, 'Emergency', 'Manage contacts', '/emergency-contacts', AppColors.danger)),
                    const SizedBox(width: 12),
                    Expanded(child: _actionCard(context, Icons.local_offer_rounded, 'My Tags', 'View all QR codes', '/tag-details', AppColors.success)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Recent Activity
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Text('Recent Activity',
                    style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: _buildRecentActivity(context, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRStatusCard(BuildContext context, QRProvider qr) {
    final hasActive = qr.hasActiveQR;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasActive
              ? [const Color(0xFF1B3A4B), const Color(0xFF1B2838)]
              : [const Color(0xFF2D4059), const Color(0xFF1B2838)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1B2838).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('QR Status', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.7))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: hasActive ? AppColors.success.withOpacity(0.2) : AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: hasActive ? AppColors.success.withOpacity(0.4) : AppColors.warning.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: hasActive ? AppColors.success : AppColors.warning),
                    ),
                    const SizedBox(width: 8),
                    Text(hasActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: hasActive ? AppColors.success : AppColors.warning)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: const Icon(Icons.qr_code_2_rounded, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hasActive ? '${qr.qrCodes.length} QR Code(s)' : 'No Active QR',
                        style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(hasActive ? 'Your belongings are protected' : 'Generate a QR to get started',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
          if (!hasActive) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/order-qr'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Generate Your First QR', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, IconData icon, String title, String subtitle, String route, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, bool isDark) {
    // Placeholder for recent activity - would be populated from API
    final activities = [
      {'icon': Icons.qr_code_scanner, 'title': 'QR Scanned', 'subtitle': 'Someone scanned your vehicle QR', 'time': '2 hours ago', 'color': AppColors.info},
      {'icon': Icons.call_received, 'title': 'Call Received', 'subtitle': 'Anonymous call - 2 minutes', 'time': 'Yesterday', 'color': AppColors.success},
      {'icon': Icons.chat_bubble_outline, 'title': 'New Message', 'subtitle': 'Stranger sent a message', 'time': '2 days ago', 'color': AppColors.accent},
    ];

    return Column(
      children: activities.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: (a['color'] as Color).withOpacity(0.1),
                ),
                child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['title'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(a['subtitle'] as String, style: GoogleFonts.poppins(fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  ],
                ),
              ),
              Text(a['time'] as String, style: GoogleFonts.poppins(fontSize: 11,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}