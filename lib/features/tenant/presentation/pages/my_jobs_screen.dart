import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'package:skillbridge_mobile/features/tenant/data/tenant_job_service.dart';
import 'job_detail_screen.dart';
import 'job_execution_screen.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: const PremiumAppBar(title: 'My Jobs'),
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildTabSelector(),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _JobsList(status: 'active'), // In Progress / Assigned
                  _JobsList(status: 'pending'), // Open
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppTheme.colors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'ACTIVE'),
          Tab(text: 'PENDING'),
        ],
      ),
    );
  }
}

class _JobsList extends StatefulWidget {
  final String status;
  const _JobsList({required this.status});

  @override
  State<_JobsList> createState() => _JobsListState();
}

class _JobsListState extends State<_JobsList> {
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

    final result = await TenantJobService.getPostedJobs(status: widget.status);

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
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: _fetchJobs,
              child: const Text('Try Again'),
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
             Container(
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white,
                 shape: BoxShape.circle,
                 boxShadow: [
                   BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
                 ]
               ),
               child: Icon(
                 widget.status == 'active' 
                   ? Icons.work_off_rounded 
                   : Icons.pending_actions_rounded, 
                 size: 48, 
                 color: Colors.grey[400]
               ),
             ),
            const SizedBox(height: 24),
            Text(
              widget.status == 'active' ? 'No active jobs' : 'No pending jobs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
             const SizedBox(height: 8),
            Text(
              widget.status == 'active' 
                ? 'Jobs in progress will show here'
                : 'Post a job to get started',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchJobs,
      color: AppTheme.colors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _jobs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildJobCard(_jobs[index]),
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    final bool isPending = widget.status == 'pending';
    final String status = job['status'] ?? 'OPEN';
    final String title = job['job_title'] ?? 'Untitled';
    final String timeAgo = _formatTimeAgo(job['created_at']);
    
    // Status color mapping
    Color statusColor;
    if (status == 'open') {
      statusColor = Colors.orange;
    } else if (status == 'in_progress') {
      statusColor = Colors.blue;
    } else if (status == 'assigned') {
      statusColor = Colors.purple;
    } else if (status == 'completed') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (status == 'assigned' || status == 'in_progress' || status == 'reviewing') {
              Navigator.pushNamed(
                context,
                JobExecutionScreen.routeName,
                arguments: job,
              );
            } else {
              Navigator.pushNamed(
                context,
                JobDetailScreen.routeName,
                arguments: {'jobData': job},
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status.toUpperCase().replaceAll('_', ' '),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                 const SizedBox(height: 20),
                 Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                 const SizedBox(height: 12),
                 Row(
                   children: [
                     Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                     const SizedBox(width: 6),
                     Text(
                       'Posted $timeAgo',
                       style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                     ),
                     const Spacer(),
                     if (isPending)
                        Text(
                          'Waiting for quotes',
                          style: TextStyle(color: AppTheme.colors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                     if (!isPending && job['selected_worker_id'] != null)
                        Row(
                          children: [
                             CircleAvatar(
                               radius: 10,
                               backgroundColor: Colors.grey[200],
                               child: const Icon(Icons.person, size: 12, color: Colors.grey),
                             ),
                             const SizedBox(width: 6),
                             Text(
                               'Worker Assigned',
                               style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w600),
                             ),
                          ],
                        )
                   ],
                  ),
                  if (status == 'open') ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/quotation-comparison',
                            arguments: job,
                          );
                          if (result == true) {
                            _fetchJobs();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.colors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('View Quotations', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

