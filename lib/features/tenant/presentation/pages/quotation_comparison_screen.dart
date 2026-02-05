import 'package:flutter/material.dart';
import '../widgets/quotation_card.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'package:skillbridge_mobile/features/tenant/data/quotation_service.dart';
import 'package:skillbridge_mobile/features/tenant/data/tenant_job_service.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import '../../../chat/presentation/pages/chat_screen.dart';

class QuotationComparisonScreen extends StatefulWidget {
  static const String routeName = '/quotation-comparison';
  final Map<String, dynamic>? jobData;
  const QuotationComparisonScreen({super.key, this.jobData});

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
  void initState() {
    super.initState();
    _jobData = widget.jobData;
    if (_jobData != null) {
      _fetchQuotations();
    } else {
      _isLoading = false;
      _errorMessage = 'Job information missing';
    }
  }

  Future<void> _fetchQuotations() async {
    if (_jobData == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. If job data is thin (e.g. from notification), fetch full details
      if (_jobData!['job_title'] == null) {
        final jobResponse = await TenantJobService.getJobDetails(_jobData!['_id']);
        if (jobResponse['success']) {
          _jobData = jobResponse['data'];
        }
      }

      // 2. Fetch Quotations
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
          CustomFeedbackPopup.show(
            context,
            title: 'Success!',
            message: 'Quotation accepted. The worker has been notified.',
            type: FeedbackType.success,
            onConfirm: () {
              Navigator.pop(context, true); // Return with success
            },
          );
        }
      } else {
        if (mounted) {
          CustomFeedbackPopup.show(
            context,
            title: 'Error',
            message: response['message'] ?? 'Failed to accept quotation.',
            type: FeedbackType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomFeedbackPopup.show(
          context,
          title: 'Error',
          message: 'An error occurred: $e',
          type: FeedbackType.error,
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
          ? const Center(child: PremiumLoader())
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    if (_jobData != null && _jobData!['job_title'] != null)
                      _buildJobHeader(),
                    Expanded(
                      child: _quotations.isEmpty
                          ? _buildEmptyState()
                          : _buildQuotationsList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildJobHeader() {
    final photos = _jobData!['issue_photos'] as List? ?? [];
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
             _jobData!['job_title'] ?? 'Job Details',
             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
           ),
           const SizedBox(height: 8),
           Text(
             _jobData!['job_description'] ?? '',
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
             style: TextStyle(color: Colors.grey[600], fontSize: 13),
           ),
           if (photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photos[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
           ],
           const Divider(height: 24),
           const Text(
             'PROPOSALS RECEIVED',
             style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0),
           ),
        ],
      ),
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
        
        // Backend now sends these fields
        final rating = (q['worker_rating'] ?? 0).toDouble();
        final jobsCompleted = q['worker_jobs_completed'] ?? 0;
        final isVerified = q['worker_verified'] ?? false;

        return QuotationCard(
          workerName: worker['name'] ?? 'Unknown Worker',
          rating: rating > 0 ? rating : 5.0, // Default to 5.0 if new (or 0)
          jobsCompleted: jobsCompleted, 
          price: (q['total_cost'] ?? 0).toDouble(),
          estimatedTime: '${q['estimated_days']} Days',
          isTopRated: index == 0, // Mark first one as top rated (Cheapest + Best Rating)
          badges: isVerified ? ['Verified'] : [],
          imageUrl: worker['profileImage'] ?? 'https://i.pravatar.cc/150?u=${worker['_id']}',
          notes: q['notes'],
          onSelected: (_jobData != null && _jobData!['status'] == 'open') 
              ? () => _onAcceptQuotation(q['_id'])
              : null, // Disable selection if job is not open
          onChat: () {
            Navigator.pushNamed(
              context,
              ChatScreen.routeName,
              arguments: {
                'jobId': _jobData!['_id'],
                'recipientName': worker['name'] ?? 'Worker',
                'recipientId': worker['_id'],
              },
            );
          },
        );
      },
    );
  }
}
