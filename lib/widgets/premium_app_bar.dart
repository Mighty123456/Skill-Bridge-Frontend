import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/features/auth/data/auth_service.dart';
import 'package:skillbridge_mobile/features/tenant/presentation/pages/tenant_notifications_screen.dart';
import 'package:skillbridge_mobile/features/worker/presentation/pages/worker_notifications_screen.dart';
import 'package:skillbridge_mobile/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:skillbridge_mobile/features/worker/data/notification_service.dart';

class PremiumAppBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;
  final String? title;
  final bool hideNotificationAction;
  final bool hideChatAction;
  final bool forceShowDefaultActions;

  const PremiumAppBar({
    super.key,
    this.actions,
    this.showBackButton = false,
    this.onNotificationTap,
    this.onChatTap,
    this.title,
    this.forceShowDefaultActions = false,
    this.hideNotificationAction = false,
    this.hideChatAction = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  State<PremiumAppBar> createState() => _PremiumAppBarState();
}

class _PremiumAppBarState extends State<PremiumAppBar> {
  // ... (existing state code)
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications();
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      final notifications = await NotificationService.getNotifications();
      if (mounted) {
        setState(() {
          _unreadNotificationCount = notifications.where((n) => n['read'] == false).length;
        });
      }
    } catch (_) {
      // Fail silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9), // Glassy white
            border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1.5)),
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: Row(
                children: [
                   // Leading: Back Button or Logo
                  if (widget.showBackButton)
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                      ),
                    )
                  else
                   Hero(
                    tag: 'app_logo_main',
                    child: Image.asset(
                      'assets/logoSkillBridge.png',
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => _buildTextLogo(),
                    ),
                  ),

                  if (widget.showBackButton) const SizedBox(width: 16),
                  
                  // Title
                  if (widget.title != null)
                    Expanded(
                      child: Text(
                        widget.title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const Spacer(),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Custom Actions (if any)
                      if (widget.actions != null) ...widget.actions!,

                      // Default Actions (Notification & Chat)
                      if (widget.actions == null || widget.forceShowDefaultActions) ...[
                        if (!widget.hideNotificationAction) ...[
                           const SizedBox(width: 8),
                           _buildActionIcon(
                             icon: Icons.notifications_none_rounded,
                             badgeCount: _unreadNotificationCount,
                             onTap: widget.onNotificationTap ?? () => _navigateByRole(context, 'notifications'),
                           ),
                        ],
                        
                        if (!widget.hideChatAction) ...[
                           const SizedBox(width: 12),
                           _buildActionIcon(
                             icon: Icons.chat_bubble_outline_rounded,
                             hasBadge: false, 
                             onTap: widget.onChatTap ?? () => _navigateByRole(context, 'chat'),
                           ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateByRole(BuildContext context, String destination) async {
    final result = await AuthService().getMe();
    if (!context.mounted) return;

    if (result['success']) {
      final user = result['data']['user'];
      final role = user['role'];
      final currentRoute = ModalRoute.of(context)?.settings.name;

      if (destination == 'notifications') {
        final targetRoute = role == 'worker' 
            ? WorkerNotificationsScreen.routeName 
            : TenantNotificationsScreen.routeName;
            
        if (currentRoute == ChatListScreen.routeName) {
           await Navigator.pushReplacementNamed(context, targetRoute);
        } else {
           await Navigator.pushNamed(context, targetRoute);
           if (mounted) _checkUnreadNotifications();
        }
      } else if (destination == 'chat') {
         if (currentRoute == TenantNotificationsScreen.routeName || 
             currentRoute == WorkerNotificationsScreen.routeName) {
            await Navigator.pushReplacementNamed(context, ChatListScreen.routeName);
         } else {
            await Navigator.pushNamed(context, ChatListScreen.routeName);
            if (mounted) _checkUnreadNotifications();
         }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to view notifications.'))
      );
    }
  }

  Widget _buildTextLogo() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Skill',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.colors.primary,
              letterSpacing: -1,
            ),
          ),
          TextSpan(
            text: 'Bridge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.colors.secondary,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    bool hasBadge = false,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ]
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.grey[800], size: 22),
            if (badgeCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    badgeCount > 9 ? '9+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (hasBadge)
               Positioned(
                right: 12,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
