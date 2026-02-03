import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import 'package:skillbridge_mobile/features/tenant/data/quotation_service.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  final List<String> _availableTags = [
    'Original Spare Parts',
    '30-Day Warranty',
    'Premium Service',
    'Emergency Rush',
    'Certified Expert',
    'All-Inclusive',
  ];
  final List<String> _selectedTags = [];
  Map<String, dynamic>? _priceStats;
  File? _videoFile;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 30));
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
    }
  }

  Future<void> _fetchStats() async {
    if (widget.jobData == null || widget.jobData!['skill_required'] == null) return;
    
    final skill = widget.jobData!['skill_required'];
    final result = await _quotationService.getQuotationStats(skill);
    if (result['success'] == true && result['data'] != null) {
      if (mounted) setState(() => _priceStats = result['data']);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final job = widget.jobData;
    if (job == null) return;

    // AI Price Warning Logic
    final labor = double.tryParse(_laborCostController.text) ?? 0;
    final materials = double.tryParse(_materialCostController.text) ?? 0;
    final total = labor + materials;

    if (_priceStats != null && _priceStats!['avgCost'] != null) {
      final double avg = (_priceStats!['avgCost'] as num).toDouble();
      if (avg > 0 && total < (avg * 0.5)) {
        // Warning: Price is < 50% of average
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(children: [
               Icon(Icons.warning_amber_rounded, color: Colors.orange), 
               SizedBox(width: 8), 
               Text('Low Price Warning')
            ]),
            content: Text(
              'Your quote of ₹$total is significantly lower than the average (₹${avg.toStringAsFixed(0)}) for this skill.\n\nAre you sure you want to proceed? Underpricing may lead to cancellations.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('EDIT PRICE')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('PROCEED ANYWAY')
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final response = await _quotationService.submitQuotation(
        jobId: job['_id'],
        laborCost: labor,
        materialCost: materials,
        estimatedDays: int.tryParse(_timelineController.text) ?? 1,
        notes: _noteController.text,
        tags: _selectedTags,
        videoPitch: _videoFile,
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
    // For timer calculation
    final job = widget.jobData ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: const PremiumAppBar(
        title: 'Submit Quotation',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                      hint: '0.00',
                      icon: Icons.handyman_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'Material Cost (₹)',
                      controller: _materialCostController,
                      hint: '0.00',
                      icon: Icons.inventory_2_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'Est. Timeline (Days)',
                      controller: _timelineController,
                      hint: '1',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    
                    // --- Tags Section ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price Justification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700])),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableTags.map((tag) {
                            final isSelected = _selectedTags.contains(tag);
                            return FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (_) => _toggleTag(tag),
                              backgroundColor: Colors.grey[100],
                              selectedColor: AppTheme.colors.primary.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? AppTheme.colors.primary : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12
                              ),
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppTheme.colors.primary : Colors.grey[300]!,
                                )
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    
                    _buildField(
                      label: 'Notes / Approach',
                      controller: _noteController,
                      hint: 'Briefly explain your work plan...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Video Pitch UI
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Video Pitch (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('Record a 30s video explaining your approach.', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        if (_videoFile != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 6),
                                const Text('Attached', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(() => _videoFile = null),
                                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                                )
                              ],
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: _pickVideo, 
                            icon: const Icon(Icons.videocam_outlined, size: 16),
                            label: const Text('Record'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                      ],
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
                    ? const SizedBox(width: 24, height: 24, child: PremiumLoader(size: 24, color: Colors.white))
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
