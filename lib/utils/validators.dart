class AppValidators {
  AppValidators._();

  static String? name(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter at least 2 characters.';
    }
    return null;
  }

  static String? requiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $fieldName.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(text)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
