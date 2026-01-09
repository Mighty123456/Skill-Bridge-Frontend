import 'package:flutter/material.dart';
import '../widgets/quotation_card.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'package:skillbridge_mobile/features/tenant/data/quotation_service.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';

class QuotationComparisonScreen extends StatefulWidget {
  static const String routeName = '/quotation-comparison';
  const QuotationComparisonScreen({super.key});

  @override
  State<QuotationComparisonScreen> createState() => _QuotationComparisonScreenState();
}

class _QuotationComparisonScreenState extends State<QuotationComparisonScreen> {
  final _quotationService = QuotationService();
  bool _isLoading = true;
  List<dynamic> _quotations = [];
  String? _errorMessage;
  Map<String, dynamic>? _jobData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_jobData == null) {
      _jobData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (_jobData != null) {
        _fetchQuotations();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Job information missing';
        });
      }
    }
  }

  Future<void> _fetchQuotations() async {
    if (_jobData == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _quotationService.getQuotations(_jobData!['_id']);
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

  void _onAcceptQuotation(String quotationId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Quotation?'),
        content: const Text('Hire this worker and start the job? Other quotations will be automatically rejected.'),
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
                Navigator.pop(context, true); // Return with success
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
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQuotations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _quotations.isEmpty
                  ? _buildEmptyState()
                  : _buildQuotationsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _fetchQuotations, child: const Text('Try Again')),
          ],
        ),
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
          const Text('Wait for workers to submit their quotes.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuotationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quotations.length,
      itemBuilder: (context, index) {
        final q = _quotations[index];
        final worker = q['worker_id'] ?? {};
        
        return QuotationCard(
          workerName: worker['name'] ?? 'Unknown Worker',
          rating: 4.8, // Should be from worker stats
          jobsCompleted: 12, // Should be from worker stats
          price: (q['total_cost'] ?? 0).toDouble(),
          estimatedTime: '${q['estimated_days']} Days',
          isTopRated: index == 0, // Mark first one as top rated (e.g. cheapest)
          badges: ['Verified'],
          imageUrl: 'https://i.pravatar.cc/150?u=${worker['_id']}',
          notes: q['notes'],
          onSelected: () => _onAcceptQuotation(q['_id']),
        );
      },
    );
  }
}
