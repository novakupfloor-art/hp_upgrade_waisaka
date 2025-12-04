import 'package:flutter/material.dart';
import '../models/models_property.dart';
import 'api_routes/property_routes.dart';
import 'api_routes/property_search_routes.dart';
import 'api_routes/ai_search_routes.dart';
import 'dart:developer' as developer;

enum ViewState { idle, loading, success, error }

class PropertyProvider extends ChangeNotifier {
  ViewState _viewState = ViewState.idle;
  List<Property> _properties = [];
  String _errorMessage = '';
  String _errorDetails = ''; // For debugging

  ViewState get viewState => _viewState;
  List<Property> get properties => _properties;
  String get errorMessage => _errorMessage;
  String get errorDetails => _errorDetails;

  bool get isLoading => _viewState == ViewState.loading;
  bool get hasError => _viewState == ViewState.error;
  bool get hasData => _properties.isNotEmpty;

  Future<void> loadProperties({
    int page = 1,
    int limit = 6,
    String? listingType,
    bool append = false,
  }) async {
    developer.log(
      '🔄 Loading properties (type: $listingType, page: $page, append: $append)...',
      name: 'PropertyProvider',
    );
    if (!append) {
      _setViewState(ViewState.loading);
    }

    try {
      developer.log(
        '📡 Calling API: getProperties(page: $page, limit: $limit, type: $listingType)',
        name: 'PropertyProvider',
      );

      final properties = await PropertyRoutes.getProperties(
        page: page,
        limit: limit,
        tipe: listingType,
      );

      developer.log(
        '✅ Received ${properties.length} properties from API',
        name: 'PropertyProvider',
      );

      if (append) {
        _properties.addAll(properties.take(limit));
      } else {
        _properties = properties.take(limit).toList();
      }

      _errorMessage = '';
      _errorDetails = '';
      _setViewState(ViewState.success);

      developer.log(
        '✅ Properties loaded successfully: ${_properties.length} items',
        name: 'PropertyProvider',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error loading properties',
        name: 'PropertyProvider',
        error: e,
        stackTrace: stackTrace,
      );

      // Categorize error for better user feedback
      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        _errorMessage =
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        _errorDetails = 'Network Error: ${e.toString()}';
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('type') ||
          e.toString().contains('Unexpected character')) {
        _errorMessage = 'Format data tidak valid. Hubungi administrator.';
        _errorDetails = 'Parsing Error: ${e.toString()}';
      } else if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'Koneksi timeout. Coba lagi.';
        _errorDetails = 'Timeout Error: ${e.toString()}';
      } else {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _errorDetails =
            'Error: ${e.toString()}\nStackTrace: ${stackTrace.toString()}';
      }

      _setViewState(ViewState.error);
    }
  }

  Future<void> refreshProperties({String? listingType}) async {
    developer.log('🔄 Refreshing properties...', name: 'PropertyProvider');
    await loadProperties(listingType: listingType);
  }

  void _setViewState(ViewState state) {
    developer.log(
      '📊 State changed: $_viewState → $state',
      name: 'PropertyProvider',
    );
    _viewState = state;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _errorDetails = '';
    _setViewState(ViewState.idle);
  }

  // Advanced search methods
  Future<void> searchPropertiesWithFilters({
    String? keyword,
    String? listingType,
    String? categoryId,
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
    int page = 1,
    int limit = 9,
    String? order,
  }) async {
    developer.log('🔍 Advanced property search...', name: 'PropertyProvider');
    _setViewState(ViewState.loading);

    try {
      final result = await PropertySearchRoutes.searchProperties(
        keyword: keyword,
        tipe: listingType,
        idKategoriProperty: categoryId,
        location: location,
        priceFrom: priceFrom,
        priceTo: priceTo,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        landSizeFrom: landSizeFrom,
        landSizeTo: landSizeTo,
        buildingSizeFrom: buildingSizeFrom,
        buildingSizeTo: buildingSizeTo,
        certificates: certificates,
        page: page,
        limit: limit,
        order: order,
      );

      if (result['success'] == true) {
        _properties = result['properties'] as List<Property>;
        _setViewState(ViewState.success);
        developer.log(
          '✅ Search successful: ${_properties.length} properties found',
          name: 'PropertyProvider',
        );
      } else {
        _errorMessage = result['error'] ?? 'Search failed';
        _errorDetails = result.toString();
        _setViewState(ViewState.error);
        developer.log(
          '❌ Search failed: $_errorMessage',
          name: 'PropertyProvider',
        );
      }
    } catch (e) {
      _errorMessage = 'Search failed: ${e.toString()}';
      _errorDetails = e.toString();
      _setViewState(ViewState.error);
      developer.log('💥 Search error: $e', name: 'PropertyProvider');
    }
  }

  Future<List<Map<String, String>>> getLocationSuggestions(String query) async {
    try {
      return await PropertySearchRoutes.getLocationSuggestions(query);
    } catch (e) {
      developer.log('❌ Location search error: $e', name: 'PropertyProvider');
      return [];
    }
  }

  /// Search properties using AI Waisaka
  Future<void> searchWithAi({
    required String listingType,
    String? keywords,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    String? propertyType,
    String? certificate,
    double? minLandArea,
    double? maxLandArea,
    double? minBuildingArea,
    double? maxBuildingArea,
  }) async {
    developer.log('🤖 AI Search initiated', name: 'PropertyProvider');
    _setViewState(ViewState.loading);

    try {
      final result = await AiSearchRoutes.searchWithAi(
        listingType: listingType,
        keywords: keywords,
        location: location,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        propertyType: propertyType,
        certificate: certificate,
        minLandArea: minLandArea,
        maxLandArea: maxLandArea,
        minBuildingArea: minBuildingArea,
        maxBuildingArea: maxBuildingArea,
      );

      if (result['success'] == true) {
        _properties = result['properties'] as List<Property>;
        _errorMessage = '';
        _errorDetails = '';
        _setViewState(ViewState.success);
        developer.log(
          '✅ AI Search successful: ${_properties.length} properties found',
          name: 'PropertyProvider',
        );
      } else {
        _errorMessage = result['error'] ?? 'AI Search failed';
        _errorDetails = result.toString();
        _setViewState(ViewState.error);
        developer.log(
          '❌ AI Search failed: $_errorMessage',
          name: 'PropertyProvider',
        );
      }
    } catch (e) {
      _errorMessage = 'AI Search failed: ${e.toString()}';
      _errorDetails = e.toString();
      _setViewState(ViewState.error);
      developer.log('💥 AI Search error: $e', name: 'PropertyProvider');
    }
  }

  Map<String, dynamic> getFilterOptions() {
    return PropertySearchRoutes.getFilterOptions();
  }
}
