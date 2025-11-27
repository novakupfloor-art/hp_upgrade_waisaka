import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../../models/models_user.dart';
import 'api_base.dart';

/// Authentication and User Management Routes
class AuthRoutes {
  /// Login with username and password
  static Future<User> login(String username, String password) async {
    try {
      // Get device info
      String deviceInfo = 'Unknown Device';
      try {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          deviceInfo = '${androidInfo.manufacturer} ${androidInfo.model}';
        } else if (Platform.isIOS) {
          final iosInfo = await DeviceInfoPlugin().iosInfo;
          deviceInfo = '${iosInfo.name} ${iosInfo.model}';
        }
      } catch (e) {
        debugPrint('Failed to get device info: $e');
      }

      final response = await http.post(
        Uri.parse('${ApiBase.baseUrl}/mobile/login'),
        headers: await ApiBase.getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'device_info': deviceInfo,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['token_auth'];
        await ApiBase.storage.write(key: 'token_auth', value: token);
        await ApiBase.storage.write(key: 'device_info', value: deviceInfo);
        await ApiBase.storage.write(
          key: 'login_date',
          value: DateTime.now().toString(),
        );

        final user = User.fromJson(data['data']['user']);
        await ApiBase.saveUser(user);

        return user;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout current user
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${ApiBase.baseUrl}/mobile/logout'),
        headers: await ApiBase.getHeaders(auth: true),
      );
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await ApiBase.clearStorage();
    }
  }

  /// Get current user from storage
  static Future<User?> getCurrentUser() async {
    return await ApiBase.getUser();
  }

  /// Sign up new user
  static Future<Map<String, dynamic>> signup({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? username,
    String? telepon,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiBase.baseUrl}/mobile/signup'),
        headers: await ApiBase.getHeaders(),
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'username': username ?? email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'telepon': telepon,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'verification_id': data['data']['verification_id'],
          'email': data['data']['email'],
        };
      } else {
        throw Exception(data['message'] ?? 'Pendaftaran gagal');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Request password reset
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiBase.baseUrl}/mobile/forgot-password'),
        headers: await ApiBase.getHeaders(),
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        throw Exception(data['message'] ?? 'Gagal mengirim email reset');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with token
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiBase.baseUrl}/mobile/reset-password'),
        headers: await ApiBase.getHeaders(),
        body: jsonEncode({
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        throw Exception(data['message'] ?? 'Gagal reset password');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  static Future<void> updateProfile(
    int idUser,
    String nama,
    String email,
    String username,
    String? telepon,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ApiBase.baseUrl}/mobile/control-panel/staff/profile/$idUser',
        ),
        headers: await ApiBase.getHeaders(auth: true),
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'username': username,
          'telepon': telepon ?? '',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update local user data
        final updatedUser = await ApiBase.getUser();
        if (updatedUser != null) {
          final newUser = User(
            idUser: updatedUser.idUser,
            username: username,
            nama: nama,
            email: email,
            aksesLevel: updatedUser.aksesLevel,
            staffId: updatedUser.staffId,
            statusStaff: updatedUser.statusStaff,
            sisaKuotaIklan: updatedUser.sisaKuotaIklan,
            totalKuotaIklan: updatedUser.totalKuotaIklan,
            gambar: updatedUser.gambar,
            telepon: telepon,
          );
          await ApiBase.saveUser(newUser);
        }
        return;
      } else {
        throw Exception(data['message'] ?? 'Gagal update profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Alternative register method (simpler version)
  static Future<void> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiBase.baseUrl}/mobile/signup'),
        headers: await ApiBase.getHeaders(),
        body: jsonEncode({
          'nama': name,
          'email': email,
          'telepon': phone,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
