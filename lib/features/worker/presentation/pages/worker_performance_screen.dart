import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class WorkerPerformanceScreen extends StatelessWidget {
  static const String routeName = '/worker-performance';
  const WorkerPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: const PremiumAppBar(
        title: 'Performance',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRatingCard(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
             const SizedBox(height: 24),
            Row(
              children: [
                 const Icon(Icons.workspace_premium_rounded, color: Colors.amber),
                 const SizedBox(width: 8),
                 Text('Your Badges', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildBadgeList(),
            const SizedBox(height: 24),
             Row(
              children: [
                 const Icon(Icons.forum_outlined, color: Colors.blueGrey),
                 const SizedBox(width: 8),
                 Text('Recent Reviews', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildFeedbackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ]
      ),
      child: Column(
        children: [
          const Text('Overall Rating', style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1)),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('0.0', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('/5', style: TextStyle(fontSize: 20, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => const Icon(Icons.star_rounded, color: Colors.white24, size: 36)),
          ),
          const SizedBox(height: 24),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: Colors.white.withValues(alpha: 0.1),
               borderRadius: BorderRadius.circular(30)
             ),
             child: const Text('New Worker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
         Expanded(child: _buildStatItem('0', 'Jobs Done', Icons.check_circle_outline, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('N/A', 'Completion', Icons.task_alt, Colors.grey)),
        const SizedBox(width: 16),
         Expanded(child: _buildStatItem('N/A', 'Res. Time', Icons.timer_outlined, Colors.grey)),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        children: [
           Icon(icon, color: color, size: 28),
           const SizedBox(height: 12),
           Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
           const SizedBox(height: 4),
           Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBadgeList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.workspace_premium_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Complete jobs to earn badges',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No reviews yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
