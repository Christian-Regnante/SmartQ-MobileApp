/// Shared field validators for admin CRUD dialogs.
class FormValidators {
  FormValidators._();

  static String? required(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldLabel is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, 'Email');
    if (requiredError != null) return requiredError;
    final email = value!.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final requiredError = required(value, 'Password');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? positiveNumber(String? value, String fieldLabel) {
    final requiredError = required(value, fieldLabel);
    if (requiredError != null) return requiredError;
    final parsed = double.tryParse(value!.trim());
    if (parsed == null) return 'Enter a valid number for $fieldLabel';
    if (parsed <= 0) return '$fieldLabel must be greater than 0';
    return null;
  }

  static String? dropdownRequired(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a $fieldLabel';
    }
    return null;
  }
}
