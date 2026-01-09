import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../data/notification_service.dart';
import 'job_detail_screen.dart';

class WorkerNotificationsScreen extends StatefulWidget {
  static const String routeName = '/worker-notifications';
  const WorkerNotificationsScreen({super.key});

  @override
  State<WorkerNotificationsScreen> createState() => _WorkerNotificationsScreenState();
}

class _WorkerNotificationsScreenState extends State<WorkerNotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

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
      appBar: AppBar(
        title: const Text('Notifications & Support'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Support / Dispute'),
        icon: const Icon(Icons.support_agent_rounded),
        backgroundColor: AppTheme.colors.secondary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
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
        icon = Icons.notification_important_rounded;
        color = Colors.orange;
        break;
      case 'payment':
        icon = Icons.account_balance_wallet_rounded;
        color = Colors.green;
        break;
      case 'job_update':
        icon = Icons.work_history_rounded;
        color = Colors.blue;
        break;
      default:
        icon = Icons.info_outline_rounded;
        color = AppTheme.colors.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isRead ? Colors.white : color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              notification['message'] ?? '',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(notification['createdAt']),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          if (!isRead) {
            NotificationService.markAsRead(notification['_id']);
            setState(() {
              notification['read'] = true;
            });
          }
           
          // Navigate to detail if it's a job alert
          if (type == 'job_alert' && notification['data'] != null && notification['data']['jobId'] != null) {
            // Navigate to details
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (_) => JobDetailScreen(jobId: notification['data']['jobId'])
              )
            );
          }
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    // Simple format for now
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
