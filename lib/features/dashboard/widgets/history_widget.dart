import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_theme.dart';
import '../../../../data/models/history_item_model.dart';
import '../controllers/dashboard_controller.dart';

class HistoryWidget extends StatefulWidget {
  final String username;
  
  const HistoryWidget({super.key, required this.username});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  final _dashboardController = DashboardController();
  List<HistoryItemModel> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant HistoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      await _dashboardController.fetchHistory();
      final allItems = _dashboardController.historyItems;
      
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
      
      final recentItems = allItems.where((item) => item.reading.timestamp != null && item.reading.timestamp!.isAfter(sixMonthsAgo)).toList();
      
      recentItems.sort((a, b) => a.reading.timestamp!.compareTo(b.reading.timestamp!));
      
      final displayItems = recentItems.length > 6 
          ? recentItems.sublist(recentItems.length - 6) 
          : recentItems;

      setState(() {
        _historyItems = displayItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading history for chart: \$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'My Usage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 24),
          
          if (_isLoading)
            const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator(color: AppTheme.textDark)),
            )
          else if (_historyItems.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  'No reading history found.',
                  style: TextStyle(color: AppTheme.textDark),
                ),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildBars(),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildBars() {
    if (_historyItems.isEmpty) return [];

    double maxValue = _historyItems.map((item) => item.reading.readingValue.toDouble()).reduce((a, b) => a > b ? a : b);
    
    if (maxValue == 0) maxValue = 1;

    final maxHeight = 110.0; 

    return _historyItems.map((item) {
      final barHeight = (item.reading.readingValue.toDouble() / maxValue) * maxHeight;
      
      final monthLabel = item.reading.timestamp != null ? DateFormat('MMM').format(item.reading.timestamp!) : 'Unk';
      
      return _buildSingleBar(monthLabel, barHeight.clamp(10.0, maxHeight));
    }).toList();
  }

  Widget _buildSingleBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
