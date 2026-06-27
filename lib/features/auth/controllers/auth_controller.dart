import 'package:flutter/material.dart';
import '../../../data/remote/api_service.dart';
import '../../../data/local/storage_service.dart';

/// Controller for managing Authentication state and business logic.
class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final ApiService _apiService;

  AuthController({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Attempts to log the user in. Returns true if successful.
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      final response = await _apiService.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        await StorageService.startSession(
          data['accessToken'],
          data['refreshToken'],
          data['userId'],
        );
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  /// Attempts to sign up a new user. Returns true if successful.
  Future<bool> signUp(String username, String password) async {
    _setLoading(true);
    try {
      final response = await _apiService.post('/auth/signup', data: {
        'username': username,
        'password': password,
        'fullName': username, 
        'bpNumber': 'BP-${DateTime.now().millisecondsSinceEpoch}',
        'address': 'N/A',
      });

      if (response.statusCode == 201) {
        final data = response.data;
        await StorageService.startSession(
          data['accessToken'],
          data['refreshToken'],
          data['userId'],
        );
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }
}
