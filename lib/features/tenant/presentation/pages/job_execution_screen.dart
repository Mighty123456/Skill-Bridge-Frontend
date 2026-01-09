import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../widgets/status_timeline.dart';

class JobExecutionScreen extends StatelessWidget {
  static const String routeName = '/job-execution';
  const JobExecutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job in Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const StatusTimeline(currentStatus: 'In Progress'),
            const SizedBox(height: 32),

            // Worker Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=ramesh')),
                  const SizedBox(height: 12),
                  const Text('Ramesh Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Plumbing Specialist', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.call, 'Call', Colors.green, () {}),
                      _buildActionButton(Icons.chat_bubble, 'Chat', AppTheme.colors.primary, () {}),
                      _buildActionButton(Icons.location_on, 'Track', Colors.orange, () {}),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress Section
            _buildSectionTitle('Work Progress Updates'),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProgressImage('https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=300'),
                  _buildProgressImage('https://images.unsplash.com/photo-1504148406432-155e4e6900f0?w=300'),
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Checklist or Step updates
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildCheckItem('Arrived at location', true),
                  _buildCheckItem('Problem inspected', true),
                  _buildCheckItem('Fixing leakage', true),
                  _buildCheckItem('Testing & Cleaning', false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Completion Notification placeholder
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.colors.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Worker has marked the job as completed.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/payment'),
                    child: const Text('Review & Pay'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProgressImage(String url) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, color: completed ? Colors.green : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: completed ? Colors.black : Colors.grey, decoration: completed ? TextDecoration.lineThrough : null)),
        ],
      ),
    );
  }
}
