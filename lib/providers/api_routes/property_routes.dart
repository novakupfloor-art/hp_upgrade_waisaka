import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/models_property.dart';
import '../../config/api_base.dart';

/// Property Management Routes
class PropertyRoutes {
  /// Get list of properties (public)
  static Future<List<Property>> getProperties({
    int page = 1,
    int limit = 6,
    String? tipe,
  }) async {
    try {
      String url =
          '${ApiBase.apiBaseUrl}/mobile/properties?page=$page&limit=$limit';
      if (tipe != null && tipe.isNotEmpty) {
        url += '&tipe=$tipe';
      }
      debugPrint('📡 API Request: GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiBase.getHeaders(),
      );

      debugPrint('📥 API Response Status: ${response.statusCode}');
      debugPrint(
        '📥 API Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final properties = (data['data'] as List)
              .map((item) {
                try {
                  return Property.fromJson(item);
                } catch (e) {
                  debugPrint('❌ Error parsing property: $e');
                  debugPrint('Item data: $item');
                  return null;
                }
              })
              .whereType<Property>()
              .toList();
          debugPrint('✅ Successfully parsed ${properties.length} properties');
          return properties;
        } else {
          throw Exception(data['message'] ?? 'API returned success=false');
        }
      } else if (response.statusCode == 404) {
        throw Exception(
          'Endpoint tidak ditemukan (404). Periksa konfigurasi API.',
        );
      } else if (response.statusCode == 500) {
        throw Exception('Server error (500). Hubungi administrator.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error in getProperties: $e');
      rethrow;
    }
  }

  /// Get property detail by ID
  static Future<Property> getPropertyDetail(int id) async {
    try {
      debugPrint('📡 Fetching property detail for ID: $id');
      final url = '${ApiBase.baseUrl}/mobile/properties/$id';
      debugPrint('📡 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiBase.getHeaders(),
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Property.fromJson(data['data']);
        } else {
          throw Exception('API returned success=false: ${data['message']}');
        }
      }
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('❌ Error in getPropertyDetail: $e');
      rethrow;
    }
  }

  /// Search properties with filters
  static Future<List<Property>> searchProperties(
    Map<String, dynamic> filters,
  ) async {
    try {
      final uri = Uri.parse('${ApiBase.baseUrl}/mobile/properties/search')
          .replace(
            queryParameters: filters.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          );

      final response = await http.get(uri, headers: await ApiBase.getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => Property.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to search properties');
    } catch (e) {
      rethrow;
    }
  }

  /// Get properties owned by current user
  static Future<List<Property>> getMyProperties(int staffId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiBase.baseUrl}/mobile/control-panel/properties/properties/$staffId',
        ),
        headers: await ApiBase.getHeaders(auth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => Property.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load my properties');
    } catch (e) {
      rethrow;
    }
  }

  /// Get properties by staff ID (for staff panel)
  static Future<List<Property>> getStaffProperties(int staffId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiBase.baseUrl}/mobile/control-panel/properties/properties/$staffId',
        ),
        headers: await ApiBase.getHeaders(auth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => Property.fromJson(item))
              .toList();
        }
      }
      throw Exception('Failed to load staff properties');
    } catch (e) {
      rethrow;
    }
  }

  /// Add new property
  static Future<void> addProperty(
    Map<String, String> fields,
    List<String> imagePaths,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiBase.baseUrl}/mobile/control-panel/properties/create'),
      );

      request.headers.addAll(await ApiBase.getHeaders(auth: true));
      request.fields.addAll(fields);

      for (var path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath('gambar[]', path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to add property');
        }
      } else {
        throw Exception('Failed to add property: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update existing property
  static Future<void> updateProperty(
    int propertyId,
    String nama,
    String alamat,
    double harga,
    int lt,
    int lb,
    String tipe,
    int kamarTidur,
    int kamarMandi,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ApiBase.baseUrl}/mobile/control-panel/properties/update/$propertyId',
        ),
        headers: await ApiBase.getHeaders(auth: true),
        body: jsonEncode({
          'nama_property': nama,
          'alamat': alamat,
          'harga': harga,
          'lt': lt,
          'lb': lb,
          'tipe': tipe,
          'kamar_tidur': kamarTidur,
          'kamar_mandi': kamarMandi,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to update property');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete property
  static Future<bool> deleteProperty(int propertyId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiBase.baseUrl}/mobile/control-panel/properties/delete/$propertyId',
        ),
        headers: await ApiBase.getHeaders(auth: true),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generate AI Insight for property
  static Future<Map<String, dynamic>> generateAiInsight(int propertyId) async {
    try {
      debugPrint('🤖 Generating AI Insight for property ID: $propertyId');
      final url = '${ApiBase.apiBaseUrl}/mobile/property/ai/$propertyId';
      debugPrint('📡 URL: $url');

      // Create HTTP client with timeout
      // AI generation takes 10-13 seconds (3 AI calls + sleep delays)
      final client = http.Client();
      try {
        final response = await client
            .post(Uri.parse(url), headers: await ApiBase.getHeaders())
            .timeout(
              const Duration(
                seconds: 60,
              ), // Allow up to 60 seconds for AI generation
              onTimeout: () {
                throw Exception(
                  'AI generation timeout - proses memakan waktu terlalu lama. Silakan coba lagi.',
                );
              },
            );

        debugPrint('📥 Response Status: ${response.statusCode}');
        debugPrint('📥 Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            return data['data'];
          } else {
            throw Exception('API returned success=false: ${data['message']}');
          }
        }
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      } finally {
        client.close(); // Always close the client
      }
    } catch (e) {
      debugPrint('❌ Error in generateAiInsight: $e');
      rethrow;
    }
  }
}
