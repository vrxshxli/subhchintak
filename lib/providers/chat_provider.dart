import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _messages = [];
  String? _activeSessionId;
  bool _isLoading = false;

  List<Map<String, dynamic>> get sessions => _sessions;
  List<Map<String, dynamic>> get messages => _messages;
  String? get activeSessionId => _activeSessionId;
  bool get isLoading => _isLoading;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.getChatSessions();
      if (response['success'] == true) {
        _sessions = List<Map<String, dynamic>>.from(response['sessions'] ?? []);
      }
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(String sessionId) async {
    _activeSessionId = sessionId;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.getChatMessages(sessionId);
      if (response['success'] == true) {
        _messages = List<Map<String, dynamic>>.from(response['messages'] ?? []);
      }
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }

  void addMessage(Map<String, dynamic> message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearChat() {
    _messages = [];
    _activeSessionId = null;
    notifyListeners();
  }
}