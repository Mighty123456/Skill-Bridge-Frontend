import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogo;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLogo = false,
    this.leading,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.colors.primary,
      foregroundColor: AppTheme.colors.onPrimary,
      elevation: 0,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Image.asset(
              'assets/logoSkillBridge.png',
              height: 60,
              width: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 14),
          ],
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

