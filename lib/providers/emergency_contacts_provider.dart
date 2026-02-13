import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class EmergencyContactsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = false;
  String? _error;

  static const String _storageKey = 'emergency_contacts_local';

  List<Map<String, dynamic>> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EmergencyContactsProvider() {
    _loadFromLocal(); // Always load from local storage first
  }

  // ═══════════════════════════════════════════════════════════════
  // LOCAL STORAGE HELPERS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _contacts.map((c) => jsonEncode(c)).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      _contacts = jsonList.map((s) {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return map;
      }).toList();
      _updatePriorityDisplay();
      notifyListeners();
    }
  }

  void _updatePriorityDisplay() {
    for (int i = 0; i < _contacts.length; i++) {
      _contacts[i]['priority_display'] = '${i + 1}';
      _contacts[i]['priority'] = i + 1;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD FROM SERVER (optional sync — merges with local)
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getEmergencyContacts();
      if (response['success'] == true) {
        final serverContacts =
            List<Map<String, dynamic>>.from(response['contacts'] ?? []);
        if (serverContacts.isNotEmpty) {
          _contacts = serverContacts;
          _updatePriorityDisplay();
          await _saveToLocal();
        }
      }
    } catch (e) {
      // Server unreachable — local data already loaded in constructor
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // ADD SINGLE CONTACT
  // ═══════════════════════════════════════════════════════════════

  Future<bool> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    // Check duplicate locally
    if (hasPhone(phone)) {
      _error = 'Contact with this phone already exists';
      notifyListeners();
      return false;
    }

    // Save locally FIRST with a temporary ID
    final localContact = <String, dynamic>{
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'phone': phone,
      'relation': relation,
      'priority': _contacts.length + 1,
      'priority_display': '${_contacts.length + 1}',
      'createdAt': DateTime.now().toIso8601String(),
    };

    _contacts.add(localContact);
    notifyListeners();
    await _saveToLocal();

    // Try to sync to server in background
    try {
      final response = await ApiService.addEmergencyContact(
        name: name,
        phone: phone,
        relation: relation,
        priority: _contacts.length,
      );

      if (response['success'] == true && response['contact'] != null) {
        // Replace local temp entry with server entry (has real ID)
        final serverContact = response['contact'] as Map<String, dynamic>;
        final idx = _contacts.indexWhere((c) => c['id'] == localContact['id']);
        if (idx >= 0) {
          serverContact['priority_display'] = '${idx + 1}';
          _contacts[idx] = serverContact;
          await _saveToLocal();
          notifyListeners();
        }
      }
    } catch (e) {
      // Saved locally — will sync when server is available
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // BULK ADD (SYNC FROM DEVICE)
  // ═══════════════════════════════════════════════════════════════

  Future<int> bulkAddContacts(List<Map<String, String>> newContacts) async {
    if (newContacts.isEmpty) return 0;

    int addedCount = 0;

    for (final contact in newContacts) {
      if (contact['name'] == null || contact['phone'] == null) continue;
      if (hasPhone(contact['phone']!)) continue;

      final localContact = <String, dynamic>{
        'id': 'local_${DateTime.now().millisecondsSinceEpoch}_$addedCount',
        'name': contact['name']!,
        'phone': contact['phone']!,
        'relation': contact['relation'] ?? '',
        'priority': _contacts.length + 1,
        'priority_display': '${_contacts.length + 1}',
        'createdAt': DateTime.now().toIso8601String(),
      };

      _contacts.add(localContact);
      addedCount++;
    }

    if (addedCount > 0) {
      _updatePriorityDisplay();
      notifyListeners();
      await _saveToLocal();

      // Try to sync to server in background (non-blocking)
      _syncBulkToServer(newContacts);
    }

    return addedCount;
  }

  /// Background server sync — updates local IDs with server IDs if successful
  Future<void> _syncBulkToServer(List<Map<String, String>> contacts) async {
    try {
      final response = await ApiService.bulkAddEmergencyContacts(
        contacts: contacts,
      );

      if (response['success'] == true) {
        final serverContacts =
            List<Map<String, dynamic>>.from(response['contacts'] ?? []);
        if (serverContacts.isNotEmpty) {
          _contacts = serverContacts;
          _updatePriorityDisplay();
          await _saveToLocal();
          notifyListeners();
        }
      }
    } catch (e) {
      // Server sync failed — local data is the source of truth
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UPDATE RELATION
  // ═══════════════════════════════════════════════════════════════

  Future<bool> updateRelation(String id, String relation) async {
    final idx = _contacts.indexWhere((c) => c['id'] == id);
    if (idx < 0) return false;

    _contacts[idx]['relation'] = relation;
    notifyListeners();
    await _saveToLocal();

    // Try server sync in background
    try {
      if (!id.startsWith('local_')) {
        await ApiService.updateEmergencyContact(id: id, relation: relation);
      }
    } catch (e) {
      // Saved locally
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // REORDER
  // ═══════════════════════════════════════════════════════════════

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _contacts.removeAt(oldIndex);
    _contacts.insert(newIndex, item);

    _updatePriorityDisplay();
    notifyListeners();
    await _saveToLocal();

    // Try server sync
    try {
      final orderedIds = _contacts
          .where((c) => !(c['id'] as String).startsWith('local_'))
          .map((c) => c['id'] as String)
          .toList();
      if (orderedIds.isNotEmpty) {
        await ApiService.reorderEmergencyContacts(orderedIds: orderedIds);
      }
    } catch (e) {
      // Saved locally
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════

  Future<bool> deleteContact(int index) async {
    if (index < 0 || index >= _contacts.length) return false;

    final contact = _contacts[index];
    final id = contact['id'] as String?;

    _contacts.removeAt(index);
    _updatePriorityDisplay();
    notifyListeners();
    await _saveToLocal();

    // Try server sync
    if (id != null && !id.startsWith('local_')) {
      try {
        await ApiService.removeEmergencyContact(id);
      } catch (e) {
        // Deleted locally
      }
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  bool hasPhone(String phone) {
    return _contacts.any((c) => c['phone'] == phone);
  }

  /// Call on logout to clear local data
  Future<void> clearAll() async {
    _contacts = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}