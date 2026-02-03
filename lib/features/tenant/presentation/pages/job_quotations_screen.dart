import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import 'package:skillbridge_mobile/features/tenant/data/quotation_service.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class JobQuotationsScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const JobQuotationsScreen({super.key, required this.jobData});

  @override
  State<JobQuotationsScreen> createState() => _JobQuotationsScreenState();
}

class _JobQuotationsScreenState extends State<JobQuotationsScreen> {
  final _quotationService = QuotationService();
  bool _isLoading = true;
  List<dynamic> _quotations = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuotations();
  }

  Future<void> _fetchQuotations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _quotationService.getQuotations(widget.jobData['_id']);
      if (response['success']) {
        setState(() {
          _quotations = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load quotations';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _acceptQuotation(String quotationId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Quotation?'),
        content: const Text('Once you accept this quotation, the worker will be assigned and other quotations will be rejected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.primary),
            child: const Text('ACCEPT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await _quotationService.acceptQuotation(quotationId);
      if (response['success']) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => CustomFeedbackPopup(
              title: 'Success!',
              message: 'Quotation accepted. The worker has been notified.',
              type: FeedbackType.success,
              onConfirm: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to previous screen with success flag
              },
            ),
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => CustomFeedbackPopup(
              title: 'Error',
              message: response['message'] ?? 'Failed to accept quotation.',
              type: FeedbackType.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => CustomFeedbackPopup(
            title: 'Error',
            message: 'An error occurred: $e',
            type: FeedbackType.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: PremiumAppBar(
        title: 'Quotations',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _fetchQuotations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: PremiumLoader())
          : _errorMessage != null
              ? _buildErrorState()
              : _quotations.isEmpty
                  ? _buildEmptyState()
                  : _buildQuotationsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchQuotations, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No quotations yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text('Wait for workers to submit their quotes.'),
        ],
      ),
    );
  }

  Widget _buildQuotationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quotations.length,
      itemBuilder: (context, index) {
        final quotation = _quotations[index];
        return _buildQuotationCard(quotation);
      },
    );
  }

  Widget _buildQuotationCard(Map<String, dynamic> quotation) {
    final worker = quotation['worker_id'] ?? {};
    final laborCost = quotation['labor_cost'] ?? 0;
    final materialCost = quotation['material_cost'] ?? 0;
    final totalCost = quotation['total_cost'] ?? 0;
    final days = quotation['estimated_days'] ?? 0;
    final notes = quotation['notes'] ?? 'No notes provided';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                      child: Text(
                        (worker['name'] ?? 'W')[0].toUpperCase(),
                        style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker['name'] ?? 'Worker Name',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text('4.8 (12 reviews)', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹$totalCost',
                      style: TextStyle(
                        color: AppTheme.colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('Labor', '₹$laborCost'),
                    _buildInfoColumn('Material', '₹$materialCost'),
                    _buildInfoColumn('Timeline', '$days Days'),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Tags Section
                if (quotation['tags'] != null && (quotation['tags'] as List).isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (quotation['tags'] as List).map<Widget>((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(fontSize: 11, color: AppTheme.colors.primary, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                const Text('Worker Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),

                // Video Pitch Section
                if (quotation['video_url'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.red.withValues(alpha: 0.1),
                             shape: BoxShape.circle
                           ),
                           child: const Icon(Icons.play_arrow_rounded, color: Colors.red),
                         ),
                         const SizedBox(width: 12),
                         const Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Video Pitch Attached', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                             Text('Tap to watch explanation', style: TextStyle(fontSize: 11, color: Colors.grey)),
                           ],
                         ),
                         const Spacer(),
                         TextButton(
                           onPressed: () {
                              // Launch video logic (e.g. url_launcher or video player dialog)
                              // For now, just show a snackbar
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playing video from: ${quotation['video_url']}')));
                           },
                           child: const Text('WATCH'),
                         )
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _acceptQuotation(quotation['_id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text('ACCEPT & HIRE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
