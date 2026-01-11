import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/features/auth/data/auth_service.dart';
import 'package:skillbridge_mobile/features/tenant/presentation/pages/tenant_notifications_screen.dart';
import 'package:skillbridge_mobile/features/worker/presentation/pages/worker_notifications_screen.dart';
import 'package:skillbridge_mobile/features/chat/presentation/pages/chat_list_screen.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onChatTap;
  final String? title;

  const PremiumAppBar({
    super.key,
    this.actions,
    this.showBackButton = false,
    this.onNotificationTap,
    this.onChatTap,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Logo or Title (never show back button)
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                )
              else
                Hero(
                  tag: 'app_logo_main',
                  child: Image.asset(
                    'assets/logoSkillBridge.png',
                    height: 45,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => _buildTextLogo(),
                  ),
                ),
              
              const Spacer(),
              
              // Actions
              if (actions != null) 
                ...actions!
              else ...[
                _buildActionIcon(
                  icon: Icons.notifications_none_rounded,
                  hasBadge: true,
                  onTap: onNotificationTap ?? () => _navigateByRole(context, 'notifications'),
                ),
                const SizedBox(width: 8),
                _buildActionIcon(
                  icon: Icons.chat_bubble_outline_rounded,
                  hasBadge: false,
                  onTap: onChatTap ?? () => _navigateByRole(context, 'chat'),
                ),
              ],
            ],
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

      if (destination == 'notifications') {
        if (role == 'worker') {
          Navigator.pushNamed(context, WorkerNotificationsScreen.routeName);
        } else {
          Navigator.pushNamed(context, TenantNotificationsScreen.routeName);
        }
      } else if (destination == 'chat') {
         Navigator.pushNamed(context, ChatListScreen.routeName);
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
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.colors.primary,
            ),
          ),
          TextSpan(
            text: 'Bridge',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppTheme.colors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required bool hasBadge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: const Color(0xFF374151), size: 26),
            if (hasBadge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
