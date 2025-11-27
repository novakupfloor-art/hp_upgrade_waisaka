import 'dart:io';
import 'dart:async';

class ErrorHelper {
  static String getFriendlyMessage(dynamic error) {
    String message = error.toString();

    if (error is SocketException) {
      return 'Tidak ada koneksi internet. Periksa sambungan Anda.';
    } else if (error is TimeoutException) {
      return 'Waktu habis. Koneksi internet Anda mungkin lambat.';
    } else if (message.contains('SocketException')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    } else if (message.contains('401') || message.contains('Unauthenticated')) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    } else if (message.contains('403')) {
      return 'Anda tidak memiliki akses untuk melakukan ini.';
    } else if (message.contains('404')) {
      return 'Data tidak ditemukan.';
    } else if (message.contains('500')) {
      return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
    }

    // Clean up "Exception: " prefix
    return message.replaceAll('Exception: ', '');
  }
}
