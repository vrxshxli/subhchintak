import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _updates = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<Map<String, dynamic>> get updates => _updates;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadUpdates() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.getUpdates();
      if (response['success'] == true) {
        _updates = List<Map<String, dynamic>>.from(response['updates'] ?? []);
        _unreadCount = _updates.where((u) => u['read'] == false).length;
      }
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }

  void markAllRead() {
    _unreadCount = 0;
    for (var u in _updates) {
      u['read'] = true;
    }
    notifyListeners();
  }
}