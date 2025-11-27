import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://192.168.18.8/novak_upfloor/public';
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'http://192.168.18.8/novak_upfloor/public/api/v1';
  static int get timeout => int.parse(dotenv.env['API_TIMEOUT'] ?? '30');
  static String get appName => dotenv.env['APP_NAME'] ?? 'Waisaka Property';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Image URL builders
  static String buildPropertyImages(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=No+Image';
    }

    // If already full URL, return as-is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Remove leading slash if present
    final cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    // Backend stores property images in: public/assets/upload/property/
    return '$baseUrl/assets/upload/property/$cleanPath';
  }

  static String buildArticleImages(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=No+Image';
    }

    // If already full URL, return as-is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Remove leading slash if present
    final cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    // Backend stores article images in: public/assets/upload/berita/
    // But based on MobileArticleController, it returns relative path from database
    return '$baseUrl/assets/upload/berita/$cleanPath';
  }

  static String buildUserImages(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/150x150?text=No+Image';
    }

    // If already full URL, return as-is
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Remove leading slash if present
    final cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    // Backend stores user images in: public/assets/upload/user/
    return '$baseUrl/assets/upload/user/$cleanPath';
  }
}
