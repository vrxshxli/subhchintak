import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class QRProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _masterQR;
  List<Map<String, dynamic>> _tagDesigns = [];
  List<Map<String, dynamic>> _addresses = [];
  String? _selectedTemplate;
  String? _customPurpose;
  Map<String, dynamic> _customization = {};
  // Temporary thumbnail bytes from canvas capture
  Uint8List? _pendingThumbnail;

  static const String _qrKey = 'master_qr_local';
  static const String _tagsKey = 'tag_designs_local';
  static const String _addrKey = 'addresses_local';

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get masterQR => _masterQR;
  List<Map<String, dynamic>> get tagDesigns => _tagDesigns;
  List<Map<String, dynamic>> get addresses => _addresses;
  String? get selectedTemplate => _selectedTemplate;
  String? get customPurpose => _customPurpose;
  Map<String, dynamic> get customization => _customization;
  Uint8List? get pendingThumbnail => _pendingThumbnail;

  bool get hasActiveSubscription {
    if (_masterQR == null) return false;
    final s = _masterQR!['status'];
    if (s != 'ACTIVE' && s != 'active') return false;
    final e = _masterQR!['expiresAt'];
    if (e != null) { final exp = DateTime.tryParse(e.toString()); if (exp != null && DateTime.now().isAfter(exp)) return false; }
    return true;
  }
  bool get hasQR => _masterQR != null;
  String get qrDataUrl => _masterQR?['qrDataUrl'] ?? '';
  String get uniqueCode => _masterQR?['uniqueCode'] ?? '';
  int get scansCount => _masterQR?['scansCount'] ?? 0;

  // Legacy compat
  bool get hasActiveQR => hasActiveSubscription;
  List<Map<String, dynamic>> get qrCodes => _masterQR != null ? [_masterQR!] : [];
  Map<String, dynamic>? get currentQR => _masterQR;
  int get activeQRCount => hasActiveSubscription ? 1 : 0;

  QRProvider() { _loadFromLocal(); }

  Future<void> _saveToLocal() async {
    final p = await SharedPreferences.getInstance();
    if (_masterQR != null) await p.setString(_qrKey, jsonEncode(_masterQR));
    await p.setStringList(_tagsKey, _tagDesigns.map((t) => jsonEncode(t)).toList());
    await p.setStringList(_addrKey, _addresses.map((a) => jsonEncode(a)).toList());
  }

  Future<void> _loadFromLocal() async {
    final p = await SharedPreferences.getInstance();
    final q = p.getString(_qrKey); if (q != null) _masterQR = jsonDecode(q);
    final t = p.getStringList(_tagsKey); if (t != null) _tagDesigns = t.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
    final a = p.getStringList(_addrKey); if (a != null) _addresses = a.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
    notifyListeners();
  }

  Future<void> loadQRCodes() async {
    _isLoading = true; notifyListeners();
    try {
      final qrR = await ApiService.getMyQR();
      if (qrR['success'] == true && qrR['qr'] != null) _masterQR = qrR['qr'];
      final tagR = await ApiService.getTagDesigns();
      if (tagR['success'] == true) _tagDesigns = List<Map<String, dynamic>>.from(tagR['tags'] ?? []);
      await _saveToLocal();
    } catch (_) {}
    _isLoading = false; notifyListeners();
  }

  Future<void> loadAddresses() async {
    try {
      final r = await ApiService.getAddresses();
      if (r['success'] == true) { _addresses = List<Map<String, dynamic>>.from(r['addresses'] ?? []); await _saveToLocal(); notifyListeners(); }
    } catch (_) {}
  }

  Future<bool> generateQR() async {
    if (_masterQR != null) return true;
    _isLoading = true; notifyListeners();
    final code = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    _masterQR = { 'id': 'local_${DateTime.now().millisecondsSinceEpoch}', 'uniqueCode': code,
      'qrDataUrl': 'https://shubhchintak.app/scan/$code', 'status': 'ACTIVE',
      'activatedAt': DateTime.now().toIso8601String(), 'expiresAt': DateTime.now().add(const Duration(days: 365)).toIso8601String(), 'scansCount': 0 };
    notifyListeners(); await _saveToLocal();
    try {
      final r = await ApiService.generateQR();
      if (r['success'] == true && r['qr'] != null) { _masterQR = r['qr']; await _saveToLocal(); notifyListeners(); }
    } catch (_) {}
    _isLoading = false; notifyListeners(); return true;
  }

  void setPendingThumbnail(Uint8List? bytes) { _pendingThumbnail = bytes; }

  Future<Map<String, dynamic>?> saveTagDesign() async {
    final purpose = _customPurpose ?? _selectedTemplate ?? 'Custom';
    final template = _selectedTemplate ?? 'custom';
    // Encode thumbnail as base64 for local storage
    String? thumbBase64;
    if (_pendingThumbnail != null) thumbBase64 = base64Encode(_pendingThumbnail!);

    final localTag = <String, dynamic>{ 'id': 'local_tag_${DateTime.now().millisecondsSinceEpoch}',
      'purpose': purpose, 'customPurpose': _customPurpose, 'templateType': template,
      'customization': Map<String, dynamic>.from(_customization), 'thumbnailBase64': thumbBase64,
      'qrDataUrl': qrDataUrl, 'createdAt': DateTime.now().toIso8601String() };
    _tagDesigns.insert(0, localTag); notifyListeners(); await _saveToLocal();
    try {
      final r = await ApiService.saveTagDesign(purpose: purpose, customPurpose: _customPurpose, templateType: template, customization: _customization);
      if (r['success'] == true && r['tag'] != null) {
        final st = r['tag'] as Map<String, dynamic>; st['thumbnailBase64'] = thumbBase64;
        final idx = _tagDesigns.indexWhere((t) => t['id'] == localTag['id']);
        if (idx >= 0) { _tagDesigns[idx] = st; await _saveToLocal(); notifyListeners(); } return st;
      }
    } catch (_) {}
    _pendingThumbnail = null; return localTag;
  }

  Future<void> deleteTag(int index) async {
    if (index < 0 || index >= _tagDesigns.length) return;
    final tag = _tagDesigns[index]; _tagDesigns.removeAt(index); notifyListeners(); await _saveToLocal();
    final id = tag['id'] as String?;
    if (id != null && !id.startsWith('local_')) try { await ApiService.deleteTagDesign(id); } catch (_) {}
  }

  Future<bool> saveAddress(Map<String, dynamic> addr) async {
    _addresses.insert(0, addr); notifyListeners(); await _saveToLocal();
    try {
      final r = await ApiService.saveAddress(addr);
      if (r['success'] == true && r['address'] != null) {
        final idx = _addresses.indexWhere((a) => a['id'] == addr['id']);
        if (idx >= 0) _addresses[idx] = r['address']; else _addresses.insert(0, r['address']);
        await _saveToLocal(); notifyListeners(); return true;
      }
    } catch (_) {} return true;
  }

  Map<String, dynamic>? get defaultAddress {
    try { return _addresses.firstWhere((a) => a['isDefault'] == true); } catch (_) { return _addresses.isNotEmpty ? _addresses.first : null; }
  }

  void setTemplate(String t) { _selectedTemplate = t; notifyListeners(); }
  void setCustomPurpose(String p) { _customPurpose = p; notifyListeners(); }
  void updateCustomization(Map<String, dynamic> d) { _customization = {..._customization, ...d}; notifyListeners(); }
  void setCurrentQR(Map<String, dynamic> q) {}
  void reset() { _selectedTemplate = null; _customPurpose = null; _customization = {}; _pendingThumbnail = null; notifyListeners(); }
  Future<void> clearAll() async { _masterQR = null; _tagDesigns = []; _addresses = []; notifyListeners();
    final p = await SharedPreferences.getInstance(); await p.remove(_qrKey); await p.remove(_tagsKey); await p.remove(_addrKey); }
}