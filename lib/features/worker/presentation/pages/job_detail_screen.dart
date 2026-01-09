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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: const PremiumAppBar(title: 'Job Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _job!['status'] == 'open' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (_job!['status'] ?? 'OPEN').toString().toUpperCase(),
                style: TextStyle(
                  color: _job!['status'] == 'open' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              _job!['job_title'] ?? 'No Title',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection('Description', _job!['job_description'] ?? 'No description provided.'),
            const SizedBox(height: 20),
            _buildSection('Urgency', urgency.toString().toUpperCase()),
            const SizedBox(height: 20),
            _buildSection('Customer', postedBy['name'] ?? 'Unknown User'),
            
            const SizedBox(height: 40),
            
            if (_job!['status'] == 'open')
              Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: AppTheme.colors.primary.withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Row(
                   children: [
                     Icon(Icons.info_outline, color: AppTheme.colors.primary),
                     const SizedBox(width: 12),
                     const Expanded(
                       child: Text(
                         'To accept this job, you will need to submit a quotation. (Coming in Phase 3)',
                         style: TextStyle(color: Colors.black87),
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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500]),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }
}
