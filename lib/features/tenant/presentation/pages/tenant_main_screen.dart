import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/features/tenant/presentation/pages/home_screen.dart';
import 'package:skillbridge_mobile/features/tenant/presentation/pages/job_history_screen.dart';
import 'package:skillbridge_mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:skillbridge_mobile/features/tenant/presentation/pages/my_jobs_screen.dart';
import 'package:skillbridge_mobile/features/tenant/presentation/pages/post_job_screen.dart';

class TenantMainScreen extends StatefulWidget {
  static const String routeName = '/tenant-main';
  const TenantMainScreen({super.key});

  @override
  State<TenantMainScreen> createState() => _TenantMainScreenState();
}

class _TenantMainScreenState extends State<TenantMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TenantHomeScreen(),
    const MyJobsScreen(),
    const PostJobScreen(),
    const JobHistoryScreen(),
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
        // On iOS, the swipe back gesture is disabled by canPop: false
        // The user will use the Home gesture to exit
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
              _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.work_outline_rounded, Icons.work_rounded, 'My Jobs', 1),
              _buildNavItem(Icons.add_circle_outline_rounded, Icons.add_circle_rounded, 'Post Job', 2),
              _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'History', 3),
              _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 4),
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
