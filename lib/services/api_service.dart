import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://subhchintak-api.onrender.com/api';
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── AUTH ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String name, required String email,
    required String password, required String phone,
  }) async {
    final response = await http.post(Uri.parse('$baseUrl/auth/register'),
        headers: await _headers(auth: false),
        body: jsonEncode({'name': name, 'email': email, 'password': password, 'phone': phone}));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: await _headers(auth: false), body: jsonEncode({'email': email, 'password': password}));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> googleSignIn({required String idToken}) async {
    final response = await http.post(Uri.parse('$baseUrl/auth/google'),
        headers: await _headers(auth: false), body: jsonEncode({'idToken': idToken}));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/auth/profile'), headers: await _headers());
    return jsonDecode(response.body);
  }

  // ─── QR CODES ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createQR({
    required String purpose, required String templateType,
    Map<String, dynamic>? customization,
  }) async {
    final response = await http.post(Uri.parse('$baseUrl/qr/create'), headers: await _headers(),
        body: jsonEncode({'purpose': purpose, 'templateType': templateType, 'customization': customization}));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserQRs() async {
    final response = await http.get(Uri.parse('$baseUrl/qr/my-qrs'), headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> activateQR({required String qrId, required String paymentId}) async {
    final response = await http.post(Uri.parse('$baseUrl/qr/activate'), headers: await _headers(),
        body: jsonEncode({'qrId': qrId, 'paymentId': paymentId}));
    return jsonDecode(response.body);
  }

  /// Update QR design (re-design for different template)
  static Future<Map<String, dynamic>> updateQRDesign({
    required String qrId, String? templateType, String? purpose,
    Map<String, dynamic>? customization,
  }) async {
    final body = <String, dynamic>{};
    if (templateType != null) body['templateType'] = templateType;
    if (purpose != null) body['purpose'] = purpose;
    if (customization != null) body['customization'] = customization;

    final response = await http.put(Uri.parse('$baseUrl/qr/update/$qrId'),
        headers: await _headers(), body: jsonEncode(body));
    return jsonDecode(response.body);
  }

  // ─── EMERGENCY CONTACTS ────────────────────────────────────────

  static Future<Map<String, dynamic>> getEmergencyContacts() async {
    final response = await http.get(Uri.parse('$baseUrl/emergency/contacts'), headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addEmergencyContact({
    required String name, required String phone, required String relation, required int priority,
  }) async {
    final response = await http.post(Uri.parse('$baseUrl/emergency/contacts'), headers: await _headers(),
        body: jsonEncode({'name': name, 'phone': phone, 'relation': relation, 'priority': priority}));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> bulkAddEmergencyContacts({required List<Map<String, String>> contacts}) async {
    final response = await http.post(Uri.parse('$baseUrl/emergency/contacts/bulk'),
        headers: await _headers(), body: jsonEncode({'contacts': contacts}));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateEmergencyContact({
    required String id, String? name, String? phone, String? relation, int? priority,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (relation != null) body['relation'] = relation;
    if (priority != null) body['priority'] = priority;
    final response = await http.put(Uri.parse('$baseUrl/emergency/contacts/$id'),
        headers: await _headers(), body: jsonEncode(body));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> reorderEmergencyContacts({required List<String> orderedIds}) async {
    final response = await http.put(Uri.parse('$baseUrl/emergency/contacts/reorder'),
        headers: await _headers(), body: jsonEncode({'orderedIds': orderedIds}));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeEmergencyContact(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/emergency/contacts/$id'), headers: await _headers());
    return jsonDecode(response.body);
  }

  // ─── CHAT ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getChatSessions() async {
    final response = await http.get(Uri.parse('$baseUrl/chat/sessions'), headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getChatMessages(String sessionId) async {
    final response = await http.get(Uri.parse('$baseUrl/chat/messages/$sessionId'), headers: await _headers());
    return jsonDecode(response.body);
  }

  // ─── NOTIFICATIONS ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> getUpdates() async {
    final response = await http.get(Uri.parse('$baseUrl/updates'), headers: await _headers());
    return jsonDecode(response.body);
  }

  // ─── PAYMENTS ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createOrder({
    required String qrId, required String orderType, required double amount,
  }) async {
    final response = await http.post(Uri.parse('$baseUrl/payment/create-order'), headers: await _headers(),
        body: jsonEncode({'qrId': qrId, 'orderType': orderType, 'amount': amount}));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId, required String paymentId, required String signature,
  }) async {
    final response = await http.post(Uri.parse('$baseUrl/payment/verify'), headers: await _headers(),
        body: jsonEncode({'orderId': orderId, 'paymentId': paymentId, 'signature': signature}));
    return jsonDecode(response.body);
  }
}