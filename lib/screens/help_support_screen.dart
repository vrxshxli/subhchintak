import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int _expandedFaq = -1;

  final _faqs = [
    {'q': 'How does SHUBHCHINTAK protect my privacy?', 'a': 'Your personal contact information is never shared with anyone. When a stranger scans your QR, they connect through our anonymous relay system. Neither party sees the other\'s phone number, email, or any personal details.'},
    {'q': 'What happens when someone scans my QR code?', 'a': 'They are redirected to a web page where they can call or chat with you anonymously. No app installation is required on their side. If you don\'t answer within 30 seconds, the call auto-escalates to your emergency contacts.'},
    {'q': 'Can I use one QR for multiple items?', 'a': 'Yes! Your QR code is linked to your account, not a specific item. You can use the same QR for different purposes — attach it to your vehicle, bag, keys, or anything else. One QR per account is all you need. Simply download and print as many copies as you want.'},
    {'q': 'What if my QR sticker gets damaged?', 'a': 'No worries! You can re-download your QR as a PDF unlimited times from the "My Tags" section and print new copies whenever needed. Your QR code stays active regardless of the physical sticker\'s condition.'},
    {'q': 'How do emergency contacts work?', 'a': 'If you miss a call from a stranger who scanned your QR, the system automatically calls your emergency contacts in priority order. You can set up to 5 emergency contacts and arrange their priority by dragging. You can sync contacts directly from your phone.'},
    {'q': 'What is the pricing model?', 'a': 'SHUBHCHINTAK offers a simple yearly subscription. Pay once and you get full access for an entire year — generate your QR, download it unlimited times, print as many copies as you need, and enjoy all features including anonymous calls, chat, and emergency escalation. No hidden charges.'},
    {'q': 'Can I deactivate my QR code temporarily?', 'a': 'Yes, you can deactivate your QR code from the "My Tags" section anytime. When deactivated, scanning the QR will show a "QR Inactive" message. You can reactivate it whenever you want without any extra charge during your subscription period.'},
    {'q': 'How many times can I download my QR?', 'a': 'Unlimited! Once your QR is generated and your subscription is active, you can download it as a PDF as many times as you want. Print it at home, at a shop, or order physical stickers — there\'s no limit.'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(child: Text('Get in Touch', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700))),
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Row(children: [
                Expanded(child: _contactCard(isDark, 'Email Us', 'support@shubhchintak.app', Icons.email_rounded, AppColors.info, () async {
                  final uri = Uri.parse('mailto:support@shubhchintak.app');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                })),
                const SizedBox(width: 12),
                Expanded(child: _contactCard(isDark, 'Call Us', '+91 1800-XXX-XXX', Icons.call_rounded, AppColors.success, () async {
                  final uri = Uri.parse('tel:+911800000000');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                })),
              ]),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Row(children: [
                Expanded(child: _contactCard(isDark, 'Connect With Us', 'Chat with our team', Icons.support_agent_rounded, AppColors.accent, () {
                  _openAdminChat(context);
                })),
                const SizedBox(width: 12),
                Expanded(child: _contactCard(isDark, 'Report Bug', 'Found an issue?', Icons.bug_report_rounded, AppColors.warning, () => _showBugReportForm())),
              ]),
            ),
            const SizedBox(height: 32),
            FadeInDown(delay: const Duration(milliseconds: 200), child: Text('Frequently Asked Questions', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700))),
            const SizedBox(height: 16),
            ...List.generate(_faqs.length, (index) {
              final faq = _faqs[index];
              final isExpanded = _expandedFaq == index;
              return FadeInUp(
                delay: Duration(milliseconds: 250 + index * 50),
                child: GestureDetector(
                  onTap: () => setState(() => _expandedFaq = isExpanded ? -1 : index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isExpanded ? AppColors.accent.withOpacity(0.3) : (isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 28, height: 28, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.accent.withOpacity(0.1)),
                            child: Center(child: Text('${index + 1}', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(faq['q']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600))),
                        AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 250),
                            child: Icon(Icons.expand_more_rounded, color: isExpanded ? AppColors.accent : Colors.grey)),
                      ]),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        Padding(padding: const EdgeInsets.only(left: 40),
                          child: Text(faq['a']!, style: GoogleFonts.poppins(fontSize: 13, height: 1.6, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
                      ],
                    ]),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(bool isDark, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
        child: Column(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.1)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 10),
          Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          Text(sub, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  // ========== ADMIN CHAT ==========
  void _openAdminChat(BuildContext context) {
    final msgController = TextEditingController();
    final messages = <Map<String, dynamic>>[
      {'text': 'Hi! Welcome to SHUBHCHINTAK support. How can we help you today?', 'isAdmin': true, 'time': 'Now'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(bottom: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                ),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.accent.withOpacity(0.1)),
                      child: const Icon(Icons.support_agent_rounded, color: AppColors.accent, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('SHUBHCHINTAK Support', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                    Row(children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success)),
                      const SizedBox(width: 6),
                      Text('Online', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.success)),
                    ]),
                  ])),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ]),
              ),
              // Messages
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    final isAdmin = msg['isAdmin'] as bool;
                    return Align(
                      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.75),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isAdmin ? (isDark ? AppColors.darkCard : Colors.grey[100]) : AppColors.accent,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isAdmin ? 4 : 16), bottomRight: Radius.circular(isAdmin ? 16 : 4),
                          ),
                        ),
                        child: Text(msg['text'] as String, style: GoogleFonts.poppins(fontSize: 14, color: isAdmin ? null : Colors.white)),
                      ),
                    );
                  },
                ),
              ),
              // Input
              Container(
                padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
                decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    border: Border(top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider))),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      decoration: InputDecoration(hintText: 'Type your message...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          filled: true, fillColor: isDark ? AppColors.darkBg : AppColors.lightBg, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (msgController.text.trim().isEmpty) return;
                      setSheetState(() {
                        messages.add({'text': msgController.text.trim(), 'isAdmin': false, 'time': 'Now'});
                        msgController.clear();
                      });
                      // Auto reply
                      Future.delayed(const Duration(seconds: 1), () {
                        if (ctx.mounted) {
                          setSheetState(() {
                            messages.add({'text': 'Thank you for reaching out! Our team will review your message and get back to you shortly. Typical response time: 2-4 hours.', 'isAdmin': true, 'time': 'Now'});
                          });
                        }
                      });
                    },
                    child: Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight])),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
                  ),
                ]),
              ),
            ]),
          );
        });
      },
    );
  }

  // ========== BUG REPORT FORM ==========
  void _showBugReportForm() {
    final descC = TextEditingController();
    final stepsC = TextEditingController();
    String selectedPage = 'Dashboard';
    String severity = 'Medium';

    final pages = ['Splash', 'Onboarding', 'Login', 'Register', 'Dashboard', 'Order QR', 'Design QR', 'QR Canvas', 'Payment', 'Emergency Contacts', 'Chat', 'Tag Details', 'Updates', 'Profile', 'Edit Profile', 'Settings', 'Other'];
    final severities = ['Low', 'Medium', 'High', 'Critical'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Report a Bug', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Help us improve by reporting issues', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),

              // Page selector
              Text('Which page has the bug?', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedPage,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.pages_rounded)),
                items: pages.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setSheetState(() => selectedPage = v ?? 'Dashboard'),
              ),
              const SizedBox(height: 16),

              // Severity
              Text('Severity', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: severities.map((s) {
                final isSelected = severity == s;
                final color = s == 'Critical' ? AppColors.danger : s == 'High' ? AppColors.warning : s == 'Medium' ? AppColors.info : AppColors.success;
                return GestureDetector(
                  onTap: () => setSheetState(() => severity = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: isSelected ? color : color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? color : color.withOpacity(0.3))),
                    child: Text(s, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : color)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),

              // Description
              Text('Describe the bug', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(controller: descC, maxLines: 3, decoration: const InputDecoration(hintText: 'What went wrong?', alignLabelWithHint: true)),
              const SizedBox(height: 16),

              // Steps to reproduce
              Text('Steps to reproduce (optional)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(controller: stepsC, maxLines: 2, decoration: const InputDecoration(hintText: '1. Go to...\n2. Tap on...', alignLabelWithHint: true)),
              const SizedBox(height: 24),

              SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
                onPressed: () {
                  if (descC.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please describe the bug')));
                    return;
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: const [Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), SizedBox(width: 10), Text('Bug report submitted. Thank you!')]),
                    backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                icon: const Icon(Icons.send_rounded, size: 20),
                label: Text('Submit Bug Report', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              )),
            ]),
          ),
        );
      }),
    );
  }
}