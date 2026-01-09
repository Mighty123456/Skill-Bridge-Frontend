import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../widgets/status_timeline.dart';
import 'quotation_comparison_screen.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class JobDetailScreen extends StatelessWidget {
  static const String routeName = '/job-detail';
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PremiumAppBar(
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Page Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'JOB DETAILS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Status Timeline
            const StatusTimeline(currentStatus: 'Open'),
            const SizedBox(height: 32),

            // Job Title and Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kitchen Sink Leakage',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const Text('Plumbing • Posted 5m ago', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.jobCardSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: AppTheme.colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '02:54:12',
                        style: TextStyle(
                          color: AppTheme.colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Descriptions etc
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'The main pipe under the kitchen sink is leaking continuously. Need someone to fix it immediately. I have the basic tools but might need replacement washers.',
              style: TextStyle(color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.location_on_outlined, 'Location', '123, Maple Street, City'),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.inventory_2_outlined, 'Material Required', 'Yes'),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.bolt_outlined, 'Urgency', 'Normal'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Workers Applied Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quotations Received',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '3 New',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preview of first worker or generic CTA
            InkWell(
              onTap: () => Navigator.pushNamed(context, QuotationComparisonScreen.routeName),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    const Stack(
                      children: [
                        CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=1')),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 6,
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ramesh Kumar', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('₹450 • 200+ jobs completed', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, QuotationComparisonScreen.routeName),
                child: const Text('Compare All Quotations'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
