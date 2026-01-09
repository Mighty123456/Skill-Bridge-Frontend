import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../../widgets/premium_app_bar.dart';
import '../../data/job_accept_service.dart';

class JobDetailScreen extends StatefulWidget {
  static const String routeName = '/job-detail';
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _job;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    final result = await JobAcceptService.getJobDetails(widget.jobId);
    if (mounted) {
      if (result['success']) {
        setState(() {
          _job = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_job == null) {
      return const Scaffold(body: Center(child: Text('Job not found')));
    }

    final postedBy = _job!['user_id'] ?? {};
    final address = _job!['location']?['address_text'] ?? 'Unknown Location';
    final urgency = _job!['urgency_level'] ?? 'medium';
    final isEmergency = urgency == 'emergency';

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: const PremiumAppBar(title: 'Job Details'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: isEmergency ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: isEmergency ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2))
                         ),
                         child: Row(
                           children: [
                             Icon(isEmergency ? Icons.warning_amber_rounded : Icons.check_circle_outline, 
                                  size: 14, 
                                  color: isEmergency ? Colors.red : Colors.green),
                             const SizedBox(width: 4),
                             Text(
                               urgency.toUpperCase(),
                               style: TextStyle(
                                 color: isEmergency ? Colors.red : Colors.green,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 12,
                               ),
                             ),
                           ],
                         ),
                       ),
                       Text('Posted ${_formatTimeAgo(_job!['created_at'])}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Text(
                     _job!['job_title'] ?? 'No Title',
                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                   ),
                   const SizedBox(height: 12),
                   Row(
                     children: [
                       Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
                       const SizedBox(width: 4),
                       Expanded(
                         child: Text(
                           address,
                           style: TextStyle(color: Colors.grey[700], fontSize: 15),
                         ),
                       ),
                     ],
                   ),
                ],
              ),
            ),
             const SizedBox(height: 12),
             Container(
               color: Colors.white,
               padding: const EdgeInsets.all(20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Description', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 12),
                   Text(
                     _job!['job_description'] ?? 'No description provided.',
                     style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 12),
             Container(
               color: Colors.white,
               padding: const EdgeInsets.all(20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text('Customer', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                          child: Text(postedBy['name']?[0] ?? 'U', style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(postedBy['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Verified Customer', style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        )
                      ],
                    )
                 ],
               ),
             ),
            const SizedBox(height: 30),
            
            if (_job!['status'] == 'open')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to quotation screen or show phase 3 msg
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quotation System coming in Phase 3'))
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Send Quotation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
