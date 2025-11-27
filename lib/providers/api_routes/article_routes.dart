import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/models_article.dart';
import 'api_base.dart';

/// Article Management Routes
class ArticleRoutes {
  /// Get list of articles (only actual articles, not services)
  static Future<List<Article>> getArticles({
    int page = 1,
    int limit = 5,
  }) async {
    try {
      // Add filter to only get articles with jenis_berita = 'Berita'
      final url =
          '${ApiBase.apiBaseUrl}/articles?page=$page&per_page=$limit&jenis_berita=Berita';
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
          final articles = (data['data'] as List)
              .map((item) => Article.fromJson(item))
              .toList();
          debugPrint('✅ Successfully parsed ${articles.length} articles');
          return articles;
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
      debugPrint('❌ Error in getArticles: $e');
      rethrow;
    }
  }

  /// Get latest articles for homepage (only actual articles)
  static Future<List<Article>> getLatestArticles({int limit = 5}) async {
    try {
      // Add filter to only get articles with jenis_berita = 'Berita'
      final url =
          '${ApiBase.apiBaseUrl}/articles?page=1&per_page=$limit&jenis_berita=Berita';
      debugPrint('📡 API Request: GET $url (Latest Articles)');

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiBase.getHeaders(),
      );

      debugPrint('📥 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final articles = (data['data'] as List)
              .map((item) => Article.fromJson(item))
              .toList();
          debugPrint(
            '✅ Successfully parsed ${articles.length} latest articles',
          );
          return articles;
        } else {
          throw Exception(data['message'] ?? 'API returned success=false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error in getLatestArticles: $e');
      rethrow;
    }
  }

  /// Search articles (only within actual articles)
  static Future<List<Article>> searchArticles(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Add filter to only search within articles with jenis_berita = 'Berita'
      final url =
          '${ApiBase.apiBaseUrl}/articles?page=$page&per_page=$limit&search=$query&jenis_berita=Berita';
      debugPrint('📡 API Request: GET $url (Search)');

      final response = await http.get(
        Uri.parse(url),
        headers: await ApiBase.getHeaders(),
      );

      debugPrint('📥 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final articles = (data['data'] as List)
              .map((item) => Article.fromJson(item))
              .toList();
          debugPrint(
            '✅ Successfully found ${articles.length} articles matching "$query"',
          );
          return articles;
        } else {
          throw Exception(data['message'] ?? 'API returned success=false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error in searchArticles: $e');
      rethrow;
    }
  }
}
