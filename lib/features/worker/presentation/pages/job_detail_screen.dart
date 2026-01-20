import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../../widgets/premium_app_bar.dart';
import '../../../../widgets/custom_feedback_popup.dart';
import '../../data/job_accept_service.dart';
import '../../data/job_execution_service.dart';
import '../../../../features/tenant/presentation/widgets/status_timeline.dart';
import '../../../../features/chat/presentation/pages/chat_screen.dart';

class JobDetailScreen extends StatefulWidget {
  static const String routeName = '/worker-job-detail';
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _job;
  String? _errorMessage;
  final List<File> _completionPhotos = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() => _isLoading = true);
    final result = await JobAcceptService.getJobDetails(widget.jobId);
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

    final postedBy = _job!['user_id'] ?? {};
    final address = _job!['location']?['address_text'] ?? 'Unknown Location';
    final urgency = _job!['urgency_level'] ?? 'normal';
    final isEmergency = urgency == 'emergency';
    final status = _job!['status'] ?? 'open';
    final List<String> photos = (_job!['issue_photos'] as List?)?.whereType<String>().toList() ?? [];
    
    // Check if I am the assigned worker
    final isAssignedToMe = _job!['selected_worker_id'] != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey, consistent with dashboard
      appBar: const PremiumAppBar(title: 'Job Details', showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Status Header
            if (isAssignedToMe)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[700]!, Colors.green[500]!],
                    begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'CONGRATS! YOU ARE HIRED FOR THIS JOB',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

            // Timeline
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: StatusTimeline(currentStatus: status),
            ),

            // Job Title & Headings Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                   BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isEmergency ? Colors.red.withValues(alpha: 0.1) : AppTheme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: (isEmergency ? Colors.red : AppTheme.colors.primary).withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          isEmergency ? 'URGENT' : 'NEW OPPORTUNITY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isEmergency ? Colors.red : AppTheme.colors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Text(_formatTimeAgo(_job!['created_at']), style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _job!['job_title'] ?? 'Job Details',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 18, color: AppTheme.colors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('JOB DESCRIPTION', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
                      ]
                    ),
                    child: Text(
                      _job!['job_description'] ?? 'No description provided.',
                      style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800], fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Photos Gallery
            if (photos.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('ISSUE PHOTOS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: photos.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _showFullScreenImage(context, photos[index]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                         children: [
                            Image.network(
                              photos[index],
                              width: 180, 
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 180, height: 140,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                              ),
                            ),
                            Container(width: 180, height: 140, color: Colors.black.withValues(alpha: 0.05)), // Subtle overlay
                         ]
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Customer Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                          backgroundImage: postedBy['profileImage'] != null 
                            ? NetworkImage(postedBy['profileImage']) 
                            : null,
                          child: postedBy['profileImage'] == null 
                            ? Text(postedBy['name']?[0] ?? 'U', style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold, fontSize: 18))
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(postedBy['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.verified_rounded, size: 14, color: AppTheme.colors.primary),
                                  const SizedBox(width: 4),
                                  Text('Verified Customer • ${_job!['skill_required'] ?? 'Job'}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.green, size: 22),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calling ${postedBy['name'] ?? 'Customer'}...'))
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Contact and Action Buttons for Assigned Worker
            if (isAssignedToMe && status == 'in_progress') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      const Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey, letterSpacing: 1.0)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  ChatScreen.routeName,
                                  arguments: {
                                    'jobId': _job!['_id'],
                                    'recipientName': postedBy['name'] ?? 'Customer',
                                    'recipientId': postedBy['_id'],
                                  },
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                              label: const Text('Message'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.colors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.3)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Calling ${postedBy['name'] ?? 'Customer'}...'))
                                );
                              },
                              icon: const Icon(Icons.phone_rounded, size: 20),
                              label: const Text('Call Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.colors.primary,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                   ],
                )
              ),
              const SizedBox(height: 32),
              
              // Finish Job Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                    border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                         children: [
                            Container(
                               padding: const EdgeInsets.all(8),
                               decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                               child: Icon(Icons.check_circle_outline_rounded, color: AppTheme.colors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text('Complete Job', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                         ]
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Upload photos of your completed work to get paid.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      
                      // Image Picker for Completion
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            GestureDetector(
                              onTap: _pickCompletionPhotos,
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                                ),
                                child: Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                      Icon(Icons.add_a_photo_rounded, color: AppTheme.colors.primary, size: 28),
                                      const SizedBox(height: 4),
                                      Text('Add Photo', style: TextStyle(fontSize: 10, color: AppTheme.colors.primary, fontWeight: FontWeight.bold)),
                                   ]
                                ),
                              ),
                            ),
                            ..._completionPhotos.map((file) => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _completionPhotos.remove(file)),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.red, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting || _completionPhotos.isEmpty ? null : _submitCompletion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.colors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 8,
                            shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('SUBMIT PROOF & FINISH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (status == 'reviewing')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle),
                         child: const Icon(Icons.hourglass_top_rounded, color: Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Text('Under Review', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Waiting for customer confirmation.', style: TextStyle(color: Colors.black54, fontSize: 13)),
                           ]
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 40),
            
            if (status == 'open')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_job!['hasSubmittedQuotation'] == true) 
                      ? null 
                      : () {
                        Navigator.pushNamed(
                          context, 
                          '/job-bid', 
                          arguments: _job,
                        ).then((result) {
                          if (result == true) {
                            _loadJobDetails(); // Refresh to update hasSubmittedQuotation
                          }
                        });
                      },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: (_job!['hasSubmittedQuotation'] == true) 
                        ? Colors.grey[300] 
                        : AppTheme.colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: (_job!['hasSubmittedQuotation'] == true) ? 0 : 8,
                      shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      (_job!['hasSubmittedQuotation'] == true) 
                        ? 'QUOTATION SENT' 
                        : 'SEND QUOTATION', 
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w900, 
                        color: (_job!['hasSubmittedQuotation'] == true) ? Colors.grey[600] : Colors.white, 
                        letterSpacing: 1.0
                      ),
                    ),
                  ),
                ),
              ),
              
            const SizedBox(height: 60),
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

  Future<void> _pickCompletionPhotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _completionPhotos.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }

  Future<void> _submitCompletion() async {
    setState(() => _isSubmitting = true);
    
    final result = await JobExecutionService.submitCompletion(
      jobId: widget.jobId,
      photos: _completionPhotos,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success']) {
        CustomFeedbackPopup.show(
          context,
          title: 'Proof Submitted!',
          message: 'The customer has been notified. They will review and confirm completion.',
          type: FeedbackType.success,
          onConfirm: () {
            _loadJobDetails();
          },
        );
      } else {
        CustomFeedbackPopup.show(
          context,
          title: 'Error',
          message: result['message'] ?? 'Failed to submit proof',
          type: FeedbackType.error,
        );
      }
    }
  }
}
