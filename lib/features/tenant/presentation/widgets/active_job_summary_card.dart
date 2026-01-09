import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

class ActiveJobSummaryCard extends StatelessWidget {
  const ActiveJobSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.colors.jobCardSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.plumbing, color: AppTheme.colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kitchen Sink Leakage',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Status: In Progress',
                      style: TextStyle(color: AppTheme.colors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹500.00',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Est. Total',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=worker1'),
              ),
              const SizedBox(width: 8),
              const Text(
                'Assigned to John Doe',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                'Started 20m ago',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
