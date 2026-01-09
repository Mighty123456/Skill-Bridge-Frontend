import 'package:flutter/material.dart';

class SkillCategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const SkillCategoryCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48, // Reduced slightly to ensure it fits in tight constraints
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
          ),
          child: Icon(
            icon, 
            color: Theme.of(context).primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A4A4A),
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
