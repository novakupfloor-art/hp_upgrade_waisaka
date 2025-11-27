import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';

class HtmlUtils {
  /// Convert HTML text to plain text
  static String htmlToPlainText(String htmlText) {
    if (htmlText.isEmpty) return '';

    // Remove HTML tags
    String plainText = htmlText
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Decode HTML entities
    plainText = plainText
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');

    return plainText;
  }

  /// Render HTML content with custom styling
  static Widget renderHtmlContent(
    String htmlContent, {
    double? fontSize,
    Color? textColor,
    Color? linkColor,
    bool isSelectable = true,
    Function(String url)? onLinkTap,
  }) {
    if (htmlContent.isEmpty) {
      return Text(
        'Tidak ada deskripsi tersedia.',
        style: TextStyle(
          fontSize: fontSize ?? 14,
          color: textColor ?? Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Html(
      data: htmlContent,
      onLinkTap: (url, _, _) {
        if (onLinkTap != null) {
          onLinkTap(url ?? '');
        }
      },
    );
  }

  /// Clean and sanitize HTML content
  static String sanitizeHtml(String htmlContent) {
    if (htmlContent.isEmpty) return '';

    // Remove potentially harmful tags and attributes
    String sanitized = htmlContent;

    // Remove script tags
    sanitized = sanitized.replaceAll(
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      '',
    );

    // Remove style tags
    sanitized = sanitized.replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false),
      '',
    );

    // Remove comments
    sanitized = sanitized.replaceAll(RegExp(r'<!--.*?-->'), '');

    // Clean up excessive whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized.trim();
  }

  /// Extract text content from HTML with specific tag filtering
  static String extractTextByTag(String htmlContent, String tagName) {
    if (htmlContent.isEmpty || tagName.isEmpty) return '';

    final pattern = RegExp(
      '<$tagName[^>]*>(.*?)</$tagName>',
      caseSensitive: false,
      dotAll: true,
    );
    final matches = pattern.allMatches(htmlContent);

    final extractedText = matches
        .map((match) => match.group(1) ?? '')
        .join(' ');
    return htmlToPlainText(extractedText);
  }

  /// Check if HTML contains specific content
  static bool containsContent(String htmlContent, String searchText) {
    final plainText = htmlToPlainText(htmlContent);
    return plainText.toLowerCase().contains(searchText.toLowerCase());
  }

  /// Truncate HTML content while preserving tags
  static String truncateHtml(String htmlContent, int maxLength) {
    if (htmlContent.length <= maxLength) return htmlContent;

    final plainText = htmlToPlainText(htmlContent);
    if (plainText.length <= maxLength) return htmlContent;

    // Find the closest sentence break before maxLength
    final truncated = plainText.substring(0, maxLength);
    final lastSentence = truncated.lastIndexOf(RegExp(r'[.!?]'));

    if (lastSentence > maxLength * 0.7) {
      return plainText.substring(0, lastSentence + 1);
    }

    return '$truncated...';
  }
}
