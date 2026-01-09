import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: const PremiumAppBar(title: 'My Jobs'),
        body: Column(
          children: [
            const SizedBox(height: 8),
            // Premium Tab Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECF0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppTheme.colors.primary,
                unselectedLabelColor: Colors.grey[500],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'ACTIVE'),
                  Tab(text: 'PENDING'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildActiveJobsList(),
                  _buildPendingJobsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJobsList() {
    final jobs = [
      {
        'title': 'Kitchen Sink Repair',
        'status': 'In Progress',
        'worker': 'Rajesh Kumar',
        'price': '₹450',
        'time': 'Started 2h ago',
        'icon': Icons.plumbing_rounded,
        'statusColor': Colors.green,
      },
      {
        'title': 'Ceiling Fan Installation',
        'status': 'Worker En Route',
        'worker': 'Amit Sharma',
        'price': '₹300',
        'time': 'Arriving at 3:00 PM',
        'icon': Icons.electric_bolt_rounded,
        'statusColor': Colors.blue,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _buildJobCard(jobs[index]),
    );
  }

  Widget _buildPendingJobsList() {
    final jobs = [
      {
        'title': 'House Painting',
        'status': '5 Quotes Received',
        'worker': 'Review & Select',
        'price': 'Bidding',
        'time': 'Posted 3h ago',
        'icon': Icons.format_paint_rounded,
        'statusColor': Colors.orange,
      },
      {
        'title': 'AC Servicing',
        'status': '2 Quotes Received',
        'worker': 'Review & Select',
        'price': 'Bidding',
        'time': 'Posted 5h ago',
        'icon': Icons.ac_unit_rounded,
        'statusColor': Colors.orange,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _buildJobCard(jobs[index]),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        job['icon'],
                        color: AppTheme.colors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Job Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title'],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (job['statusColor'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: job['statusColor'],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  job['status'].toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: job['statusColor'],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          job['price'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: job['price'] == 'Bidding' 
                                ? Colors.grey[400] 
                                : AppTheme.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    job['worker'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  job['time'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
