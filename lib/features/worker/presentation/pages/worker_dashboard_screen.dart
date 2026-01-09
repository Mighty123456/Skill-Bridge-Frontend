import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../widgets/available_job_card.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'worker_wallet_screen.dart';
import 'worker_performance_screen.dart';
import 'worker_notifications_screen.dart';


class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: PremiumAppBar(
        actions: [
          Row(
            children: [
              Switch(
                value: true,
                onChanged: (val) {},
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.green,
              ),
              const Text('Online ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerNotificationsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'WORKER DASHBOARD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerPerformanceScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.workspace_premium, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text('Gold Pro', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Earning Summary
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerWalletScreen()));
              },
              child: _buildEarningsCard(),
            ),
            const SizedBox(height: 24),

            // Performance Stats
            Row(
              children: [
                _buildStatCard('Rating', '4.9', Icons.star, Colors.amber),
                const SizedBox(width: 16),
                _buildStatCard('Jobs Done', '124', Icons.check_circle, Colors.green),
              ],
            ),
            const SizedBox(height: 24),

            // Available Jobs section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jobs Near You', style: Theme.of(context).textTheme.headlineMedium),
                TextButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const AvailableJobCard(
              title: 'Kitchen Sink Leakage',
              location: 'Sector 15, Gurgaon',
              distance: '2.5 km',
              urgency: 'Emergency',
              remainingTime: '2h 15m',
              estimatedPrice: '₹400 - ₹600',
              postedTime: '5m ago',
            ),
            const SizedBox(height: 16),
            const AvailableJobCard(
              title: 'Full House Wiring',
              location: 'DLF Phase 3, Gurgaon',
              distance: '4.1 km',
              urgency: 'Normal',
              remainingTime: '1d 4h',
              estimatedPrice: '₹2000 - ₹5000',
              postedTime: '20m ago',
            ),
            const SizedBox(height: 16),
            const AvailableJobCard(
              title: 'CCTV Installation',
              location: 'Sohna Road, Gurgaon',
              distance: '1.2 km',
              urgency: 'Normal',
              remainingTime: '5h 30m',
              estimatedPrice: '₹800 - ₹1200',
              postedTime: '1h ago',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Earnings', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Text('This Week', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('₹12,450.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildEarningSubItem('Pending', '₹1,200'),
              const SizedBox(width: 32),
              _buildEarningSubItem('Withdrawable', '₹4,500'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningSubItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
