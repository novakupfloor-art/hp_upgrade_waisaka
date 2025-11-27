import 'package:intl/intl.dart';

class FormatHelper {
  /// Truncate text to specified length with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Format currency to Indonesian Rupiah
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format date to readable format
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format date time to readable format
  static String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format area (land/building size)
  static String formatArea(int? area) {
    if (area == null || area == 0) return '';
    return '$area m²';
  }

  /// Format property type
  static String formatPropertyType(String? type) {
    if (type == null || type.isEmpty) return '';
    switch (type.toLowerCase()) {
      case 'rumah':
        return 'Rumah';
      case 'apartemen':
        return 'Apartemen';
      case 'tanah':
        return 'Tanah';
      case 'ruko':
        return 'Ruko';
      case 'villa':
        return 'Villa';
      default:
        return type;
    }
  }
}
