import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/features/worker/presentation/pages/worker_dashboard_screen.dart';
import 'package:skillbridge_mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:skillbridge_mobile/features/worker/presentation/pages/active_jobs_screen.dart';
import 'package:skillbridge_mobile/features/worker/presentation/pages/worker_wallet_screen.dart';

class WorkerMainScreen extends StatefulWidget {
  static const String routeName = '/worker-main';
  const WorkerMainScreen({super.key});

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WorkerDashboardScreen(),
    const ActiveJobsScreen(),
    const WorkerWalletScreen(),
    const ProfileScreen(),
  ];


  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // Only show exit dialog on Android
        if (Platform.isAndroid) {
          final bool shouldPop = await _showExitDialog(context) ?? false;
          if (context.mounted && shouldPop) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(

      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppTheme.colors.primary,
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            showUnselectedLabels: true,
            items: [
              _buildNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home', 0),
              _buildNavItem(Icons.work_outline_rounded, Icons.work_rounded, 'My Jobs', 1),
              _buildNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Wallet', 2),
              _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 3),
            ],
          ),
        ),
      ),
      ),
    );
  }


  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
           color: _currentIndex == index ? AppTheme.colors.primary.withValues(alpha: 0.1) : Colors.transparent,
           borderRadius: BorderRadius.circular(12)
        ),
        child: Icon(icon)
      ),
      activeIcon: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
           color: AppTheme.colors.primary.withValues(alpha: 0.1),
           borderRadius: BorderRadius.circular(12)
        ),
        child: Icon(activeIcon)
      ),
      label: label,
    );
  }
}
