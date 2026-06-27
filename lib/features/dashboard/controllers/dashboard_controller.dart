import 'package:flutter/material.dart';
import '../../../data/remote/api_service.dart';
import '../../../data/models/reading_model.dart';

class DashboardController extends ChangeNotifier {
  bool isLoading = false;
  List<ReadingModel> readings = [];

  final ApiService _apiService;

  DashboardController({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  Future<void> fetchHistory() async {
    isLoading = true;
    notifyListeners();

    try {
      // NOTE: Ensure your node backend has a GET /billing/history route created
      final response = await _apiService.get('/billing/history');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['history'] ?? [];
        readings = data.map((json) => ReadingModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching history: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
