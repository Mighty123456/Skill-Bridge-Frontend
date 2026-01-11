import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

import '../pages/job_detail_screen.dart';

class ActiveJobSummaryCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  const ActiveJobSummaryCard({super.key, required this.jobData});

  IconData _getSkillIcon(String? skill) {
    if (skill == null) return Icons.work_outline;
    switch (skill.toLowerCase()) {
      case 'plumbing': return Icons.plumbing_rounded;
      case 'electric':
      case 'electrical': return Icons.electric_bolt_rounded;
      case 'cleaning': return Icons.cleaning_services_rounded;
      case 'painting': return Icons.format_paint_rounded;
      case 'carpentry': return Icons.carpenter_rounded;
      case 'gardening': return Icons.yard_rounded;
      case 'delivery': return Icons.moped_rounded;
      default: return Icons.handyman_rounded;
    }
  }

  String _getTimeAgo(String? dateStr) {
    if (dateStr == null) return 'Recently';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      return '${diff.inMinutes}m ago';
    } catch (e) { return 'Recently'; }
  }

  @override
  Widget build(BuildContext context) {
    final title = jobData['job_title'] ?? 'Untitled Job';
    final status = jobData['status']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'PENDING';
    final skill = jobData['skill_required'];
    final createdAt = jobData['created_at'];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context, 
          JobDetailScreen.routeName,
          arguments: {'jobData': jobData},
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
                      color: AppTheme.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getSkillIcon(skill), color: AppTheme.colors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Status: $status',
                          style: TextStyle(
                            color: status == 'OPEN' ? Colors.green : AppTheme.colors.primary, 
                            fontSize: 12, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Posted ${_getTimeAgo(createdAt)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    '${jobData['quotation_count'] ?? 0} Bids',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.colors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
