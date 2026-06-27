import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';
import '../../../routes.dart';
import '../../../data/local/storage_service.dart';
import '../widgets/history_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final username = await StorageService.getUserId();
    if (mounted) {
      setState(() {
        _username = username ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.textDark),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.menu, arguments: AppRoutes.dashboard);
          },
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: AppTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.primaryYellow),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome text
            Text(
              'Hi, $_username!',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 24),

            // Upload Reading Card
            _buildUploadCard(),
            const SizedBox(height: 24),

            // Amount Payable Card
            _buildAmountPayableCard(),
            const SizedBox(height: 24),

            // My Usage Chart Card
            HistoryWidget(username: _username),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        children: [
          const Text(
            'Upload your electricity meter reading',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Before 30 ${DateFormat('MMM yyyy').format(DateTime.now())}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: AppTheme.darkButtonStyle,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.camera);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPayableCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        children: [
          const Text(
            'Total Amount Payable',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'Rs. ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                '1852.45',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '01 Sep 2021 - 30 Sep 2021',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: AppTheme.darkButtonStyle,
                  onPressed: () {},
                  child: const Text('Pay now'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: AppTheme.darkButtonStyle,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.history);
                  },
                  child: const Text('View Bills'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
