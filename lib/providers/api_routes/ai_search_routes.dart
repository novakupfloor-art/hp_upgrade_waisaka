import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/models_property.dart';
import '../../config/api_base.dart';

/// AI Waisaka Search Routes
class AiSearchRoutes {
  /// Search properties using AI Waisaka
  /// Search properties using AI Waisaka
  ///
  /// This method now delegates to PropertySearchRoutes.searchProperties to ensure
  /// consistent parameter mapping and reuse the fixed search logic.
  static Future<Map<String, dynamic>> searchWithAi({
    required String listingType, // 'jual' or 'sewa'
    String? location,
    double? minPrice,
    double? maxPrice,
    double? minLandArea,
    double? maxLandArea,
    double? minBuildingArea,
    double? maxBuildingArea,
    int? bedrooms,
    int? bathrooms,
    String? propertyType,
    String? certificate,
    int? categoryId,
    int? provinceId,
    int? districtId,
    int? subDistrictId,
    String? keywords,
  }) async {
    try {
      debugPrint('🤖 AI Search: Calling Real Endpoint /ai-waisaka/search');

      final url = '${ApiBase.apiBaseUrl}/ai-waisaka/search';
      final headers = await ApiBase.getHeaders();

      final filters = {
        'listingType': listingType,
        'keywords': keywords,
        'location': location,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'minLandArea': minLandArea,
        'maxLandArea': maxLandArea,
        'minBuildingArea': minBuildingArea,
        'maxBuildingArea': maxBuildingArea,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'propertyType': propertyType,
        'certificate': certificate,
        'categoryId': categoryId,
        'provinceId': provinceId,
        'districtId': districtId,
        'subDistrictId': subDistrictId,
      };

      // Remove null values
      filters.removeWhere((key, value) => value == null);

      final body = {'filters': filters};

      debugPrint('🤖 AI Search Request URL: $url');
      debugPrint('🤖 AI Search Request Headers: $headers');
      debugPrint('🤖 AI Search Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('🤖 AI Search Response Status: ${response.statusCode}');
      debugPrint('🤖 AI Search Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> propertiesData = data['data'] ?? [];
          final properties = propertiesData
              .map((json) => Property.fromJson(json))
              .toList();

          return {
            'success': true,
            'properties': properties,
            'metadata': data['metadata'],
          };
        } else {
          throw Exception(data['message'] ?? 'AI Search failed');
        }
      } else {
        throw Exception(
          'Failed to connect to AI Search (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('❌ AI Search Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'properties': <Property>[],
      };
    }
  }

  /// Get search suggestions
  static Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.length < 2) return [];

      final url = '${ApiBase.apiBaseUrl}/ai-waisaka/suggestions';

      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {'q': query}),
        headers: await ApiBase.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['data'] ?? []);
        }
      }

      return [];
    } catch (e) {
      debugPrint('❌ Suggestions Error: $e');
      return [];
    }
  }
}
