import 'package:flutter/material.dart';
import '../models/models_article.dart';
import 'api_routes/article_routes.dart';
import 'dart:developer' as developer;

enum ViewState { idle, loading, success, error }

class ArticleProvider extends ChangeNotifier {
  ViewState _viewState = ViewState.idle;
  List<Article> _articles = [];
  List<Article> _latestArticles = [];
  String _errorMessage = '';
  String _errorDetails = ''; // For debugging

  ViewState get viewState => _viewState;
  List<Article> get articles => _articles;
  List<Article> get latestArticles => _latestArticles;
  String get errorMessage => _errorMessage;
  String get errorDetails => _errorDetails;

  bool get isLoading => _viewState == ViewState.loading;
  bool get hasError => _viewState == ViewState.error;
  bool get hasData => _articles.isNotEmpty;
  bool get hasLatestData => _latestArticles.isNotEmpty;

  /// Load latest articles for homepage (only actual articles, not services)
  Future<void> loadLatestArticles({int limit = 5}) async {
    developer.log('🔄 Loading latest articles...', name: 'ArticleProvider');
    _setViewState(ViewState.loading);

    try {
      developer.log(
        '📡 Calling API: getLatestArticles(limit: $limit)',
        name: 'ArticleProvider',
      );

      final articles = await ArticleRoutes.getLatestArticles(limit: limit);

      developer.log(
        '✅ Received ${articles.length} latest articles from API',
        name: 'ArticleProvider',
      );

      _latestArticles = articles;
      _errorMessage = '';
      _errorDetails = '';
      _setViewState(ViewState.success);

      developer.log(
        '✅ Latest articles loaded successfully: ${_latestArticles.length} items',
        name: 'ArticleProvider',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error loading latest articles',
        name: 'ArticleProvider',
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

  /// Load all articles (only actual articles, not services)
  Future<void> loadArticles({int page = 1, int limit = 10}) async {
    developer.log('🔄 Loading articles...', name: 'ArticleProvider');
    _setViewState(ViewState.loading);

    try {
      developer.log(
        '📡 Calling API: getArticles(page: $page, limit: $limit)',
        name: 'ArticleProvider',
      );

      final articles = await ArticleRoutes.getArticles(
        page: page,
        limit: limit,
      );

      developer.log(
        '✅ Received ${articles.length} articles from API',
        name: 'ArticleProvider',
      );

      _articles = articles;
      _errorMessage = '';
      _errorDetails = '';
      _setViewState(ViewState.success);

      developer.log(
        '✅ Articles loaded successfully: ${_articles.length} items',
        name: 'ArticleProvider',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error loading articles',
        name: 'ArticleProvider',
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

  /// Search articles (only within actual articles)
  Future<void> searchArticles(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    developer.log('🔍 Searching articles: "$query"', name: 'ArticleProvider');
    _setViewState(ViewState.loading);

    try {
      developer.log(
        '📡 Calling API: searchArticles(query: "$query", page: $page, limit: $limit)',
        name: 'ArticleProvider',
      );

      final articles = await ArticleRoutes.searchArticles(
        query,
        page: page,
        limit: limit,
      );

      developer.log(
        '✅ Found ${articles.length} articles matching "$query"',
        name: 'ArticleProvider',
      );

      _articles = articles;
      _errorMessage = '';
      _errorDetails = '';
      _setViewState(ViewState.success);

      developer.log(
        '✅ Article search completed: ${_articles.length} items',
        name: 'ArticleProvider',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error searching articles',
        name: 'ArticleProvider',
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

  Future<void> refreshArticles() async {
    developer.log('🔄 Refreshing articles...', name: 'ArticleProvider');
    if (_latestArticles.isNotEmpty) {
      await loadLatestArticles();
    } else {
      await loadArticles();
    }
  }

  void _setViewState(ViewState state) {
    developer.log(
      '📊 State changed: $_viewState → $state',
      name: 'ArticleProvider',
    );
    _viewState = state;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _errorDetails = '';
    _setViewState(ViewState.idle);
  }
}
