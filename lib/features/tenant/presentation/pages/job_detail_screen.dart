import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../widgets/status_timeline.dart';
import 'quotation_comparison_screen.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import 'package:skillbridge_mobile/features/worker/data/job_execution_service.dart';

import 'package:skillbridge_mobile/features/tenant/data/tenant_job_service.dart';
import '../../../chat/presentation/pages/chat_screen.dart';

class JobDetailScreen extends StatefulWidget {
  static const String routeName = '/tenant-job-detail';
  final String? jobId;
  final Map<String, dynamic>? jobData;

  const JobDetailScreen({super.key, this.jobId, this.jobData});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _job;
  String? _errorMessage;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (widget.jobData != null) {
      setState(() {
        _job = widget.jobData;
        _isLoading = false;
      });
    } else if (widget.jobId != null) {
      _loadJobDetails();
    } else {
      setState(() {
        _errorMessage = "Job Information Missing";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadJobDetails() async {
    setState(() => _isLoading = true);
    final result = await TenantJobService.getJobDetails(widget.jobId!);
    if (mounted) {
      setState(() {
        if (result['success']) {
          _job = result['data'];
        } else {
          _errorMessage = result['message'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null || _job == null) {
      return Scaffold(
        appBar: const PremiumAppBar(title: 'Error', showBackButton: true),
        body: Center(child: Text(_errorMessage ?? 'Job not found')),
      );
    }

    final String title = _job!['job_title'] ?? 'Untitled';
    final String description = _job!['job_description'] ?? 'No description provided.';
    final String address = _job!['location']?['address_text'] ?? 'Unknown Location';
    final String status = _job!['status'] ?? 'open';
    final String urgency = _job!['urgency_level'] ?? 'normal';
    final List<String> photos = (_job!['issue_photos'] as List?)?.whereType<String>().toList() ?? [];
    final worker = _job!['selected_worker_id'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PremiumAppBar(
        title: 'Job Details',
        showBackButton: true,
        actions: [
          if (status == 'open')
            TextButton(
              onPressed: () {},
              child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Page Header - Dynamic Status Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (status == 'completed' ? Colors.green : (status == 'open' ? AppTheme.colors.primary : Colors.orange)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (status == 'completed' ? Colors.green : (status == 'open' ? AppTheme.colors.primary : Colors.orange)).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status == 'completed' ? Icons.check_circle_outline : (status == 'open' ? Icons.campaign_outlined : Icons.engineering_outlined),
                    size: 14,
                    color: status == 'completed' ? Colors.green : (status == 'open' ? AppTheme.colors.primary : Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status == 'open' ? 'OPEN FOR QUOTATIONS' : (status == 'completed' ? 'JOB COMPLETED' : 'WORK IN PROGRESS'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: status == 'completed' ? Colors.green : (status == 'open' ? AppTheme.colors.primary : Colors.orange),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Status Timeline
            StatusTimeline(currentStatus: status.toUpperCase().replaceAll('_', ' ')),
            const SizedBox(height: 32),

            // Job Title and Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_job!['skill_required']?.toUpperCase() ?? 'GENERAL'} • Posted ${_formatTimeAgo(_job!['created_at'])}', 
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13)
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Job Description
            const Text(
              'Job Description',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.2),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.grey[800], height: 1.6, fontSize: 15, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 32),

            // Photos Section (Moved below description)
            if (photos.isNotEmpty) ...[
              const Text(
                'Issue Photos',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.2),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: photos.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _showFullScreenImage(context, photos[index]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        photos[index],
                        width: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 240,
                          color: Colors.grey[100],
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.location_on_outlined, 'Location', address),
                  const Divider(height: 32),
                  _buildDetailRow(Icons.bolt_outlined, 'Urgency', urgency.toUpperCase()),
                  const Divider(height: 32),
                  _buildDetailRow(Icons.event_note_outlined, 'Status', status.toUpperCase().replaceAll('_', ' ')),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Worker Assigned Section
            if (worker != null) ...[
              const Text(
                'Assigned Professional',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.2),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                      backgroundImage: worker['profileImage'] != null ? NetworkImage(worker['profileImage']) : null,
                      child: worker['profileImage'] == null 
                        ? Text(worker['name']?[0] ?? 'W', style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold))
                        : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(worker['name'] ?? 'Professional', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Contact: ${worker['phone'] ?? 'N/A'}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                     IconButton(
                       icon: const Icon(Icons.phone_rounded, color: Colors.green),
                       onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling ${worker['name'] ?? 'Professional'}...'))
                          );
                       },
                     ),
                   ],
                 ),
               ),
               
               // Completion Review Section for Tenant
               if (status == 'reviewing') ...[
                 const SizedBox(height: 32),
                 const Text(
                   'Review Completion Proof',
                   style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.2),
                 ),
                 const SizedBox(height: 16),
                 Container(
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     color: Colors.green.withValues(alpha: 0.05),
                     borderRadius: BorderRadius.circular(24),
                     border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Row(
                         children: [
                           Icon(Icons.verified, color: Colors.green),
                           SizedBox(width: 8),
                           Text('Worker has finished!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                         ],
                       ),
                       const SizedBox(height: 16),
                       Text(
                         'Please review the work proof photos below and confirm if the work is satisfactory.',
                         style: TextStyle(color: Colors.grey[700], fontSize: 14),
                       ),
                       const SizedBox(height: 20),
                       
                       // Completion Photos
                       if ((_job!['completion_photos'] as List?)?.isNotEmpty ?? false)
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: (_job!['completion_photos'] as List).length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final url = _job!['completion_photos'][index];
                              return GestureDetector(
                                onTap: () => _showFullScreenImage(context, url),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(url, width: 120, height: 120, fit: BoxFit.cover),
                                ),
                              );
                            },
                          ),
                        ),
                       
                       const SizedBox(height: 24),
                       Row(
                         children: [
                           Expanded(
                             child: OutlinedButton.icon(
                               onPressed: () {
                                 Navigator.pushNamed(
                                   context,
                                   ChatScreen.routeName,
                                   arguments: {
                                     'jobId': _job!['_id'],
                                     'recipientName': worker['name'] ?? 'Worker',
                                     'recipientId': worker['_id'],
                                   },
                                 );
                               },
                               icon: const Icon(Icons.chat_bubble_outline),
                               label: const Text('MESSAGE'),
                               style: OutlinedButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(vertical: 16),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                               ),
                             ),
                           ),
                           const SizedBox(width: 8),
                           Expanded(
                             child: OutlinedButton(
                               onPressed: () {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(content: Text('Dispute system coming soon!'))
                                 );
                               },
                               style: OutlinedButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(vertical: 16),
                                 side: const BorderSide(color: Colors.red),
                                 foregroundColor: Colors.red,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                               ),
                               child: const Text('DISPUTE'),
                             ),
                           ),
                           const SizedBox(width: 8),
                           Expanded(
                             flex: 2,
                             child: ElevatedButton(
                               onPressed: _isConfirming ? null : _confirmCompletion,
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.green,
                                 foregroundColor: Colors.white,
                                 padding: const EdgeInsets.symmetric(vertical: 16),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                               ),
                               child: _isConfirming 
                                 ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                 : const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold)),
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                 ),
               ],
               
               // Completed State UI
               if (status == 'completed') ...[
                 const SizedBox(height: 32),
                 Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     color: Colors.blue.withValues(alpha: 0.05),
                     borderRadius: BorderRadius.circular(28),
                     border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                   ),
                   child: Column(
                     children: [
                       const Icon(Icons.stars_rounded, color: Colors.blue, size: 48),
                       const SizedBox(height: 16),
                       const Text(
                         'Job Successfully Completed!',
                         style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                       ),
                       const SizedBox(height: 8),
                       Text(
                         'This job was finished on ${_formatDate(_job!['updated_at'])}',
                         style: TextStyle(color: Colors.grey[600], fontSize: 13),
                       ),
                       
                       if ((_job!['completion_photos'] as List?)?.isNotEmpty ?? false) ...[
                         const SizedBox(height: 24),
                         const Align(
                           alignment: Alignment.centerLeft,
                           child: Text('Work Proof Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                         ),
                         const SizedBox(height: 12),
                         SizedBox(
                           height: 100,
                           child: ListView.separated(
                             scrollDirection: Axis.horizontal,
                             itemCount: (_job!['completion_photos'] as List).length,
                             separatorBuilder: (context, index) => const SizedBox(width: 10),
                             itemBuilder: (context, index) {
                               final url = _job!['completion_photos'][index];
                               return GestureDetector(
                                 onTap: () => _showFullScreenImage(context, url),
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(12),
                                   child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                                 ),
                               );
                             },
                           ),
                         ),
                       ],
                       
                       const SizedBox(height: 24),
                       OutlinedButton(
                         onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Review system coming soon!'))
                           );
                         },
                         style: OutlinedButton.styleFrom(
                           minimumSize: const Size(double.infinity, 50),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                         ),
                         child: const Text('WRITE A WORKER REVIEW'),
                       ),
                     ],
                   ),
                 ),
               ],
             ] else if (status == 'open') ...[
               const SizedBox(height: 12),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () => Navigator.pushNamed(
                     context, 
                     QuotationComparisonScreen.routeName,
                     arguments: _job,
                   ),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppTheme.colors.primary,
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 18),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     elevation: 0,
                   ),
                   child: const Text('VIEW QUOTATIONS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                 ),
               ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppTheme.colors.primary),
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCompletion() async {
    setState(() => _isConfirming = true);
    
    final result = await JobExecutionService.confirmCompletion(widget.jobId ?? _job!['_id']);

    if (mounted) {
      setState(() => _isConfirming = false);
      if (result['success']) {
        CustomFeedbackPopup.show(
          context,
          title: 'Job Completed!',
          message: 'The job has been closed. Thank you for using SkillBridge.',
          type: FeedbackType.success,
          onConfirm: () {
            _loadJobDetails();
          },
        );
      } else {
        CustomFeedbackPopup.show(
          context,
          title: 'Error',
          message: result['message'] ?? 'Failed to confirm completion',
          type: FeedbackType.error,
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'recently';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'recently';
    return '${date.day}/${date.month}/${date.year}';
  }
}
