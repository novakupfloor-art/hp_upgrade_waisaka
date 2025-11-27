import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PhoneUtils {
  /// Request phone call permission
  static Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  /// Make a phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      // Clean phone number - remove non-digit characters
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create phone URI
      final uri = Uri(scheme: 'tel', path: cleanNumber);

      // Check if phone call is supported
      if (await canLaunchUrl(uri)) {
        // Request permission on Android
        if (await requestPhonePermission()) {
          return await launchUrl(uri);
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error making phone call: $e');
      return false;
    }
  }

  /// Open WhatsApp with message
  static Future<bool> openWhatsApp(
    String phoneNumber, {
    String? message,
  }) async {
    try {
      // Clean phone number - remove non-digit characters and plus if present
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      // Add country code if not present (assuming Indonesia)
      if (!cleanNumber.startsWith('0')) {
        cleanNumber = '62$cleanNumber';
      } else if (cleanNumber.startsWith('0')) {
        cleanNumber = '62${cleanNumber.substring(1)}';
      }

      // Create WhatsApp message
      final whatsappMessage =
          message ??
          'Halo, saya tertarik dengan properti yang Anda tawarkan. Mohon informasi lebih lanjut.';
      final encodedMessage = Uri.encodeComponent(whatsappMessage);

      // Create WhatsApp URI
      final uri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: cleanNumber,
        query: 'text=$encodedMessage',
      );

      // Check if WhatsApp is supported
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
      return false;
    }
  }

  /// Open WhatsApp with property details
  static Future<bool> openWhatsAppForProperty(
    String phoneNumber, {
    required String propertyName,
    required String propertyPrice,
    required String propertyAddress,
  }) async {
    final message =
        '''
Halo, saya tertarik dengan properti berikut:

🏠 *$propertyName*
💰 Harga: $propertyPrice
📍 Lokasi: $propertyAddress

Mohon informasi lebih lanjut mengenai properti ini. Terima kasih!
    ''';

    return openWhatsApp(phoneNumber, message: message);
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanNumber.isEmpty) return phoneNumber;

    // Format Indonesia phone number
    if (cleanNumber.startsWith('+62')) {
      final number = cleanNumber.substring(3);
      if (number.length >= 9) {
        return '+62 ${number.substring(0, 3)}-${number.substring(3, 6)}-${number.substring(6)}';
      }
      return '+62 $number';
    } else if (cleanNumber.startsWith('0')) {
      final number = cleanNumber.substring(1);
      if (number.length >= 9) {
        return '0${number.substring(0, 3)}-${number.substring(3, 6)}-${number.substring(6)}';
      }
      return '0$number';
    }

    return phoneNumber;
  }

  /// Validate phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return cleanNumber.length >= 10 && cleanNumber.length <= 15;
  }
}
