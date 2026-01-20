import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../worker/data/notification_service.dart';
import 'quotation_comparison_screen.dart';

class TenantNotificationsScreen extends StatefulWidget {
  static const String routeName = '/tenant-notifications';
  const TenantNotificationsScreen({super.key});

  @override
  State<TenantNotificationsScreen> createState() => _TenantNotificationsScreenState();
}

class _TenantNotificationsScreenState extends State<TenantNotificationsScreen> {
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
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
            'No Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when you receive a quotation.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'system';
    final isRead = notification['read'] == true;
    
    IconData icon;
    Color color;
    
    switch (type) {
      case 'quotation_received':
        icon = Icons.assignment_outlined;
        color = AppTheme.colors.primary;
        break;
      case 'payment':
        icon = Icons.payment_rounded;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = Colors.blue;
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
           
          if (type == 'quotation_received' && notification['data'] != null && notification['data']['jobId'] != null) {
            await Navigator.pushNamed(
              context, 
              QuotationComparisonScreen.routeName,
              arguments: {'_id': notification['data']['jobId']}
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
                color: Colors.black.withValues(alpha: isRead ? 0.03 : 0.0),
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
                           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}
