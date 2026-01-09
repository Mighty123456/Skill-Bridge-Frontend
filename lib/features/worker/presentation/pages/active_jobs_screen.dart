import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

class ActiveJobsScreen extends StatelessWidget {
  static const String routeName = '/worker-jobs';
  const ActiveJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: AppBar(
          title: const Text('My Jobs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          children: [
            _ActiveJobsList(),
            _CompletedJobsList(),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobsList extends StatelessWidget {
  const _ActiveJobsList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'IN PROGRESS',
                        style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text('₹1,200', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Full House Electrical Wiring',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Sector 62, Noida', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 16),
                const LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progress', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('60%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Update'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Complete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompletedJobsList extends StatelessWidget {
  const _CompletedJobsList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: const Text('Kitchen Sink Repair', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text('Completed on 10 Oct 2023'),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < 4 ? Colors.amber : Colors.grey)),
                ),
              ],
            ),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹450', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
