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
      backgroundColor: Colors.white,
      appBar: const PremiumAppBar(title: 'Job Assignment', showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Status Header
            if (isAssignedToMe)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[700]!, Colors.green[500]!],
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'CONGRATS! YOU ARE HIRED FOR THIS JOB',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: StatusTimeline(currentStatus: status),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEmergency ? Colors.red.withValues(alpha: 0.1) : AppTheme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isEmergency ? 'URGENT' : 'NEW OPPORTUNITY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isEmergency ? Colors.red : AppTheme.colors.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Text(_formatTimeAgo(_job!['created_at']), style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _job!['job_title'] ?? 'Job Details',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppTheme.colors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(color: Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Job Description', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(
                    _job!['job_description'] ?? 'No description provided.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800], fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Photos Gallery
            if (photos.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Photos of the Issue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        width: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 280,
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

            // Customer Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Information', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                          backgroundImage: postedBy['profileImage'] != null 
                            ? NetworkImage(postedBy['profileImage']) 
                            : null,
                          child: postedBy['profileImage'] == null 
                            ? Text(postedBy['name']?[0] ?? 'U', style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold))
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(postedBy['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text('Verified Customer • ${_job!['skill_required'] ?? 'Job'}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone_rounded, color: Colors.green),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling ${postedBy['name'] ?? 'Customer'}...'))
                            );
                          },
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Execution Actions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            ChatScreen.routeName,
                            arguments: {
                              'jobId': _job!['_id'],
                              'recipientName': postedBy['name'] ?? 'Customer',
                            },
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('MESSAGE'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        icon: const Icon(Icons.phone),
                        label: const Text('CALL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Finish Job Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Finish This Job', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        'Upload photos of the completed work to notify the customer.',
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                                ),
                                child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                              ),
                            ),
                            ..._completionPhotos.map((file) => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _completionPhotos.remove(file)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSubmitting 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('SUBMIT COMPLETION PROOF', style: TextStyle(fontWeight: FontWeight.bold)),
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Waiting for customer to confirm your work.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 40),
            
            if (status == 'open')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      elevation: 0,
                    ),
                    child: Text(
                      (_job!['hasSubmittedQuotation'] == true) 
                        ? 'QUOTATION SENT' 
                        : 'SEND QUOTATION', 
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.w900, 
                        color: (_job!['hasSubmittedQuotation'] == true) ? Colors.grey[600] : Colors.white, 
                        letterSpacing: 1.2
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
