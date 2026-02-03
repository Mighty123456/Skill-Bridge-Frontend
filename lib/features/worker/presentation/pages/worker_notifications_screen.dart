import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import '../../data/notification_service.dart';


import 'package:skillbridge_mobile/widgets/premium_loader.dart';

class WorkerNotificationsScreen extends StatefulWidget {
  static const String routeName = '/worker-notifications';
  const WorkerNotificationsScreen({super.key});

  @override
  State<WorkerNotificationsScreen> createState() => _WorkerNotificationsScreenState();
}

class _WorkerNotificationsScreenState extends State<WorkerNotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await NotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: const PremiumAppBar(
        title: 'Notifications',
        showBackButton: true,
        hideNotificationAction: true,
      ),
      body: _isLoading
          ? const Center(child: PremiumLoader())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.colors.primary,
        child: const Icon(Icons.support_agent_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No new notifications at the moment.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'system';
    final isRead = notification['read'] == true;
    
    // Determine style based on type
    IconData icon;
    Color color;
    
    switch (type) {
      case 'job_alert':
        icon = Icons.work_outline_rounded;
        color = Colors.orange;
        break;
      case 'payment':
        icon = Icons.attach_money_rounded;
        color = Colors.green;
        break;
      case 'job_update':
        icon = Icons.update_rounded;
        color = Colors.blue;
        break;
      case 'quotation_accepted':
        icon = Icons.assignment_turned_in_rounded;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = AppTheme.colors.primary;
    }

    return GestureDetector(
      onTap: () async {
        if (_isNavigating) return;
        _isNavigating = true;
        try {
          if (!isRead) {
            NotificationService.markAsRead(notification['_id']);
            setState(() {
              notification['read'] = true;
            });
          }
           
          // Navigate to detail if it's a job alert or quotation accepted
          if ((type == 'job_alert' || type == 'quotation_accepted') && 
              notification['data'] != null && notification['data']['jobId'] != null) {
            // Navigate to details
            await Navigator.pushNamed(
              context, 
              '/worker-job-detail', 
              arguments: notification['data']['jobId']
            );
          }
        } finally {
          if (mounted) _isNavigating = false;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Colors.transparent : color.withValues(alpha: 0.3),
            width: 1
          ),
          boxShadow: [
             BoxShadow(
                color: Colors.black.withValues(alpha: isRead ? 0.03 : 0.0), // No shadow for unread to make it flat/highlighted
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRead ? Colors.grey[100] : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isRead ? Colors.grey : color, size: 20),
            ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         notification['title'] ?? 'Notification',
                         style: TextStyle(
                           fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                           fontSize: 15,
                           color: isRead ? Colors.black87 : Colors.black,
                         ),
                       ),
                       if (!isRead)
                         Container(
                           width: 8,
                           height: 8,
                           decoration: BoxDecoration(
                             color: color,
                             shape: BoxShape.circle,
                           ),
                         )
                     ],
                   ),
                   const SizedBox(height: 6),
                   Text(
                     notification['message'] ?? '',
                     style: TextStyle(
                       fontSize: 13, 
                       color: isRead ? Colors.grey[600] : Colors.black87,
                       height: 1.4
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     _formatTimeAgo(notification['createdAt']),
                     style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                   ),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
