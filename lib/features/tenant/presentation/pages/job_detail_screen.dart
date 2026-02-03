import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import '../widgets/status_timeline.dart';
import 'quotation_comparison_screen.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import 'package:skillbridge_mobile/features/worker/data/job_execution_service.dart';

import 'package:skillbridge_mobile/features/tenant/data/tenant_job_service.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
      return const Scaffold(body: Center(child: PremiumLoader()));
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
      backgroundColor: const Color(0xFFF2F4F7), // Professional background
      appBar: PremiumAppBar(
        title: 'Job Details',
        showBackButton: true,
        actions: [
          if (status == 'open')
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status & Timeline Section (Card)
            Container(
              decoration: _cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Dynamic Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (status == 'completed' ? Colors.green : (status == 'open' ? AppTheme.colors.primary : Colors.orange)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          status == 'completed' ? Icons.check_circle_rounded : (status == 'open' ? Icons.campaign_rounded : Icons.engineering_rounded),
                          size: 16,
                          color: status == 'completed' ? Colors.green : (status == 'open' ? AppTheme.colors.primary : Colors.orange),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status == 'open' ? 'Open for Quotations' : (status == 'completed' ? 'Job Completed' : 'Work in Progress'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: status == 'completed' ? Colors.green : (status == 'open' ? AppTheme.colors.primary : Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  StatusTimeline(currentStatus: status.toUpperCase().replaceAll('_', ' ')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Main Info Card (Title, Desc, Details)
            Container(
              decoration: _cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Posted ${_formatTimeAgo(_job!['created_at'])}', 
                              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)
                            ),
                          ],
                        ),
                      ),
                      // Skill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _job!['skill_required']?.toUpperCase() ?? 'GENERAL',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(height: 1),
                  ),
                  
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 15),
                  ),
                  const SizedBox(height: 24),

                  // Key Details Grid (Location, Urgency)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.location_on_outlined, 'Location', address),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                         _buildDetailRow(Icons.bolt_rounded, 'Urgency', urgency.toUpperCase()), // Using rounded icon
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

             // 3. Photos Section
             if (photos.isNotEmpty)
              Container(
                decoration: _cardDecoration(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       children: [
                         const Icon(Icons.image_outlined, size: 20, color: Colors.black87),
                         const SizedBox(width: 8),
                         Text(
                           'Photos',
                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                         ),
                       ],
                     ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: photos.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => _showFullScreenImage(context, photos[index]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              photos[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (photos.isNotEmpty) const SizedBox(height: 16),

            // 4. Worker Assigned Section
            if (worker != null) ...[
              Container(
                decoration: _cardDecoration(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Professional',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                          backgroundImage: worker['profileImage'] != null ? NetworkImage(worker['profileImage']) : null,
                          child: worker['profileImage'] == null 
                            ? Text(worker['name']?[0] ?? 'W', style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold, fontSize: 18))
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(worker['name'] ?? 'Professional', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star_rounded, size: 16, color: Colors.amber[700]),
                                  const SizedBox(width: 4),
                                  Text('4.8 (12 Reviews)', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        Row(
                          children: [
                            _buildActionIconBtn(
                              Icons.chat_bubble_outline_rounded, 
                              AppTheme.colors.primary, 
                              () {
                                Navigator.pushNamed(
                                   context,
                                   ChatScreen.routeName,
                                   arguments: {
                                     'jobId': _job!['_id'],
                                     'recipientName': worker['name'] ?? 'Worker',
                                     'recipientId': worker['_id'],
                                   },
                                 );
                              }
                            ),
                            const SizedBox(width: 12),
                            _buildActionIconBtn(
                              Icons.phone_rounded, 
                              Colors.green, 
                              () {
                                  if (worker['phone'] != null && worker['phone'].toString().isNotEmpty) {
                                    _makePhoneCall(worker['phone']);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Phone number not available'))
                                    );
                                  }
                              }
                            ),
                          ],
                        ),
                      ],
                    ),
                   ],
                 ),
               ),
               const SizedBox(height: 16),
               
               // Completion Review Section for Tenant
               if (status == 'reviewing') ...[
                 Container(
                   decoration: BoxDecoration(
                     color: Colors.green.withValues(alpha: 0.04), // Very subtle green tint
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                   ),
                   padding: const EdgeInsets.all(20),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Row(
                         children: [
                           Icon(Icons.verified_rounded, color: Colors.green, size: 28),
                           SizedBox(width: 12),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('Work Completed', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                                 Text('Please review the proof below.', style: TextStyle(color: Colors.black54, fontSize: 13)),
                               ],
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 20),
                       
                       // Completion Photos
                       if ((_job!['completion_photos'] as List?)?.isNotEmpty ?? false)
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
                       
                       const SizedBox(height: 24),
                       Row(
                         children: [
                           Expanded(
                             child: OutlinedButton(
                               onPressed: () {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(content: Text('Dispute system coming soon!'))
                                 );
                               },
                               style: OutlinedButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(vertical: 14),
                                 side: BorderSide(color: Colors.red[300]!),
                                 foregroundColor: Colors.red,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                               ),
                               child: const Text('Dispute', style: TextStyle(fontWeight: FontWeight.bold)),
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             flex: 2,
                             child: ElevatedButton(
                               onPressed: _isConfirming ? null : _confirmCompletion,
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.green,
                                 foregroundColor: Colors.white,
                                 padding: const EdgeInsets.symmetric(vertical: 14),
                                 elevation: 0,
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                               ),
                               child: _isConfirming 
                                 ? const SizedBox(height: 20, width: 20, child: PremiumLoader(size: 20, color: Colors.white))
                                 : const Text('Confirm & Close Job', style: TextStyle(fontWeight: FontWeight.bold)),
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
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [Colors.blue[50]!, Colors.white],
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                     ),
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: Colors.blue[100]!),
                   ),
                   child: Column(
                     children: [
                       const Icon(Icons.verified, color: Colors.blue, size: 48),
                       const SizedBox(height: 12),
                       const Text(
                         'Job Finished',
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         'Completed on ${_formatDate(_job!['updated_at'])}',
                         style: TextStyle(color: Colors.grey[600], fontSize: 14),
                       ),
                       const SizedBox(height: 20),
                       
                       if ((_job!['completion_photos'] as List?)?.isNotEmpty ?? false) ...[
                         SizedBox(
                           height: 80,
                           child: ListView.separated(
                             scrollDirection: Axis.horizontal,
                             shrinkWrap: true,
                             itemCount: (_job!['completion_photos'] as List).length,
                             separatorBuilder: (context, index) => const SizedBox(width: 8),
                             itemBuilder: (context, index) {
                               final url = _job!['completion_photos'][index];
                               return ClipRRect(
                                 borderRadius: BorderRadius.circular(8),
                                 child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                               );
                             },
                           ),
                         ),
                         const SizedBox(height: 20),
                       ],

                       ElevatedButton(
                         onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Review system coming soon!'))
                           );
                         },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.white,
                           foregroundColor: Colors.blue,
                           elevation: 0,
                           side: const BorderSide(color: Colors.blue),
                           minimumSize: const Size(double.infinity, 48),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                         child: const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.bold)),
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
                     elevation: 2,
                     shadowColor: AppTheme.colors.primary.withValues(alpha: 0.3),
                   ),
                   child: const Text('View Received Quotations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 ),
               ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Very subtle shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
  }

  Widget _buildActionIconBtn(IconData icon, Color color, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.normal)),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Remove any non-digit characters except '+' at the start
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        // Fallback for some devices/simulators: try launching without checking 'canLaunch'
        // or just print the error
        debugPrint('Could not launch using canLaunchUrl check. Trying direct launch...');
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Error launching dialer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer: $cleanNumber')),
        );
      }
    }
  }
}
