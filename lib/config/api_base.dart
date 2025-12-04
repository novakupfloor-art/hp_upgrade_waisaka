import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_config.dart';
import '../models/models_user.dart';

/// Base class containing shared utilities for all API routes
class ApiBase {
  static const storage = FlutterSecureStorage();

  /// Get authentication token from secure storage
  static Future<String?> getAuthToken() async {
    return await storage.read(key: 'token_auth');
  }

  /// Build headers for HTTP requests
  static Future<Map<String, String>> getHeaders({bool auth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getAuthToken();
      if (token != null) {
        headers['token_auth'] = token;
      }
    }

    return headers;
  }

  /// Save user data to secure storage
  static Future<void> saveUser(User user) async {
    await storage.write(
      key: 'user_data',
      value: jsonEncode({
        'id_user': user.idUser,
        'username': user.username,
        'nama': user.nama,
        'email': user.email,
        'akses_level': user.aksesLevel,
        'staff_id': user.staffId,
        'status_staff': user.statusStaff,
        'sisa_kuota_iklan': user.sisaKuotaIklan,
        'total_kuota_iklan': user.totalKuotaIklan,
        'gambar': user.gambar,
        'telepon': user.telepon,
      }),
    );
  }

  /// Get user data from secure storage
  static Future<User?> getUser() async {
    final data = await storage.read(key: 'user_data');
    if (data != null) {
      return User.fromJson(jsonDecode(data));
    }
    return null;
  }

  /// Clear all stored data (for logout)
  static Future<void> clearStorage() async {
    await storage.delete(key: 'token_auth');
    await storage.delete(key: 'user_data');
    await storage.delete(key: 'device_info');
    await storage.delete(key: 'login_date');
  }

  /// Get base URL for API calls
  static String get baseUrl => AppConfig.baseUrl;
  static String get apiBaseUrl => AppConfig.apiBaseUrl;
}
