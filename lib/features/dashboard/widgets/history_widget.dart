import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_theme.dart';
import '../../../../data/local/isar_service.dart';
import '../../../../data/local/schemas/reading_schema.dart';

class HistoryWidget extends StatefulWidget {
  final String username;
  
  const HistoryWidget({super.key, required this.username});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  final _isarService = IsarService();
  List<MeterReading> _readings = [];
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
    if (widget.username.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final allReadings = await _isarService.getReadingsForUser(widget.username);
      
      // Filter to the last 6 months only
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
      
      final recentReadings = allReadings.where((r) => r.timestamp.isAfter(sixMonthsAgo)).toList();
      
      // Sort chronologically (oldest first) for the chart
      recentReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      // Take up to the last 6 chronological readings if there are many in the same month
      // Or we can just display the last 6 readings in general. 
      // Let's display up to the last 6 readings
      final displayReadings = recentReadings.length > 6 
          ? recentReadings.sublist(recentReadings.length - 6) 
          : recentReadings;

      setState(() {
        _readings = displayReadings;
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
          else if (_readings.isEmpty)
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
    if (_readings.isEmpty) return [];

    // Find the maximum value to scale the bars proportionally
    double maxValue = _readings.map((r) => r.readingValue).reduce((a, b) => a > b ? a : b);
    
    // Fallback if max is 0 to avoid division by zero
    if (maxValue == 0) maxValue = 1;

    final maxHeight = 110.0; // The max physical height we want a bar to be

    return _readings.map((reading) {
      // Calculate proportional height
      final barHeight = (reading.readingValue / maxValue) * maxHeight;
      
      // Format month label (e.g. 'Jan')
      final monthLabel = DateFormat('MMM').format(reading.timestamp);
      
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
