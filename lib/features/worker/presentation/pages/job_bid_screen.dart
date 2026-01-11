import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/features/tenant/data/quotation_service.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class JobBidScreen extends StatefulWidget {
  static const String routeName = '/job-bid';
  final Map<String, dynamic>? jobData;

  const JobBidScreen({super.key, this.jobData});

  @override
  State<JobBidScreen> createState() => _JobBidScreenState();
}

class _JobBidScreenState extends State<JobBidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _laborCostController = TextEditingController();
  final _materialCostController = TextEditingController();
  final _timelineController = TextEditingController();
  final _noteController = TextEditingController();
  final _quotationService = QuotationService();
  bool _isLoading = false;

  @override
  void dispose() {
    _laborCostController.dispose();
    _materialCostController.dispose();
    _timelineController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final job = widget.jobData;
    if (job == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _quotationService.submitQuotation(
        jobId: job['_id'],
        laborCost: double.parse(_laborCostController.text),
        materialCost: double.tryParse(_materialCostController.text) ?? 0,
        estimatedDays: int.tryParse(_timelineController.text) ?? 1,
        notes: _noteController.text,
      );

      if (response['success']) {
        if (mounted) {
          CustomFeedbackPopup.show(
            context,
            title: 'Success!',
            message: 'Your quotation has been submitted successfully.',
            type: FeedbackType.success,
            onConfirm: () {
              Navigator.pop(context, true); // Return to previous screen
            },
          );
        }
      } else {
        if (mounted) {
          CustomFeedbackPopup.show(
            context,
            title: 'Submission Failed',
            message: response['message'] ?? 'Could not submit quotation.',
            type: FeedbackType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomFeedbackPopup.show(
          context,
          title: 'Error',
          message: 'An unexpected error occurred: $e',
          type: FeedbackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.jobData;
    
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Job data missing')),
      );
    }

    final String title = job['job_title'] ?? 'Untitled Job';
    final String urgency = job['urgency_level'] ?? 'Normal';
    final bool isEmergency = urgency.toLowerCase() == 'emergency';

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: const PremiumAppBar(
        title: 'Submit Quotation',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isEmergency ? Colors.red : AppTheme.colors.primary).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (isEmergency ? Colors.red : AppTheme.colors.primary).withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isEmergency ? Icons.warning_amber_rounded : Icons.work_rounded, 
                          color: isEmergency ? Colors.red : AppTheme.colors.primary, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Urgency: ${urgency.toUpperCase()} • ${job['location']?['address_text'] ?? 'Unknown'}', 
                      style: const TextStyle(fontSize: 12, color: Colors.grey)
                    ),
                    const Divider(height: 24),
                    Text(
                      job['job_description'] ?? 'No description provided',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    if (job['issue_photos'] != null && (job['issue_photos'] as List).whereType<String>().isNotEmpty) ...[
                      const Text(
                        'PHOTOS:',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: (job['issue_photos'] as List).length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              job['issue_photos'][index],
                              width: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text('YOUR QUOTATION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2, color: Colors.grey)),
              const SizedBox(height: 16),

              _buildField(
                label: 'Labor Cost (₹)',
                controller: _laborCostController,
                hint: 'e.g. 500',
                icon: Icons.person_outline,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildField(
                label: 'Estimated Material Cost (₹)',
                controller: _materialCostController,
                hint: 'e.g. 200 (if any)',
                icon: Icons.build_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildField(
                label: 'Estimated Timeline (Days)',
                controller: _timelineController,
                hint: 'e.g. 1',
                icon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildField(
                label: 'Notes / Way of Work',
                controller: _noteController,
                hint: 'Briefly explain how you will fix this...',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppTheme.colors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SUBMIT QUOTATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              _buildTimeRemaining(job),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRemaining(Map<String, dynamic> job) {
    final endTimeStr = job['quotation_end_time'];
    if (endTimeStr == null) return const SizedBox.shrink();

    try {
      final endTime = DateTime.parse(endTimeStr);
      final remaining = endTime.difference(DateTime.now());
      
      if (remaining.isNegative) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text(
                'This job is no longer accepting quotations.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        );
      }

      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      final isUrgent = hours < 1;
      final color = isUrgent ? Colors.red : Colors.orange;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isUrgent ? Icons.timer_rounded : Icons.info_outline, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  'Time Remaining: ${hours}h ${minutes}m', 
                  style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isUrgent ? 'Hurry! Window is closing soon.' : 'Submit your best quote before the deadline.',
              style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppTheme.colors.primary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: Colors.black12)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: Colors.black12)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2)
            ),
          ),
        ),
      ],
    );
  }
}
