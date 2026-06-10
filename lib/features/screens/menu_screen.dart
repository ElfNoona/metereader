import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/local/storage_service.dart';
import '../../routes.dart';

class MenuScreen extends StatefulWidget {
  final String activeRoute;
  const MenuScreen({super.key, this.activeRoute = ''});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
        _username = username ?? 'A.B.C.Perera';
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

  void _handleNavigation(String routeName) {
    if (widget.activeRoute == routeName) {
      Navigator.pop(context); // Just close the menu if we're already on that screen
    } else {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Profile Section
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.teal,
                    radius: 30,
                    child: Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'A.C. No. 102345679',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Menu Items
              _buildMenuItem(
                icon: Icons.home,
                title: 'Home',
                isActive: widget.activeRoute == AppRoutes.dashboard,
                onTap: () {
                  if (widget.activeRoute == AppRoutes.dashboard) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
                  }
                },
              ),
              _buildMenuItem(
                icon: Icons.arrow_circle_up,
                title: 'Submit Reading',
                isActive: [AppRoutes.camera, AppRoutes.cropping, AppRoutes.confirmation].contains(widget.activeRoute),
                onTap: () => _handleNavigation(AppRoutes.camera),
              ),
              _buildMenuItem(
                icon: Icons.history,
                title: 'Bill History',
                isActive: widget.activeRoute == AppRoutes.history,
                onTap: () => _handleNavigation(AppRoutes.history),
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Settings',
                isActive: false,
                onTap: () {}, // Unmapped
              ),

              const SizedBox(height: 48),

              // Logout Button
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: isActive
          ? BoxDecoration(
              color: AppTheme.primaryYellow,
              borderRadius: BorderRadius.circular(30),
            )
          : null,
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.black : AppTheme.primaryYellow,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.black : AppTheme.primaryYellow,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onTap: onTap,
      ),
    );
  }
}
