import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import '../../../../widgets/premium_app_bar.dart';
import '../../data/worker_dashboard_service.dart';

class ActiveJobsScreen extends StatefulWidget {
  static const String routeName = '/worker-jobs';
  const ActiveJobsScreen({super.key});

  @override
  State<ActiveJobsScreen> createState() => _ActiveJobsScreenState();
}

class _ActiveJobsScreenState extends State<ActiveJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: const PremiumAppBar(title: 'My Jobs'),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: _buildTabSelector(),
            ),
            const Expanded(
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  JobList(status: 'active'),
                  JobList(status: 'completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppTheme.colors.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colors.primary.withValues(alpha: 0.2), // Reduced opacity
              blurRadius: 4, // Reduced blur
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.work_history_rounded, size: 16), SizedBox(width: 8), Text('ACTIVE')])),
          Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_rounded, size: 16), SizedBox(width: 8), Text('COMPLETED')])),
        ],
      ),
    );
  }
}

class JobList extends StatefulWidget {
  final String status;
  const JobList({super.key, required this.status});

  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  bool _isLoading = true;
  List<dynamic> _jobs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await WorkerDashboardService.getMyJobs(status: widget.status);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _jobs = result['data'];
      } else {
        _error = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: PremiumLoader(
          color: AppTheme.colors.primary,
          size: 40,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Something went wrong', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchJobs,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Opacity(
               opacity: 0.7,
               child: Image.network(
                 'https://cdn-icons-png.flaticon.com/512/7486/7486777.png', // Placeholder or use asset
                 width: 150,
                 errorBuilder: (c,e,s) => Icon(Icons.assignment_ind_outlined, size: 100, color: Colors.grey[300]),
               ),
             ),
            const SizedBox(height: 24),
            Text(
              widget.status == 'active' ? 'No Active Jobs' : 'No History Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
             const SizedBox(height: 8),
            Text(
              widget.status == 'active' 
                ? 'Your accepted jobs will be listed here.'
                : 'Jobs you complete will appear here.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
             if (widget.status == 'active') ...[
               const SizedBox(height: 24),
               ElevatedButton(
                 onPressed: () {
                   // Go back to dashboard/feed to find jobs
                   Navigator.pop(context);
                 },
                 child: const Text('Find Jobs'),
               ),
             ]
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchJobs,
      color: AppTheme.colors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _jobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final job = _jobs[index];
          if (widget.status == 'active') {
            return _buildActiveJobCard(job);
          } else {
            return _buildCompletedJobCard(job);
          }
        },
      ),
    );
  }

  Widget _buildActiveJobCard(dynamic job) {
    final String status = job['status'] ?? 'active';
    final String title = job['job_title'] ?? 'Untitled Job';
    
    // Status Color Coding
    Color statusColor = Colors.blue;
    Color statusBg = Colors.blue.withValues(alpha: 0.1);
    
    if (status == 'in_progress') {
       statusColor = Colors.orange;
       statusBg = Colors.orange.withValues(alpha: 0.1);
    } else if (status == 'assigned') {
       statusColor = AppTheme.colors.primary;
       statusBg = AppTheme.colors.primary.withValues(alpha: 0.1);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), // Reduced opacity
            blurRadius: 8, // Reduced blur
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
             Navigator.pushNamed(context, '/worker-job-detail', arguments: job['_id']);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        status.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForTitle(title),
                        color: AppTheme.colors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  job['location']?['address_text'] ?? 'Location not available',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                        const Text('Scheduled Date', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.black87),
                            const SizedBox(width: 6),
                            Text(_formatDate(job['updated_at']), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                       ],
                     ),
                     ElevatedButton(
                       onPressed: () {
                          Navigator.pushNamed(context, '/worker-job-detail', arguments: job['_id']);
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppTheme.colors.primary,
                         foregroundColor: Colors.white,
                         elevation: 0,
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                       child: const Text('Manage Job'),
                     ),
                   ],
                 )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedJobCard(dynamic job) {
    final title = job['job_title'] ?? 'Untitled';
    final completedDate = _formatDate(job['updated_at']);
    final rating = 4.8; // Use static or fetch if available

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
             Container(
               width: 50,
               height: 50,
               decoration: BoxDecoration(
                 color: Colors.green.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                   const SizedBox(height: 4),
                   Text('Completed on $completedDate', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                   const SizedBox(height: 6),
                   Row(
                     children: [
                       const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                       const SizedBox(width: 4),
                       Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                     ],
                   )
                 ],
               ),
             ),
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: Colors.grey[100],
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Icon(Icons.receipt_long_rounded, color: Colors.grey, size: 20),
             )
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('plumb')) return Icons.plumbing_rounded;
    if (t.contains('electr')) return Icons.electric_bolt_rounded;
    if (t.contains('clean')) return Icons.cleaning_services_rounded;
    if (t.contains('paint')) return Icons.format_paint_rounded;
    if (t.contains('ac') || t.contains('cool')) return Icons.ac_unit_rounded;
    return Icons.handyman_rounded;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

