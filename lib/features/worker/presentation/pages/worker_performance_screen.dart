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
        title: const Text('Performance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
              Text('4.9', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('/5', style: TextStyle(fontSize: 20, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => const Icon(Icons.star_rounded, color: Colors.amber, size: 36)),
          ),
          const SizedBox(height: 24),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: Colors.white.withValues(alpha: 0.1),
               borderRadius: BorderRadius.circular(30)
             ),
             child: const Text('Top Rated Worker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('124', 'Jobs Done', Icons.check_circle_outline, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('98%', 'Completion', Icons.task_alt, Colors.blue)),
        const SizedBox(width: 16),
         Expanded(child: _buildStatItem('45m', 'Res. Time', Icons.timer_outlined, Colors.orange)),
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
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
           _buildBadgeCard('Elite Pro', 'Completed 100+ Jobs', Colors.amber, 0.8),
           const SizedBox(width: 16),
           _buildBadgeCard('Swift', 'Fast Response Time', Colors.purple, 0.6),
            const SizedBox(width: 16),
           _buildBadgeCard('Verified', 'Identity Verified', Colors.blue, 1.0),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(String title, String subtitle, Color color, double progress) {
     return Container(
       width: 140,
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
         boxShadow: [
           BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
         ]
       ),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: color.withValues(alpha: 0.1),
               shape: BoxShape.circle,
             ),
             child: Icon(Icons.workspace_premium, color: color, size: 24),
           ),
           const SizedBox(height: 12),
           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
           const SizedBox(height: 4),
           Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center, maxLines: 2),
           const SizedBox(height: 12),
           LinearProgressIndicator(value: progress, backgroundColor: color.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation(color), borderRadius: BorderRadius.circular(2)),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                     radius: 16,
                     backgroundColor: Colors.grey[200],
                     child: const Icon(Icons.person, size: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rajesh Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Kitchen Wiring', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) => const Icon(Icons.star, size: 14, color: Colors.amber)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Excellent work! Professional and arrived exactly on time. Fixed the issue quickly.',
                style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text('12 Jan 2024', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}
