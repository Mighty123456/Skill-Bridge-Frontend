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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.colors.primary,
              unselectedItemColor: Colors.grey[400],
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_outlined, size: 24),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.home_rounded, size: 26),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.work_outline_rounded, size: 24),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.work_rounded, size: 26),
                  ),
                  label: 'My Jobs',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.add_circle_outline_rounded, size: 28),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.add_circle_rounded, size: 30),
                  ),
                  label: 'Post Job',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.receipt_long_outlined, size: 24),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.receipt_long_rounded, size: 26),
                  ),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_outline_rounded, size: 24),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_rounded, size: 26),
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
