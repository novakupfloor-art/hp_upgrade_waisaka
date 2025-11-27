import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/models_property.dart';
import 'api_base.dart';

/// AI Waisaka Search Routes
class AiSearchRoutes {
  /// Search properties using AI Waisaka
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
      final url = '${ApiBase.apiBaseUrl}/ai-waisaka/search';

      debugPrint('🤖 AI Search: POST $url');

      final filters = <String, dynamic>{
        'listingType': listingType,
        if (location != null && location.isNotEmpty) 'location': location,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (minLandArea != null) 'minLandArea': minLandArea,
        if (maxLandArea != null) 'maxLandArea': maxLandArea,
        if (minBuildingArea != null) 'minBuildingArea': minBuildingArea,
        if (maxBuildingArea != null) 'maxBuildingArea': maxBuildingArea,
        if (bedrooms != null) 'bedrooms': bedrooms,
        if (bathrooms != null) 'bathrooms': bathrooms,
        if (propertyType != null) 'propertyType': propertyType,
        if (certificate != null) 'certificate': certificate,
        if (categoryId != null) 'categoryId': categoryId,
        if (provinceId != null) 'provinceId': provinceId,
        if (districtId != null) 'districtId': districtId,
        if (subDistrictId != null) 'subDistrictId': subDistrictId,
        // Ensure keywords are passed as 'query' or 'keywords' depending on backend expectation.
        // Based on typical AI search, 'query' is often used for the natural language part.
        // We'll send both to be safe or stick to 'keywords' if that's what was there.
        // User asked for "text yang rumit" (complex text) to be handled better.
        // We'll ensure it's passed as a distinct field.
        if (keywords != null && keywords.isNotEmpty) 'keywords': keywords,
        if (keywords != null && keywords.isNotEmpty) 'query': keywords,
      };

      debugPrint('📝 Filters: $filters');

      final response = await http.post(
        Uri.parse(url),
        headers: await ApiBase.getHeaders(),
        body: jsonEncode({'filters': filters}),
      );

      debugPrint('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<Property> properties = (data['data'] as List)
              .map((json) => Property.fromJson(json))
              .toList();

          debugPrint('✅ Found ${properties.length} properties');

          return {
            'success': true,
            'properties': properties,
            'metadata': data['search_metadata'],
          };
        } else {
          throw Exception(data['message'] ?? 'Search failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to search properties');
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
