import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../data/models/history_item_model.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import '../../../routes.dart';

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  final _dashboardController = DashboardController();
  List<HistoryItemModel> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      await _dashboardController.fetchHistory();
      if (mounted) {
        setState(() {
          _historyItems = _dashboardController.historyItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reading history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePayBill(String billId) async {
    final success = await _dashboardController.payBill(billId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill paid successfully!')),
      );
      _loadHistory();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pay bill.'), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  Future<void> _handleDownload(String invoiceId) async {
    await _dashboardController.downloadAndOpenInvoice(invoiceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.menu, arguments: AppRoutes.history),
        ),
        title: const Text(
          'Reading History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading || _dashboardController.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow))
          : _historyItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: _historyItems.length,
                  itemBuilder: (context, index) {
                    final item = _historyItems[index];
                    return _buildHistoryCard(item);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No readings found.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your scanned readings will appear here.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItemModel item) {
    final reading = item.reading;
    final formattedDate = reading.timestamp != null ? DateFormat('dd MMM yyyy, hh:mm a').format(reading.timestamp!) : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meter Reading',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                reading.readingValue.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          if (item.billId != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Colors.white54, thickness: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bill Amount', style: TextStyle(fontSize: 12, color: AppTheme.textDark)),
                    Text(
                      'Rs. ${item.totalPayable.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (item.isPaid) ...[
                      const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      if (item.invoiceId != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.download, color: AppTheme.textDark),
                          onPressed: () => _handleDownload(item.invoiceId!),
                          tooltip: 'Download Invoice',
                        ),
                      ]
                    ] else ...[
                      const Icon(Icons.cancel, color: Colors.red, size: 28),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.textDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _handlePayBill(item.billId!),
                        child: const Text('Pay Bill', style: TextStyle(fontSize: 12)),
                      ),
                    ]
                  ],
                )
              ],
            ),
          ]
        ],
      ),
    );
  }
}
