/// Shared phone validators for registration and profile editing.
class PhoneValidators {
  PhoneValidators._();

  /// Rwanda mobile: +250 followed by 7 and 8 more digits (e.g. +250788123456).
  static String? rwandaMobile(String? val) {
    if (val == null || val.trim().isEmpty) {
      return 'Phone number is required';
    }
    final normalized = val.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+2507\d{8}$').hasMatch(normalized)) {
      return 'Use the correct format: +2507XXXXXXXX';
    }
    return null;
  }
}
