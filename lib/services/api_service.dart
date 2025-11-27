import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/models_article.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: AppConfig.timeout),
      receiveTimeout: Duration(seconds: AppConfig.timeout),
    ),
  );

  // Get articles with jenis_berita = 'Berita' only
  static Future<List<Article>> getArticles({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/articles',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'jenis_berita': 'Berita', // Filter to only get actual articles
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> articlesData = response.data['data'];
        return articlesData.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load articles');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // Get article detail by ID
  static Future<Article> getArticleDetail(int id) async {
    try {
      final response = await _dio.get('/articles/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Article.fromJson(response.data['data']);
      } else {
        throw Exception('Article not found');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // Get latest articles for homepage (limited to 5 items)
  static Future<List<Article>> getLatestArticles() async {
    try {
      final response = await _dio.get(
        '/articles',
        queryParameters: {
          'page': 1,
          'per_page': 5,
          'jenis_berita': 'Berita', // Only get actual articles, not services
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> articlesData = response.data['data'];
        return articlesData.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load latest articles');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  // Search articles by keyword
  static Future<List<Article>> searchArticles(
    String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/articles',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'search': query,
          'jenis_berita': 'Berita', // Only search within actual articles
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> articlesData = response.data['data'];
        return articlesData.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search articles');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
