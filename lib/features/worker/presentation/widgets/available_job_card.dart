import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import '../pages/job_bid_screen.dart';

class AvailableJobCard extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const AvailableJobCard({
    super.key,
    required this.jobData,
  });

  String _getRemainingTime() {
    final endTimeStr = jobData['quotation_end_time'];
    if (endTimeStr == null) return 'Flexible';
    try {
      final endTime = DateTime.parse(endTimeStr);
      final remaining = endTime.difference(DateTime.now());
      if (remaining.isNegative) return 'Closed';
      if (remaining.inHours > 24) return '${remaining.inDays}d left';
      if (remaining.inHours > 0) return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
      return '${remaining.inMinutes}m left';
    } catch (e) {
      return 'Limited';
    }
  }

  Color _getTimerColor() {
    final endTimeStr = jobData['quotation_end_time'];
    if (endTimeStr == null) return Colors.grey;
    try {
      final endTime = DateTime.parse(endTimeStr);
      final remaining = endTime.difference(DateTime.now());
      if (remaining.isNegative) return Colors.grey;
      if (remaining.inHours < 1) return Colors.red;
      if (remaining.inHours < 6) return Colors.orange;
      return Colors.green;
    } catch (e) {
      return Colors.orange;
    }
  }

  String _getTimeAgo() {
    final createdAt = jobData['created_at'];
    if (createdAt == null) return 'Recently';
    try {
      final date = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return 'Recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgency = jobData['urgency_level'] ?? 'medium';
    final bool isEmergency = urgency.toLowerCase() == 'emergency';
    final title = jobData['job_title'] ?? 'Untitled Job';
    final location = jobData['location']?['address_text'] ?? 'Unknown Location';
    
    // AI & Distance Logic
    final distanceKm = jobData['distanceKm'] != null ? '${jobData['distanceKm']} km' : 'Nearby';
    final matchScore = jobData['matchScore'];
    final aiLabel = jobData['aiLabel']; // 'Top Match'
    
    final timerText = _getRemainingTime();
    final timerColor = _getTimerColor();
    final postedTime = _getTimeAgo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isEmergency ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isEmergency 
                ? Colors.red.withValues(alpha: 0.05) 
                : Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // AI Top Match Badge
                  if (aiLabel != null && aiLabel == 'Top Match') 
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]), // Violet
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                           BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('98% Match', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEmergency ? Colors.red : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEmergency) const Icon(Icons.flash_on, color: Colors.white, size: 12),
                        if (isEmergency) const SizedBox(width: 4),
                        Text(
                          urgency.toUpperCase(),
                          style: TextStyle(
                            color: isEmergency ? Colors.white : Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Quotation Status Badge
                  if (jobData['hasSubmittedQuotation'] == true) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'SENT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Text(postedTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Text('($distanceKm)', style: TextStyle(color: AppTheme.colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              if (jobData['issue_photos'] != null && (jobData['issue_photos'] as List).whereType<String>().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage((jobData['issue_photos'] as List).whereType<String>().first),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (matchScore != null && matchScore > 0)
                     Text('Match Score: $matchScore%', style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
                  
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: timerColor, size: 14),
                      const SizedBox(width: 4),
                      Text(timerText, style: TextStyle(color: timerColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: timerText == 'Closed' ? null : () {
                  Navigator.pushNamed(context, JobBidScreen.routeName, arguments: jobData);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  backgroundColor: timerText == 'Closed' ? Colors.grey[300] : AppTheme.colors.primary,
                  foregroundColor: timerText == 'Closed' ? Colors.grey : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(timerText == 'Closed' ? 'CLOSED' : 'Send Quote'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

