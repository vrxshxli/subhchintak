import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class ChatInterfaceScreen extends StatefulWidget {
  const ChatInterfaceScreen({super.key});

  @override
  State<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

class _ChatInterfaceScreenState extends State<ChatInterfaceScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isRecording = false;

  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hi, I found your bag near the metro station.', 'isOwner': false, 'time': '10:32 AM', 'type': 'text'},
    {'text': 'Oh thank you so much! Which station?', 'isOwner': true, 'time': '10:33 AM', 'type': 'text'},
    {'text': 'Rajiv Chowk. I can wait here for 15 mins.', 'isOwner': false, 'time': '10:33 AM', 'type': 'text'},
    {'text': 'I am on my way! Thank you for being kind!', 'isOwner': true, 'time': '10:34 AM', 'type': 'text'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isOwner': true,
        'time': 'Now',
        'type': 'text',
      });
      _messageController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShell(
      currentIndex: 2,
      body: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.accent.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Anonymous Stranger', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success)),
                          const SizedBox(width: 6),
                          Text('Online', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.success)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call button
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppColors.success.withOpacity(0.1)),
                  child: IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/live-call'),
                    icon: const Icon(Icons.call_rounded, color: AppColors.success, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                // Location share
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: AppColors.info.withOpacity(0.1)),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location sharing - temporary and privacy-preserving')));
                    },
                    icon: const Icon(Icons.location_on_outlined, color: AppColors.info, size: 22),
                  ),
                ),
              ],
            ),
          ),
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isOwner = msg['isOwner'] as bool;
                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isOwner ? AppColors.accent : (isDark ? AppColors.darkCard : Colors.grey[100]),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isOwner ? 16 : 4),
                          bottomRight: Radius.circular(isOwner ? 4 : 16),
                        ),
                        border: isOwner ? null : Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(msg['text'] as String,
                              style: GoogleFonts.poppins(fontSize: 14, color: isOwner ? Colors.white : null)),
                          const SizedBox(height: 4),
                          Text(msg['time'] as String,
                              style: GoogleFonts.poppins(fontSize: 10, color: isOwner ? Colors.white.withOpacity(0.7) : Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
            ),
            child: Row(
              children: [
                // Voice message button
                GestureDetector(
                  onLongPressStart: (_) => setState(() => _isRecording = true),
                  onLongPressEnd: (_) => setState(() => _isRecording = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: _isRecording ? AppColors.danger.withOpacity(0.2) : (isDark ? AppColors.darkBg : AppColors.lightBg),
                    ),
                    child: Icon(Icons.mic_rounded, color: _isRecording ? AppColors.danger : AppColors.accent, size: 22),
                  ),
                ),
                const SizedBox(width: 10),
                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBg : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintStyle: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Send button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}