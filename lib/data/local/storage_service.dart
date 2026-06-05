import 'package:shared_preferences/shared_preferences.dart';

/// A service to handle persistent login state using SharedPreferences.

class StorageService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUsername = 'loggedInUsername';

  /// 1. Start a Session (Login/Signup)
  /// Saves the active username and sets the logged-in flag to true.
  static Future<void> startSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  /// 2. Check Login Status
  /// Used when the app opens to decide whether to show the Login screen or Dashboard.
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false; // Default to false if not found
  }

  /// 3. Get Active Username
  /// Used to query Isar for the correct user's reading history.
  static Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// 4. End Session (Logout)
  /// Clears the saved keys so the app forces a login next time.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }
}
