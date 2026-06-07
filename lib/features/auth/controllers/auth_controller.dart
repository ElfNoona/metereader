import 'package:flutter/material.dart';
import '../../../core/validators.dart';

/// Controller for managing Authentication state and business logic.
/// It bridges the UI screens and the core AuthValidator logic.
class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Attempts to log the user in. Returns true if successful, throws an error otherwise.
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      await AuthValidator.login(username: username, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Attempts to sign up a new user. Returns true if successful, throws an error otherwise.
  Future<bool> signUp(String username, String password) async {
    _setLoading(true);
    try {
      await AuthValidator.signUp(username: username, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
}
