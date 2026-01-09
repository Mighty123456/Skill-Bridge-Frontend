import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

class WorkerPerformanceScreen extends StatelessWidget {
  static const String routeName = '/worker-performance';
  const WorkerPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Performance & Badges'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSummary(),
            const SizedBox(height: 24),
            _buildBadgeProgress(context),
            const SizedBox(height: 24),
            Text('Recent Feedback', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _buildFeedbackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Average Rating', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('4.9', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
              Text('/5', style: TextStyle(fontSize: 24, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => const Icon(Icons.star_rounded, color: Colors.amber, size: 32)),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat('124', 'Jobs Done'),
              _buildSimpleStat('98%', 'Completion'),
              _buildSimpleStat('45 mins', 'Avg Response'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildBadgeProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badge Progress', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildBadgeItem('Elite Worker', 0.8, '80/100 jobs'),
              const Divider(),
              _buildBadgeItem('Quick Responder', 0.4, '12/30 instant responses'),
              const Divider(),
              _buildBadgeItem('Five Star Pro', 0.95, '48/50 five-star reviews'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String name, double progress, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.workspace_premium, color: Colors.amber),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(detail, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFF5F5F5),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rajesh Kumar', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (i) => const Icon(Icons.star, size: 14, color: Colors.amber)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Excellent work! Professional and arrived on time.', style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 8),
                const Text('Kitchen Wiring - 12 Jan 2024', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }
}
