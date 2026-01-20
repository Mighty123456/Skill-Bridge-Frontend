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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const PremiumAppBar(
        title: 'Submit Quotation',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Professional Job Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
                  ],
                  border: isEmergency ? Border.all(color: Colors.red.withValues(alpha: 0.3)) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isEmergency ? Colors.red : AppTheme.colors.primary).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEmergency ? Icons.warning_amber_rounded : Icons.work_rounded, 
                            color: isEmergency ? Colors.red : AppTheme.colors.primary, 
                            size: 24
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      job['location']?['address_text'] ?? 'Unknown Location', 
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                    const Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(
                      job['job_description'] ?? 'No description provided.',
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                    if (job['issue_photos'] != null && (job['issue_photos'] as List).whereType<String>().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('PHOTOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: (job['issue_photos'] as List).length,
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              // Maybe view full image
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                job['issue_photos'][index],
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text('YOUR QUOTATION DETAILS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1, color: Colors.black54)),
              ),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                     BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildField(
                      label: 'Labor Cost (₹)',
                      controller: _laborCostController,
                      hint: 'e.g. 500',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        if (double.tryParse(value) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                      label: 'Material Cost (₹)',
                      controller: _materialCostController,
                      hint: 'e.g. 200 (optional)',
                      icon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    _buildField(
                      label: 'Est. Timeline (Days)',
                      controller: _timelineController,
                      hint: 'e.g. 2',
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
                      label: 'Notes / Approach',
                      controller: _noteController,
                      hint: 'Briefly explain your work plan...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppTheme.colors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('SUBMIT QUOTATION', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
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
        return Center(
          child: Text(
            'Quotation window closed',
            style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 13),
          ),
        );
      }

      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      final isUrgent = hours < 1;
      final color = isUrgent ? Colors.red : Colors.orange;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_rounded, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            'Time remaining: ${hours}h ${minutes}m', 
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)
          ),
        ],
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
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, size: 22, color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide.none
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: Colors.grey[200]!)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 1.5)
            ),
          ),
        ),
      ],
    );
  }
}
