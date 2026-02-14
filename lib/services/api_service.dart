import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://subhchintak-api.onrender.com/api';
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async => await _storage.read(key: 'auth_token');
  static Future<void> setToken(String token) async => await _storage.write(key: 'auth_token', value: token);
  static Future<void> removeToken() async => await _storage.delete(key: 'auth_token');

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth) { final t = await getToken(); if (t != null) h['Authorization'] = 'Bearer $t'; }
    return h;
  }

  static Future<Map<String, dynamic>> _post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final r = await http.post(Uri.parse('$baseUrl$path'), headers: await _headers(auth: auth), body: body != null ? jsonEncode(body) : null);
    return jsonDecode(r.body);
  }
  static Future<Map<String, dynamic>> _get(String path) async {
    final r = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    return jsonDecode(r.body);
  }
  static Future<Map<String, dynamic>> _put(String path, {Map<String, dynamic>? body}) async {
    final r = await http.put(Uri.parse('$baseUrl$path'), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    return jsonDecode(r.body);
  }
  static Future<Map<String, dynamic>> _delete(String path) async {
    final r = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
    return jsonDecode(r.body);
  }

  // ─── AUTH ───
  static Future<Map<String, dynamic>> register({required String name, required String email, required String password, required String phone}) =>
      _post('/auth/register', body: {'name': name, 'email': email, 'password': password, 'phone': phone}, auth: false);
  static Future<Map<String, dynamic>> login({required String email, required String password}) =>
      _post('/auth/login', body: {'email': email, 'password': password}, auth: false);
  static Future<Map<String, dynamic>> googleSignIn({required String idToken}) =>
      _post('/auth/google', body: {'idToken': idToken}, auth: false);
  static Future<Map<String, dynamic>> getProfile() => _get('/auth/profile');

  // ─── QR ───
  static Future<Map<String, dynamic>> generateQR() => _post('/qr/generate');
  static Future<Map<String, dynamic>> getMyQR() => _get('/qr/my-qr');
  static Future<Map<String, dynamic>> getUserQRs() => _get('/qr/my-qrs');

  // ─── TAG DESIGNS ───
  static Future<Map<String, dynamic>> saveTagDesign({required String purpose, String? customPurpose, required String templateType, Map<String, dynamic>? customization}) =>
      _post('/qr/tags', body: {'purpose': purpose, 'customPurpose': customPurpose, 'templateType': templateType, 'customization': customization});
  static Future<Map<String, dynamic>> getTagDesigns() => _get('/qr/tags');
  static Future<Map<String, dynamic>> deleteTagDesign(String id) => _delete('/qr/tags/$id');

  // ─── ADDRESSES ───
  static Future<Map<String, dynamic>> getAddresses() => _get('/qr/addresses');
  static Future<Map<String, dynamic>> saveAddress(Map<String, dynamic> addr) => _post('/qr/addresses', body: addr);
  static Future<Map<String, dynamic>> updateAddress(String id, Map<String, dynamic> data) => _put('/qr/addresses/$id', body: data);
  static Future<Map<String, dynamic>> deleteAddress(String id) => _delete('/qr/addresses/$id');

  // ─── STICKER ORDERS ───
  static Future<Map<String, dynamic>> createStickerOrder({required String addressId, required List<Map<String, dynamic>> items}) =>
      _post('/qr/sticker-order', body: {'addressId': addressId, 'items': items});
  static Future<Map<String, dynamic>> payStickerOrder(String orderId, String paymentId) =>
      _post('/qr/sticker-order/$orderId/pay', body: {'paymentId': paymentId});
  static Future<Map<String, dynamic>> getStickerOrders() => _get('/qr/sticker-orders');

  // ─── EMERGENCY CONTACTS ───
  static Future<Map<String, dynamic>> getEmergencyContacts() => _get('/emergency/contacts');
  static Future<Map<String, dynamic>> addEmergencyContact({required String name, required String phone, required String relation, required int priority}) =>
      _post('/emergency/contacts', body: {'name': name, 'phone': phone, 'relation': relation, 'priority': priority});
  static Future<Map<String, dynamic>> bulkAddEmergencyContacts({required List<Map<String, String>> contacts}) =>
      _post('/emergency/contacts/bulk', body: {'contacts': contacts});
  static Future<Map<String, dynamic>> updateEmergencyContact({required String id, String? name, String? phone, String? relation, int? priority}) {
    final b = <String, dynamic>{}; if (name != null) b['name'] = name; if (phone != null) b['phone'] = phone; if (relation != null) b['relation'] = relation; if (priority != null) b['priority'] = priority;
    return _put('/emergency/contacts/$id', body: b);
  }
  static Future<Map<String, dynamic>> reorderEmergencyContacts({required List<String> orderedIds}) =>
      _put('/emergency/contacts/reorder', body: {'orderedIds': orderedIds});
  static Future<Map<String, dynamic>> removeEmergencyContact(String id) => _delete('/emergency/contacts/$id');

  // ─── CHAT ───
  static Future<Map<String, dynamic>> getChatSessions() => _get('/chat/sessions');
  static Future<Map<String, dynamic>> getChatMessages(String sessionId) => _get('/chat/messages/$sessionId');

  // ─── NOTIFICATIONS ───
  static Future<Map<String, dynamic>> getUpdates() => _get('/updates');

  // ─── PAYMENTS ───
  static Future<Map<String, dynamic>> createOrder({required String qrId, required String orderType, required double amount}) =>
      _post('/payment/create-order', body: {'qrId': qrId, 'orderType': orderType, 'amount': amount});
  static Future<Map<String, dynamic>> verifyPayment({required String orderId, required String paymentId, required String signature}) =>
      _post('/payment/verify', body: {'orderId': orderId, 'paymentId': paymentId, 'signature': signature});

  // Legacy compat
  static Future<Map<String, dynamic>> createQR({required String purpose, required String templateType, Map<String, dynamic>? customization}) =>
      saveTagDesign(purpose: purpose, templateType: templateType, customization: customization);
  static Future<Map<String, dynamic>> activateQR({required String qrId, required String paymentId}) async => {'success': true};
  static Future<Map<String, dynamic>> updateQRDesign({required String qrId, String? templateType, String? purpose, Map<String, dynamic>? customization}) =>
      saveTagDesign(purpose: purpose ?? 'Custom', templateType: templateType ?? 'custom', customization: customization);
}