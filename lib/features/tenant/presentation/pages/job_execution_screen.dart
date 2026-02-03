import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import '../widgets/status_timeline.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import '../../data/tenant_job_service.dart';
import 'package:skillbridge_mobile/features/auth/data/auth_service.dart';

class JobExecutionScreen extends StatefulWidget {
  static const String routeName = '/job-execution';
  final Map<String, dynamic> jobData;

  const JobExecutionScreen({super.key, required this.jobData});

  @override
  State<JobExecutionScreen> createState() => _JobExecutionScreenState();
}

class _JobExecutionScreenState extends State<JobExecutionScreen> {
  late Map<String, dynamic> _job;
  final _otpController = TextEditingController();
  final _jobService = TenantJobService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  final List<File> _evidencePhotos = [];
  bool _isLoading = false;
  Map<String, dynamic>? _currentUser;
  bool _isTenant = false;

  @override
  void initState() {
    super.initState();
    _job = widget.jobData;
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final result = await _authService.getMe();
    if (result['success'] == true && result['data'] != null) {
      setState(() {
        _currentUser = result['data'];
        // Check if current user is the owner (Tenant)
        // Adjust for typical MongoDB structure which might populate or might return string ID
        final jobUserId = _job['user_id'] is Map ? _job['user_id']['_id'] : _job['user_id'];
        _isTenant = jobUserId.toString() == _currentUser!['_id'].toString();
      });
    }
  }

  void _startJob(String otp) async {
    setState(() => _isLoading = true);
    final result = await _jobService.startJob(_job['_id'], otp);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      setState(() => _job = result['data']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Started!')));
    } else {
      _showError(result['message']);
    }
  }

  void _confirmCompletion() async {
    setState(() => _isLoading = true);
    final result = await _jobService.confirmCompletion(_job['_id']);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      setState(() => _job = result['data']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Confirmed & Closed!')));
    } else {
      _showError(result['message']);
    }
  }

  void _pickEvidence() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _evidencePhotos.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  void _completeJob() async {
    if (_evidencePhotos.isEmpty) {
      _showError('Please upload at least one photo as proof.');
      return;
    }
    
    setState(() => _isLoading = true);
    final result = await _jobService.submitCompletion(_job['_id'], _evidencePhotos);
    setState(() => _isLoading = false);

    if (!mounted) return;

     if (result['success']) {
      setState(() => _job = result['data']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Completed! Sent for review.')));
    } else {
      _showError(result['message']);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Scaffold(body: Center(child: PremiumLoader()));

    final status = _job['status'];


    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Job: ${status.toString().toUpperCase().replaceAll('_', ' ')}',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
             const StatusTimeline(currentStatus: 'In Progress'), // Make dynamic based on status
             const SizedBox(height: 20),
             
             // --- STATUS: ASSIGNED (WAITING FOR START) ---
             if (status == 'assigned') ...[
               Container(
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                 ),
                 child: Column(
                   children: [
                     const Icon(Icons.lock_clock, size: 48, color: Colors.orange),
                     const SizedBox(height: 16),
                     const Text('Secure Job Start', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     
                     if (_isTenant) ...[
                        const Text('Share this code with the worker to start:', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            _job['start_otp'] ?? '????', // Should be populated by backend if owner
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Waiting for worker to enter code...', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                     ] else ...[
                        const Text('Ask the customer for the 4-digit start code.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            hintText: '0000',
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _startJob(_otpController.text),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: _isLoading ? const PremiumLoader(size: 24, color: Colors.white) : const Text('VERIFY & START JOB'),
                          ),
                        ),
                     ]
                   ],
                 ),
               ),
             ],

             // --- STATUS: IN PROGRESS ---
             if (status == 'in_progress') ...[
                Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                 ),
                 child: Column(
                   children: [
                     const Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.timelapse, color: Colors.blue),
                         SizedBox(width: 8),
                         Text('Job is Live', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                       ],
                     ),
                     const SizedBox(height: 24),
                     const Divider(),
                     const SizedBox(height: 16),
                     const Text('Evidence & Completion', style: TextStyle(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     
                     if (_isTenant) ...[
                        const Text('Worker is currently performing the task.', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('You will be notified to review evidence once done.', style: TextStyle(fontSize: 12)),
                     ] else ...[
                        if (_evidencePhotos.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _evidencePhotos.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.file(_evidencePhotos[index], width: 100, fit: BoxFit.cover),
                                ),
                              ),
                            ),
    
                         const SizedBox(height: 16),
                         OutlinedButton.icon(
                           onPressed: _pickEvidence,
                           icon: const Icon(Icons.camera_alt),
                           label: const Text('Capture/Upload Evidence'),
                         ),
                         const SizedBox(height: 24),
                         SizedBox(
                           width: double.infinity,
                           height: 50,
                           child: ElevatedButton(
                             onPressed: _isLoading ? null : _completeJob,
                             style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.primary),
                             child: _isLoading ? const PremiumLoader(size: 24, color: Colors.white) : const Text('MARK JOB AS COMPLETED'),
                           ),
                         ),
                     ]
                   ],
                 ),
               )
             ],

             // --- STATUS: REVIEWING ---
             if (status == 'reviewing') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                       const Row(
                        children: [
                          Icon(Icons.hourglass_top, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(child: Text('Job Finished. Reviewing Evidence.')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Display Evidence Photos (Read from backend array)
                      // Ideally _job['completion_photos'] is available
                      if (_job['completion_photos'] != null && (_job['completion_photos'] as List).isNotEmpty)
                         SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (_job['completion_photos'] as List).length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network((_job['completion_photos'] as List)[index], width: 100, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                         ),

                      const SizedBox(height: 16),

                      if (_isTenant) 
                        SizedBox(
                           width: double.infinity,
                           height: 50,
                           child: ElevatedButton(
                             onPressed: _isLoading ? null : _confirmCompletion,
                             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                             child: _isLoading ? const PremiumLoader(size: 24, color: Colors.white) : const Text('CONFIRM COMPLETION'),
                           ),
                        )
                      else
                         const Text('Waiting for customer confirmation.', style: TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                )
             ],
             
             // --- STATUS: COMPLETED ---
             if (status == 'completed') ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(child: Text('Job successfully completed! Payment processing.')),
                    ],
                  ),
                )
             ],
          ],
        ),
      ),
    );
  }
}
