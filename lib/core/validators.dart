import '../data/local/isar_service.dart';
import '../data/local/storage_service.dart';

class Validators {
  /// --- Form Field Validation ---
  /// Basic UI level validation for the text fields.

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters long';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!hasUppercase || !hasDigits || !hasLowercase || !hasSpecialCharacters) {
      return 'Password must contain at least 1 uppercase, 1 lowercase, 1 number, and 1 special character';
    }
    return null;
  }
  
  /// Validates the meter reading text field on the UI 
  /// before passing it to IsarService.
  static String? validateMeterReading(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Reading cannot be empty';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid numeric reading';
    }
    return null;
  }
}

/// --- Core Authentication Flow Logic ---
/// This class handles the signup, login, and persistent state flows
/// by combining the Isar DB and Storage Service.
class AuthValidator {
  
  /// 1. SIGN UP LOGIC
  /// A person signing up will enter a username and password. 
  /// This gets verified against user schema and gets stored in the isar db instance.
  static Future<bool> signUp({
    required String username,
    required String password,
  }) async {
    // Step A: Basic string validation
    final usernameError = Validators.validateUsername(username);
    final passwordError = Validators.validatePassword(password);
    
    if (usernameError != null || passwordError != null) {
      throw Exception(usernameError ?? passwordError);
    }

    final isarService = IsarService();

    // Step B: Check Isar DB if the username already exists.
    final userExists = await isarService.checkUserExists(username);
    if (userExists) {
      throw Exception('Username already taken');
    }

    // Step C: Create the new User schema and save it to Isar DB.
    await isarService.createUser(username, password); 

    // Step D: Once stored, automatically set the session as "logged in" in secure storage.
    await StorageService.startSession(username);

    return true; // Successfully signed up and session started
  }

  /// 2. LOGIN LOGIC
  /// Verify the entered username and password against the ones stored in DB
  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    // Step A: Basic string validation
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Username and password cannot be empty');
    }

    final isarService = IsarService();

    // Step B: Retrieve the user record from Isar DB by username.
    final userRecord = await isarService.getUserByUsername(username);
    if (userRecord == null) {
      throw Exception('User not found');
    }

    // Step C: Verify if the entered password matches the stored password.
    if (userRecord.password != password) {
      throw Exception('Incorrect password');
    }

    // Step D: If valid, set the persistent login status in secure storage.
    await StorageService.startSession(username);

    return true; // Successfully logged in
  }

  /// 3. PERSISTENT LOGIN CHECK
  /// After logging in once, the user should stay signed in.
  static Future<bool> isUserLoggedIn() async {
    // Check storage for an active session flag.
    return await StorageService.isUserLoggedIn();
  }

  /// 4. LOGOUT
  /// User stays signed in *unless* he explicitly presses log out.
  static Future<void> logout() async {
    // Clear the session flag and user data from storage.
    await StorageService.clearSession();
  }
}
