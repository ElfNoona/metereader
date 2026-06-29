import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../data/remote/api_service.dart';
import '../../../data/models/history_item_model.dart';

class DashboardController extends ChangeNotifier {
  final ApiService _apiService;
  List<HistoryItemModel> historyItems = [];
  bool isLoading = false;

  DashboardController({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

  Future<void> fetchHistory() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/billing/history');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['history'] ?? [];
        historyItems = data.map((json) => HistoryItemModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching history: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadAndOpenInvoice(String invoiceId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.downloadBytes('/billing/invoice/$invoiceId/download');
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/invoice_$invoiceId.pdf';
        final file = File(filePath);
        
        await file.writeAsBytes(response.data);
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      print('Error downloading invoice: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payBill(String billId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/billing/pay/$billId');
      if (response.statusCode == 200) {
        await fetchHistory(); // Refresh history to show paid status
        return true;
      }
      return false;
    } catch (e) {
      print('Error paying bill: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
