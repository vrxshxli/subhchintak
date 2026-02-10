import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QRProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _qrCodes = [];
  Map<String, dynamic>? _currentQR;
  String? _selectedTemplate;
  String? _customPurpose;
  Map<String, dynamic> _customization = {};

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get qrCodes => _qrCodes;
  Map<String, dynamic>? get currentQR => _currentQR;
  String? get selectedTemplate => _selectedTemplate;
  String? get customPurpose => _customPurpose;
  Map<String, dynamic> get customization => _customization;

  bool get hasActiveQR => _qrCodes.any((qr) => qr['status'] == 'active');

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

  Future<void> loadQRCodes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.getUserQRs();
      if (response['success'] == true) {
        _qrCodes = List<Map<String, dynamic>>.from(response['qrCodes'] ?? []);
      }
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createQR() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.createQR(
        purpose: _customPurpose ?? _selectedTemplate ?? 'general',
        templateType: _selectedTemplate ?? 'custom',
        customization: _customization,
      );
      if (response['success'] == true) {
        _currentQR = response['qr'];
        _qrCodes.add(response['qr']);
        _isLoading = false;
        notifyListeners();
        return response['qr'];
      }
    } catch (e) {
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> activateQR(String qrId, String paymentId) async {
    try {
      final response = await ApiService.activateQR(qrId: qrId, paymentId: paymentId);
      if (response['success'] == true) {
        final idx = _qrCodes.indexWhere((q) => q['id'] == qrId);
        if (idx >= 0) {
          _qrCodes[idx]['status'] = 'active';
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  void reset() {
    _selectedTemplate = null;
    _customPurpose = null;
    _customization = {};
    _currentQR = null;
    notifyListeners();
  }
}