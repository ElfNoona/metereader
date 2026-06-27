import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../data/local/storage_service.dart';
import '../../../data/models/reading_model.dart';

class DashboardController extends ChangeNotifier {
  bool isLoading = false;
  List<ReadingModel> readings = [];

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000/api'));

  Future<void> fetchHistory() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await StorageService.getAccessToken();
      // NOTE: Ensure your node backend has a GET /billing/history route created
      final response = await _dio.get(
        '/billing/history',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

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
