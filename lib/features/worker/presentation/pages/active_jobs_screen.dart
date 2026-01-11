import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
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
        backgroundColor: AppTheme.colors.background,
        appBar: const PremiumAppBar(title: 'My Jobs'),
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildTabSelector(),
            const SizedBox(height: 16),
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
          Tab(text: 'COMPLETED'),
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
        child: CircularProgressIndicator(
          color: AppTheme.colors.primary,
          strokeWidth: 3,
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
                   : Icons.task_alt_rounded, 
                 size: 48, 
                 color: Colors.grey[400]
               ),
             ),
            const SizedBox(height: 24),
            Text(
              widget.status == 'active' ? 'No active jobs' : 'No completed jobs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
             const SizedBox(height: 8),
            Text(
              widget.status == 'active' 
                ? 'Accepted jobs will appear here'
                : 'Completed jobs history',
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
             Navigator.pushNamed(context, '/worker-job-detail', arguments: job['_id']);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase().replaceAll('_', ' '),
                        style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text('Quote Sent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForTitle(title),
                        color: AppTheme.colors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        job['location']?['address_text'] ?? 'Unknown Location',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                 const SizedBox(height: 16),
                 SizedBox(
                   width: double.infinity,
                   child: OutlinedButton(
                     onPressed: () {
                        Navigator.pushNamed(context, '/worker-job-detail', arguments: job['_id']);
                     },
                     style: OutlinedButton.styleFrom(
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                       side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.5)),
                     ),
                     child: Text('View Details', style: TextStyle(color: AppTheme.colors.primary)),
                   ),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
           padding: const EdgeInsets.all(10),
           decoration: BoxDecoration(
             color: Colors.green.withValues(alpha: 0.1),
             shape: BoxShape.circle,
           ),
           child: const Icon(Icons.check, color: Colors.green, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed on ${_formatDate(job['updated_at'])}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                 children: const [
                   Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                   Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                   Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                   Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                   Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                 ],
              ),
            ],
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}

