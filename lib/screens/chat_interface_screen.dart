import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class ChatInterfaceScreen extends StatefulWidget {
  const ChatInterfaceScreen({super.key});

  @override
  State<ChatInterfaceScreen> createState() => _ChatInterfaceScreenState();
}

class _ChatInterfaceScreenState extends State<ChatInterfaceScreen> {
  bool _inChatView = false;
  int _selectedChatIndex = -1;

  // Sample chat list
  final List<Map<String, dynamic>> _chatList = [
    {'name': 'Stranger #1', 'lastMsg': 'I found your bag near the metro station', 'time': '10:32 AM', 'unread': 2, 'qr': 'Backpack QR', 'online': true},
    {'name': 'Stranger #2', 'lastMsg': 'Your vehicle is parked in no-parking zone', 'time': 'Yesterday', 'unread': 0, 'qr': 'Four-Wheeler QR', 'online': false},
    {'name': 'Stranger #3', 'lastMsg': 'Found your keys at the coffee shop', 'time': '2 days ago', 'unread': 0, 'qr': 'Key QR', 'online': false},
  ];

  final List<Map<String, dynamic>> _messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isRecording = false;
  int _recordingSeconds = 0;

  void _openChat(int index) {
    setState(() {
      _inChatView = true;
      _selectedChatIndex = index;
      _messages.clear();
      _messages.addAll([
        {'text': _chatList[index]['lastMsg'], 'isOwner': false, 'time': _chatList[index]['time'], 'type': 'text'},
      ]);
      _chatList[index]['unread'] = 0;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'text': _messageController.text.trim(), 'isOwner': true, 'time': 'Now', 'type': 'text'});
      _messageController.clear();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _shareLocation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.info.withOpacity(0.1)),
              child: const Icon(Icons.location_on_rounded, color: AppColors.info, size: 22)),
          const SizedBox(width: 12),
          Text('Share Location?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        ]),
        content: Text('Are you sure about sharing your location? This will share your current location with the stranger temporarily.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final status = await Permission.location.request();
              if (status.isGranted) {
                setState(() {
                  _messages.add({'text': '📍 Location shared', 'isOwner': true, 'time': 'Now', 'type': 'location'});
                });
                _scrollToBottom();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: const [Icon(Icons.check_circle_rounded, color: Colors.white, size: 20), SizedBox(width: 10), Text('Location shared successfully')]),
                    backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
                }
              }
            },
            child: Text('Yes, Share', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission denied')));
      return;
    }
    setState(() { _isRecording = true; _recordingSeconds = 0; });
    // Timer for recording duration
    _countRecording();
  }

  void _countRecording() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isRecording) return false;
      setState(() => _recordingSeconds++);
      return _isRecording;
    });
  }

  void _stopRecording() {
    final duration = _recordingSeconds;
    setState(() { _isRecording = false; _recordingSeconds = 0; });
    if (duration > 0) {
      setState(() {
        _messages.add({'text': '🎤 Voice message (${duration}s)', 'isOwner': true, 'time': 'Now', 'type': 'voice', 'duration': duration});
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_inChatView) return _buildChatView(context);
    return _buildChatList(context);
  }

  // ========== CHAT LIST (WhatsApp style) ==========
  Widget _buildChatList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShell(
      currentIndex: 2,
      body: _chatList.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No conversations yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Chats will appear when someone\nscans your QR code', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]), textAlign: TextAlign.center),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _chatList.length,
              itemBuilder: (context, index) {
                final chat = _chatList[index];
                final hasUnread = (chat['unread'] as int) > 0;

                return FadeInUp(
                  delay: Duration(milliseconds: 50 * index),
                  child: InkWell(
                    onTap: () => _openChat(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider, width: 0.5)),
                      ),
                      child: Row(children: [
                        // Avatar
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withOpacity(0.1),
                          ),
                          child: Stack(children: [
                            Center(child: Icon(Icons.person_rounded, color: AppColors.accent, size: 28)),
                            if (chat['online'] == true)
                              Positioned(bottom: 2, right: 2, child: Container(width: 14, height: 14,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success,
                                      border: Border.all(color: isDark ? AppColors.darkBg : Colors.white, width: 2)))),
                          ]),
                        ),
                        const SizedBox(width: 14),
                        // Info
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(chat['name'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600)),
                            Text(chat['time'] as String, style: GoogleFonts.poppins(fontSize: 11, color: hasUnread ? AppColors.accent : Colors.grey)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            Expanded(child: Text(chat['lastMsg'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(fontSize: 13, color: hasUnread ? (isDark ? Colors.white : Colors.black87) : Colors.grey))),
                            if (hasUnread)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
                                child: Text('${chat['unread']}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                          ]),
                          const SizedBox(height: 2),
                          Text(chat['qr'] as String, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.accent)),
                        ])),
                      ]),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ========== CHAT VIEW ==========
  Widget _buildChatView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chat = _chatList[_selectedChatIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => setState(() => _inChatView = false)),
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withOpacity(0.1)),
              child: const Icon(Icons.person_rounded, color: AppColors.accent, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(chat['name'] as String, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            Text(chat['online'] == true ? 'Online' : 'Offline', style: GoogleFonts.poppins(fontSize: 11, color: chat['online'] == true ? AppColors.success : Colors.grey)),
          ]),
        ]),
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/live-call'),
              icon: Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.success.withOpacity(0.1)),
                  child: const Icon(Icons.call_rounded, color: AppColors.success, size: 20))),
          IconButton(onPressed: _shareLocation,
              icon: Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.info.withOpacity(0.1)),
                  child: const Icon(Icons.location_on_outlined, color: AppColors.info, size: 20))),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(children: [
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isOwner = msg['isOwner'] as bool;
              final type = msg['type'] as String;

              return Align(
                alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isOwner ? AppColors.accent : (isDark ? AppColors.darkCard : Colors.grey[100]),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isOwner ? 16 : 4), bottomRight: Radius.circular(isOwner ? 4 : 16),
                    ),
                    border: isOwner ? null : Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    if (type == 'voice')
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.play_arrow_rounded, color: isOwner ? Colors.white : AppColors.accent, size: 22),
                        const SizedBox(width: 8),
                        Container(width: 100, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),
                            color: isOwner ? Colors.white.withOpacity(0.4) : AppColors.accent.withOpacity(0.3))),
                        const SizedBox(width: 8),
                        Text('${msg['duration']}s', style: GoogleFonts.poppins(fontSize: 12, color: isOwner ? Colors.white.withOpacity(0.8) : Colors.grey)),
                      ])
                    else if (type == 'location')
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.location_on_rounded, color: isOwner ? Colors.white : AppColors.info, size: 20),
                        const SizedBox(width: 8),
                        Text('Live Location Shared', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isOwner ? Colors.white : AppColors.info)),
                      ])
                    else
                      Text(msg['text'] as String, style: GoogleFonts.poppins(fontSize: 14, color: isOwner ? Colors.white : null)),
                    const SizedBox(height: 4),
                    Text(msg['time'] as String, style: GoogleFonts.poppins(fontSize: 10, color: isOwner ? Colors.white.withOpacity(0.6) : Colors.grey)),
                  ]),
                ),
              );
            },
          ),
        ),
        // Recording indicator
        if (_isRecording)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: AppColors.danger.withOpacity(0.1),
            child: Row(children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.danger)),
              const SizedBox(width: 10),
              Text('Recording... ${_recordingSeconds}s', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger)),
              const Spacer(),
              GestureDetector(onTap: () => setState(() { _isRecording = false; _recordingSeconds = 0; }),
                  child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey))),
            ]),
          ),
        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider))),
          child: Row(children: [
            // Voice button
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 44,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                    color: _isRecording ? AppColors.danger.withOpacity(0.2) : (isDark ? AppColors.darkBg : AppColors.lightBg)),
                child: Icon(Icons.mic_rounded, color: _isRecording ? AppColors.danger : AppColors.accent, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: isDark ? AppColors.darkBg : AppColors.lightBg, borderRadius: BorderRadius.circular(14)),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(hintText: 'Type a message...', border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintStyle: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accentLight])),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
            ),
          ]),
        ),
      ]),
    );
  }
}