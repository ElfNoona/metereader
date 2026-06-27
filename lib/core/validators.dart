class Validators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username cannot be empty';
    if (value.length < 3) return 'Username must be at least 3 characters';
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
  
  static String? validateMeterReading(String? value) {
    if (value == null || value.isEmpty) return 'Reading cannot be empty';
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }
}
