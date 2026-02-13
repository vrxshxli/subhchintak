import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class QRProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _qrCodes = [];
  Map<String, dynamic>? _currentQR;
  String? _selectedTemplate;
  String? _customPurpose;
  Map<String, dynamic> _customization = {};

  static const String _storageKey = 'qr_codes_local';

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get qrCodes => _qrCodes;
  Map<String, dynamic>? get currentQR => _currentQR;
  String? get selectedTemplate => _selectedTemplate;
  String? get customPurpose => _customPurpose;
  Map<String, dynamic> get customization => _customization;

  /// True if at least one QR has ACTIVE status
  bool get hasActiveQR => _qrCodes.any((qr) =>
      qr['status'] == 'ACTIVE' || qr['status'] == 'active');

  /// Get the first active QR (the primary linked QR)
  Map<String, dynamic>? get activeQR {
    try {
      return _qrCodes.firstWhere((qr) =>
          qr['status'] == 'ACTIVE' || qr['status'] == 'active');
    } catch (_) {
      return null;
    }
  }

  /// Count of active QRs
  int get activeQRCount => _qrCodes
      .where((qr) => qr['status'] == 'ACTIVE' || qr['status'] == 'active')
      .length;

  QRProvider() {
    _loadFromLocal();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOCAL STORAGE
  // ═══════════════════════════════════════════════════════════════

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _qrCodes.map((c) => jsonEncode(c)).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      _qrCodes = jsonList
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .toList();
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TEMPLATE & PURPOSE SELECTION
  // ═══════════════════════════════════════════════════════════════

  void setTemplate(String template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void setCustomPurpose(String purpose) {
    _customPurpose = purpose;
    notifyListeners();
  }

  void updateCustomization(Map<String, dynamic> data) {
    _customization = {..._customization, ...data};
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD FROM SERVER
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadQRCodes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getUserQRs();
      if (response['success'] == true) {
        final serverQRs =
            List<Map<String, dynamic>>.from(response['qrCodes'] ?? []);
        if (serverQRs.isNotEmpty) {
          _qrCodes = serverQRs;
          await _saveToLocal();
        }
      }
    } catch (e) {
      // Use local data
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // CREATE QR CODE
  // ═══════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> createQR() async {
    _isLoading = true;
    notifyListeners();

    final purpose = _customPurpose ?? _selectedTemplate ?? 'Custom';
    final template = _selectedTemplate ?? 'custom';

    // Create locally first
    final localQR = <String, dynamic>{
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'uniqueCode': DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase(),
      'purpose': purpose,
      'customPurpose': _customPurpose,
      'templateType': template,
      'status': 'INACTIVE',
      'qrDataUrl': 'https://shubhchintak.app/scan/${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
      'customization': _customization,
      'scansCount': 0,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _qrCodes.insert(0, localQR);
    _currentQR = localQR;
    notifyListeners();
    await _saveToLocal();

    // Try server sync
    try {
      final response = await ApiService.createQR(
        purpose: purpose,
        templateType: template,
        customization: _customization,
      );

      if (response['success'] == true && response['qr'] != null) {
        final serverQR = response['qr'] as Map<String, dynamic>;
        final idx = _qrCodes.indexWhere((q) => q['id'] == localQR['id']);
        if (idx >= 0) {
          _qrCodes[idx] = serverQR;
          _currentQR = serverQR;
          await _saveToLocal();
          notifyListeners();
        }
        _isLoading = false;
        notifyListeners();
        return serverQR;
      }
    } catch (e) {
      // Local QR created
    }

    _isLoading = false;
    notifyListeners();
    return localQR;
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTIVATE QR (after payment)
  // ═══════════════════════════════════════════════════════════════

  Future<bool> activateQR(String qrId, {String? paymentId}) async {
    // Activate locally first
    final idx = _qrCodes.indexWhere((q) => q['id'] == qrId);
    if (idx >= 0) {
      _qrCodes[idx]['status'] = 'ACTIVE';
      _qrCodes[idx]['activatedAt'] = DateTime.now().toIso8601String();
      notifyListeners();
      await _saveToLocal();
    }

    // Try server sync
    try {
      if (!qrId.startsWith('local_')) {
        final response = await ApiService.activateQR(
          qrId: qrId,
          paymentId: paymentId ?? 'local_payment',
        );
        if (response['success'] == true) {
          return true;
        }
      }
    } catch (e) {
      // Activated locally
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // UPDATE QR DESIGN (re-design for different template)
  // ═══════════════════════════════════════════════════════════════

  Future<bool> updateQRDesign(String qrId, {
    String? templateType,
    String? purpose,
    Map<String, dynamic>? newCustomization,
  }) async {
    final idx = _qrCodes.indexWhere((q) => q['id'] == qrId);
    if (idx < 0) return false;

    if (templateType != null) _qrCodes[idx]['templateType'] = templateType;
    if (purpose != null) _qrCodes[idx]['purpose'] = purpose;
    if (newCustomization != null) _qrCodes[idx]['customization'] = newCustomization;

    notifyListeners();
    await _saveToLocal();

    // Try server
    try {
      if (!qrId.startsWith('local_')) {
        await ApiService.updateQRDesign(
          qrId: qrId,
          templateType: templateType,
          purpose: purpose,
          customization: newCustomization,
        );
      }
    } catch (e) {
      // Updated locally
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  void setCurrentQR(Map<String, dynamic> qr) {
    _currentQR = qr;
    notifyListeners();
  }

  void reset() {
    _selectedTemplate = null;
    _customPurpose = null;
    _customization = {};
    _currentQR = null;
    notifyListeners();
  }

  Future<void> clearAll() async {
    _qrCodes = [];
    _currentQR = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}