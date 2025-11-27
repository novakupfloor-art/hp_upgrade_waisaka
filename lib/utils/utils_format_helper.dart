import 'package:intl/intl.dart';

/// Helper class untuk formatting currency, date, dan area
/// Sesuai dengan Standards 7: Helper Functions
class FormatHelper {
  /// Format harga ke format Rupiah
  /// Example: 1000000 -> "Rp 1.000.000"
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format tanggal ke format Indonesia
  /// Example: 2025-11-28 -> "28 Nov 2025"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format tanggal dan waktu lengkap
  /// Example: 2025-11-28 14:30 -> "28 Nov 2025 14:30"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dateTime);
  }

  /// Format luas area (m²)
  /// Example: 100.5 -> "100 m²"
  static String formatArea(double area) {
    return '${area.toStringAsFixed(0)} m²';
  }

  /// Format nomor telepon Indonesia
  /// Example: 081234567890 -> "0812-3456-7890"
  static String formatPhoneNumber(String phone) {
    // Remove all non-numeric characters
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Format: 0812-3456-7890
    if (cleaned.length >= 10) {
      final part1 = cleaned.substring(0, 4);
      final part2 = cleaned.substring(
        4,
        cleaned.length > 8 ? 8 : cleaned.length,
      );
      final part3 = cleaned.length > 8 ? cleaned.substring(8) : '';

      if (part3.isNotEmpty) {
        return '$part1-$part2-$part3';
      } else if (part2.isNotEmpty) {
        return '$part1-$part2';
      }
      return part1;
    }
    return phone;
  }

  /// Format angka dengan separator ribuan
  /// Example: 1000000 -> "1.000.000"
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number);
  }

  /// Format persentase
  /// Example: 0.75 -> "75%"
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  /// Format durasi dalam hari
  /// Example: 30 -> "30 hari"
  static String formatDuration(int days) {
    if (days == 1) return '1 hari';
    if (days < 30) return '$days hari';

    final months = (days / 30).floor();
    final remainingDays = days % 30;

    if (remainingDays == 0) {
      return months == 1 ? '1 bulan' : '$months bulan';
    }

    return '$months bulan $remainingDays hari';
  }
}
