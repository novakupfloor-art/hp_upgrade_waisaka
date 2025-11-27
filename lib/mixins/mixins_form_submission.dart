import 'package:flutter/material.dart';

/// Mixin untuk standardisasi form submission flow
/// Mengikuti Standards 11: Form Submission Flow
///
/// Flow:
/// 1. Validate Inputs
/// 2. Collect Data
/// 3. Process Data
/// 4. API Call (On Success/On Error)
/// 5. Reset State
mixin FormSubmissionMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Set loading state
  void setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  /// Standard form submission flow
  ///
  /// Usage:
  /// ```dart
  /// await submitForm(
  ///   formKey: _formKey,
  ///   onSubmit: () async {
  ///     final data = _collectFormData();
  ///     await ApiService.submit(data);
  ///   },
  ///   onSuccess: () {
  ///     showSuccessMessage('Data berhasil disimpan');
  ///     Navigator.pop(context);
  ///   },
  ///   onError: (error) {
  ///     showErrorMessage(error);
  ///   },
  /// );
  /// ```
  Future<void> submitForm({
    required GlobalKey<FormState> formKey,
    required Future<void> Function() onSubmit,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Step 1: Validate
      if (!formKey.currentState!.validate()) {
        return;
      }

      // Set loading state
      setLoading(true);

      // Step 4: API Call (Steps 2 & 3 handled in onSubmit)
      await onSubmit();

      // Step 4a: On Success
      if (onSuccess != null) {
        onSuccess();
      }
    } catch (e) {
      // Step 4b: On Error
      if (onError != null) {
        onError(e.toString());
      } else {
        _showDefaultError(e.toString());
      }
    } finally {
      // Step 5: Reset State
      setLoading(false);
    }
  }

  /// Show default error message
  void _showDefaultError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show success message
  void showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show error message
  void showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show info message
  void showInfoMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show warning message
  void showWarningMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show loading dialog
  void showLoadingDialog({String message = 'Memproses...'}) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// Show confirmation dialog
  Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Tidak',
  }) async {
    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
