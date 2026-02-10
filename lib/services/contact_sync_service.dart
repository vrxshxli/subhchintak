import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactSyncService {
  /// Request contacts permission and return granted status
  static Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  /// Check if contacts permission is already granted
  static Future<bool> hasPermission() async {
    return await Permission.contacts.isGranted;
  }

  /// Fetch all device contacts with phone numbers
  /// Returns a list of maps with 'name' and 'phone' keys
  static Future<List<Map<String, String>>> fetchDeviceContacts() async {
    final hasAccess = await hasPermission();
    if (!hasAccess) {
      final granted = await requestPermission();
      if (!granted) return [];
    }

    try {
      // Fetch contacts with phone numbers
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      final List<Map<String, String>> result = [];

      for (final contact in contacts) {
        if (contact.phones.isNotEmpty) {
          // Take the first phone number
          String phone = contact.phones.first.number;
          // Clean up the phone number - remove spaces, dashes
          phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

          // Add +91 prefix if not present (Indian numbers)
          if (!phone.startsWith('+')) {
            if (phone.startsWith('0')) {
              phone = '+91${phone.substring(1)}';
            } else if (phone.length == 10) {
              phone = '+91$phone';
            }
          }

          result.add({
            'name': contact.displayName,
            'phone': phone,
            'relation': '', // User can set this later
          });
        }
      }

      // Sort alphabetically by name
      result.sort((a, b) => a['name']!.compareTo(b['name']!));
      return result;
    } catch (e) {
      return [];
    }
  }

  /// Search contacts by name
  static Future<List<Map<String, String>>> searchContacts(String query) async {
    final allContacts = await fetchDeviceContacts();
    if (query.isEmpty) return allContacts;

    return allContacts.where((c) {
      return c['name']!.toLowerCase().contains(query.toLowerCase()) ||
          c['phone']!.contains(query);
    }).toList();
  }
}