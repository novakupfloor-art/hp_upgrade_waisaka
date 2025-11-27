/// Helper class untuk validasi form input
/// Sesuai dengan Standards 7: Helper Functions
class ValidationHelper {
  /// Validasi email
  /// Returns true jika email valid
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Validasi nomor telepon Indonesia
  /// Returns true jika nomor telepon valid (10-13 digit)
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    // Indonesia phone: 10-13 digits
    return cleaned.length >= 10 && cleaned.length <= 13;
  }

  /// Validasi password (minimal 6 karakter)
  /// Returns true jika password valid
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Validasi username (alphanumeric, 3-32 karakter)
  /// Returns true jika username valid
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,32}$').hasMatch(username);
  }

  /// Validasi angka positif
  /// Returns true jika value adalah angka positif
  static bool isPositiveNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0;
  }

  /// Validasi angka (termasuk negatif dan desimal)
  /// Returns true jika value adalah angka valid
  static bool isValidNumber(String value) {
    return double.tryParse(value) != null;
  }

  /// Validasi required field
  /// Returns error message jika kosong, null jika valid
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validasi email dengan error message
  /// Returns error message jika tidak valid, null jika valid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!isValidEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validasi phone dengan error message
  /// Returns error message jika tidak valid, null jika valid
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (!isValidPhone(value)) {
      return 'Format nomor telepon tidak valid (10-13 digit)';
    }
    return null;
  }

  /// Validasi password dengan error message
  /// Returns error message jika tidak valid, null jika valid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (!isValidPassword(value)) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validasi username dengan error message
  /// Returns error message jika tidak valid, null jika valid
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (!isValidUsername(value)) {
      return 'Username harus 3-32 karakter (huruf, angka, underscore)';
    }
    return null;
  }

  /// Validasi angka positif dengan error message
  /// Returns error message jika tidak valid, null jika valid
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (!isPositiveNumber(value)) {
      return '$fieldName harus berupa angka positif';
    }
    return null;
  }

  /// Validasi minimal panjang string
  /// Returns error message jika tidak valid, null jika valid
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  /// Validasi maksimal panjang string
  /// Returns error message jika tidak valid, null jika valid
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    return null;
  }

  /// Validasi konfirmasi password
  /// Returns error message jika tidak cocok, null jika valid
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (password != confirmation) {
      return 'Password tidak cocok';
    }
    return null;
  }
}
