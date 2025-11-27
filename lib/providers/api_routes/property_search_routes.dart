import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/models_property.dart';
import 'api_base.dart';

/// Advanced Property Search Routes (matching waisakaproperty.com)
class PropertySearchRoutes {
  /// Search properties with comprehensive filters (matching web search)
  static Future<Map<String, dynamic>> searchProperties({
    String? keyword,
    String? tipe, // 'jual' or 'sewa'
    String? idKategoriProperty,
    String? location,
    String? priceFrom,
    String? priceTo,
    String? bedrooms,
    String? bathrooms,
    String? landSizeFrom,
    String? landSizeTo,
    String? buildingSizeFrom,
    String? buildingSizeTo,
    String? certificates,
    int? page,
    int? limit,
    String? order, // 'newest', 'price_desc', 'price_asc'
  }) async {
    try {
      // Build URL based on web search pattern
      // Use the correct API endpoint defined in api.php
      final url = '${ApiBase.apiBaseUrl}/mobile/properties/search';

      debugPrint('🔍 Property Search: GET $url');
      debugPrint(
        '📝 Search Parameters: ${{'keyword': keyword, 'tipe': tipe, 'id_kategori_property': idKategoriProperty, 'location': location, 'price_from': priceFrom, 'price_to': priceTo, 'bedrooms': bedrooms, 'bathrooms': bathrooms, 'landsize_from': landSizeFrom, 'landsize_to': landSizeTo, 'buildingsize_from': buildingSizeFrom, 'buildingsize_to': buildingSizeTo, 'certificates': certificates, 'page': page ?? 1, 'limit': limit ?? 9, 'order': order ?? 'newest'}}',
      );

      final response = await http.get(
        Uri.parse(url).replace(
          queryParameters: {
            if (keyword != null && keyword.isNotEmpty) 'q': keyword,
            if (tipe != null) 'tipe': tipe,
            if (idKategoriProperty != null)
              'id_kategori_property': idKategoriProperty,
            if (location != null && location.isNotEmpty) 'location': location,
            if (priceFrom != null && priceFrom.isNotEmpty)
              'price_from': priceFrom,
            if (priceTo != null && priceTo.isNotEmpty) 'price_to': priceTo,
            if (bedrooms != null && bedrooms.isNotEmpty) 'bedrooms': bedrooms,
            if (bathrooms != null && bathrooms.isNotEmpty)
              'bathrooms': bathrooms,
            if (landSizeFrom != null && landSizeFrom.isNotEmpty)
              'landsize_from': landSizeFrom,
            if (landSizeTo != null && landSizeTo.isNotEmpty)
              'landsize_to': landSizeTo,
            if (buildingSizeFrom != null && buildingSizeFrom.isNotEmpty)
              'buildingsize_from': buildingSizeFrom,
            if (buildingSizeTo != null && buildingSizeTo.isNotEmpty)
              'buildingsize_to': buildingSizeTo,
            if (certificates != null && certificates.isNotEmpty)
              'certificates': certificates,
            if (page != null) 'page': page.toString(),
            if (limit != null) 'limit': limit.toString(),
            if (order != null) 'order': order,
          },
        ),
        headers: await ApiBase.getHeaders(),
      );

      debugPrint('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle different response formats
        List<Property> properties = [];
        Map<String, dynamic>? pagination;

        if (data['data'] != null) {
          final propertiesData = data['data'] is List
              ? data['data']
              : (data['data']['data'] ?? []);

          properties = propertiesData.map<Property>((json) {
            return Property.fromJson(
              json is Map<String, dynamic> ? json : json['property'] ?? {},
            );
          }).toList();

          // Extract pagination info if available
          if (data['data'] is Map<String, dynamic>) {
            final dataMap = data['data'] as Map<String, dynamic>;
            pagination = {
              'current_page': dataMap['current_page'] ?? 1,
              'last_page': dataMap['last_page'] ?? 1,
              'per_page': dataMap['per_page'] ?? limit ?? 9,
              'total': dataMap['total'] ?? properties.length,
            };
          }
        }

        debugPrint('✅ Found ${properties.length} properties');

        return {
          'success': true,
          'properties': properties,
          'pagination':
              pagination ??
              {
                'current_page': page ?? 1,
                'last_page': 1,
                'per_page': limit ?? 9,
                'total': properties.length,
              },
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to search properties');
      }
    } catch (e) {
      debugPrint('❌ Property Search Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'properties': <Property>[],
      };
    }
  }

  /// Get location suggestions (matching listing/location endpoint)
  static Future<List<Map<String, String>>> getLocationSuggestions(
    String query,
  ) async {
    try {
      final url = '${ApiBase.baseUrl}/listing/location';

      debugPrint('📍 Location Search: GET $url?q=$query');

      final response = await http.get(
        Uri.parse(url).replace(queryParameters: {'q': query.toLowerCase()}),
        headers: await ApiBase.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((item) {
          return {
            'kabupaten': (item[0] ?? '').toString(),
            'provinsi': (item[1] ?? '').toString(),
            'full_address': '${item[0]}, ${item[1]}',
          };
        }).toList();
      } else {
        throw Exception('Failed to get location suggestions');
      }
    } catch (e) {
      debugPrint('❌ Location Search Error: $e');
      return [];
    }
  }

  /// Get filter options (price ranges, bedroom counts, etc.)
  static Map<String, dynamic> getFilterOptions() {
    return {
      'price_ranges': [
        {'label': '< 50 Juta', 'min': '0', 'max': '50000000'},
        {'label': '50-100 Juta', 'min': '50000000', 'max': '100000000'},
        {'label': '100-500 Juta', 'min': '100000000', 'max': '500000000'},
        {'label': '500M - 1 M', 'min': '500000000', 'max': '1000000000'},
        {'label': '1-3 M', 'min': '1000000000', 'max': '3000000000'},
        {'label': '3-5 M', 'min': '3000000000', 'max': '5000000000'},
        {'label': '5-7 M', 'min': '5000000000', 'max': '7000000000'},
        {'label': '7-10 M', 'min': '7000000000', 'max': '10000000000'},
        {'label': '10-15 M', 'min': '10000000000', 'max': '15000000000'},
        {'label': '15-20 M', 'min': '15000000000', 'max': '20000000000'},
        {'label': '20-30 M', 'min': '20000000000', 'max': '30000000000'},
        {'label': '30-50 M', 'min': '30000000000', 'max': '50000000000'},
        {'label': '50-75 M', 'min': '50000000000', 'max': '75000000000'},
        {'label': '> 75 M', 'min': '75000000000', 'max': ''},
      ],
      'bedroom_options': ['1', '2', '3', '4', '5+'],
      'bathroom_options': ['1', '2', '3', '4', '5', '6', '7+'],
      'certificate_options': [
        {'value': 'SHM', 'label': 'SHM - Sertifikat Hak Milik'},
        {'value': 'HGB', 'label': 'HGB - Hak Guna Bangunan'},
        {'value': 'other', 'label': 'Lainnya (PPJB, Girik, Adat, dll)'},
      ],
      'sort_options': [
        {'value': 'newest', 'label': 'Terbaru'},
        {'value': 'price_desc', 'label': 'Harga Tertinggi'},
        {'value': 'price_asc', 'label': 'Harga Terendah'},
      ],
      'listing_types': [
        {'value': 'jual', 'label': 'Dijual'},
        {'value': 'sewa', 'label': 'Disewa'},
      ],
      'limit_options': ['6', '9', '12', '18', '24'],
    };
  }

  /// Build search filters from form data
  static Map<String, dynamic> buildFilters({
    String? keyword,
    String? listingType,
    String? categoryId,
    String? location,
    String? priceRange,
    String? bedrooms,
    String? bathrooms,
    String? landSizeRange,
    String? buildingSizeRange,
    String? certificate,
    String? sortBy,
  }) {
    final filters = <String, dynamic>{};

    // Keyword search
    if (keyword != null && keyword.isNotEmpty) {
      filters['keyword'] = keyword;
    }

    // Listing type (jual/sewa)
    if (listingType != null) {
      filters['tipe'] = listingType;
    }

    // Category
    if (categoryId != null && categoryId.isNotEmpty) {
      filters['id_kategori_property'] = categoryId;
    }

    // Location
    if (location != null && location.isNotEmpty) {
      filters['location'] = location;
    }

    // Price range
    if (priceRange != null && priceRange.isNotEmpty) {
      final priceParts = priceRange.split('-');
      if (priceParts.length >= 2) {
        filters['price_from'] = priceParts[0];
        filters['price_to'] = priceParts[1];
      }
    }

    // Bedrooms
    if (bedrooms != null && bedrooms.isNotEmpty) {
      filters['bedrooms'] = bedrooms == '5+' ? '5+' : bedrooms;
    }

    // Bathrooms
    if (bathrooms != null && bathrooms.isNotEmpty) {
      filters['bathrooms'] = bathrooms == '7+' ? '7+' : bathrooms;
    }

    // Land size
    if (landSizeRange != null && landSizeRange.isNotEmpty) {
      final sizeParts = landSizeRange.split('-');
      if (sizeParts.length >= 2) {
        filters['landsize_from'] = sizeParts[0];
        filters['landsize_to'] = sizeParts[1];
      }
    }

    // Building size
    if (buildingSizeRange != null && buildingSizeRange.isNotEmpty) {
      final sizeParts = buildingSizeRange.split('-');
      if (sizeParts.length >= 2) {
        filters['buildingsize_from'] = sizeParts[0];
        filters['buildingsize_to'] = sizeParts[1];
      }
    }

    // Certificate
    if (certificate != null && certificate.isNotEmpty) {
      filters['certificates'] = certificate;
    }

    // Sort
    if (sortBy != null) {
      filters['order'] = sortBy;
    }

    return filters;
  }
}
