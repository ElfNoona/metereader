import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../routes.dart';
import '../../../data/local/storage_service.dart';

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
    final username = await StorageService.getLoggedInUsername();
    if (mounted) {
      setState(() {
        _username = username ?? 'User';
      });
    }
  }

  Future<void> _handleLogout() async {
    await StorageService.clearSession();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false);
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
          onPressed: () {},
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
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textDark),
            onPressed: _handleLogout,
            tooltip: 'Logout',
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
            _buildUsageChartCard(),
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
          const Text(
            'Before 30 Oct 2021',
            style: TextStyle(
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
                  onPressed: () {},
                  child: const Text('View Bills'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChartCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
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
          
          // Simple Bar Chart Mockup
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBar('Jan', 80),
                _buildBar('Feb', 100),
                _buildBar('Mar', 120),
                _buildBar('Apr', 90),
                _buildBar('May', 150),
                _buildBar('Jun', 110),
                _buildBar('Jul', 130),
                _buildBar('Aug', 140),
                _buildBar('Sep', 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
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
            fontSize: 10,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
