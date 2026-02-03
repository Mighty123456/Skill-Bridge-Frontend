import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../widgets/available_job_card.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';
import 'package:skillbridge_mobile/widgets/custom_feedback_popup.dart';
import 'worker_wallet_screen.dart';
import 'worker_performance_screen.dart';
import 'worker_notifications_screen.dart';
import '../../data/worker_dashboard_service.dart';
import '../../../auth/data/auth_service.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import 'worker_passport_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _jobs = [];
  List<dynamic> _filteredJobs = [];
  String? _error;
  Timer? _refreshTimer;
  String _filterType = 'All'; // 'All', 'Urgent', 'New'
  String _userName = 'Worker';
  
  // Animation controller for filter chips
  late AnimationController _animationController;

  bool _isOnline = true; // Default to online

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 300)
    );
    _loadUserProfile();
    _fetchJobs();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isOnline) {
        _fetchJobs(isBackground: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await AuthService().getMe();
      if (user['success'] == true && mounted) {
        setState(() {
          _userName = user['data']['name'] ?? 'Worker';
           // Check for isOnline or availabilityStatus field from backend
           // If backend uses 'isOnline' (which we just added), use that.
          if (user['data'].containsKey('isOnline')) {
             _isOnline = user['data']['isOnline'];
          }
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _fetchJobs({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final result = await WorkerDashboardService.getWorkerFeed();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _jobs = result['data'];
        _applyFilter();
      } else {
        if (!isBackground) _error = result['message'];
      }
    });
  }

  void _applyFilter() {
    if (_filterType == 'All') {
      _filteredJobs = List.from(_jobs);
    } else if (_filterType == 'Urgent') {
      _filteredJobs = _jobs.where((job) => (job['urgency_level'] ?? '').toLowerCase() == 'emergency').toList();
    } else if (_filterType == 'New') {
       // Mock logic for 'New' - last 24 hours
       final now = DateTime.now();
       _filteredJobs = _jobs.where((job) {
          final created = DateTime.tryParse(job['created_at'] ?? '');
          return created != null && now.difference(created).inHours < 24;
       }).toList();
    }
  }

  void _onFilterChanged(String newFilter) {
    setState(() {
      _filterType = newFilter;
      _applyFilter();
    });
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    // Optimistic update
    setState(() {
      _isOnline = value;
    });
    
    final result = await WorkerDashboardService.updateAvailability(value);
    
    if (!mounted) return;

    if (result['success']) {
      CustomFeedbackPopup.show(
        context,
        title: value ? 'You are Online' : 'You are Offline',
        message: value 
            ? 'You are now ONLINE. You will receive job notifications.' 
            : 'You are now OFFLINE. You won\'t receive new jobs.',
        type: value ? FeedbackType.success : FeedbackType.info,
      );
    } else {
      // Revert if failed
      setState(() {
        _isOnline = !value;
      });
      CustomFeedbackPopup.show(
        context,
        title: 'Status Update Failed',
        message: result['message'] ?? "Unknown error",
        type: FeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: PremiumAppBar(
        onNotificationTap: () {
          Navigator.pushNamed(context, WorkerNotificationsScreen.routeName);
        },
        onChatTap: () {
           Navigator.pushNamed(context, '/chat-list');
        },
        forceShowDefaultActions: true, // Ensure Chat & Notifications are shown
        actions: [
          Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               Text(
                 _isOnline ? 'Active' : 'Offline',
                 style: TextStyle(
                   fontSize: 13, 
                   fontWeight: FontWeight.bold, 
                   color: _isOnline ? const Color(0xFF059669) : Colors.grey[600]
                 ),
               ),
               const SizedBox(width: 8),
               Transform.scale(
                 scale: 0.8,
                 child: Switch(
                   value: _isOnline,
                   onChanged: _toggleOnlineStatus,
                   activeThumbColor: const Color(0xFF10B981),
                   activeTrackColor: const Color(0xFFD1FAE5),
                   inactiveThumbColor: Colors.grey[400],
                   inactiveTrackColor: Colors.grey[200],
                 ),
               ),
               const SizedBox(width: 4),
             ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchJobs(),
        color: AppTheme.colors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Afternoon,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerPerformanceScreen()));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star_outline_rounded, color: Colors.black54, size: 16),
                                SizedBox(width: 4),
                                Text('Performance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Main Stats Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerWalletScreen()));
                      },
                      child: _buildEarningsCard(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Secondary Stats Row
                    Row(
                      children: [
                        _buildStatCard(
                          'Rating', 
                          '0.0', 
                          Icons.star_rounded, 
                          AppTheme.colors.secondary,
                          AppTheme.colors.secondary.withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          'Jobs Done', 
                          '0', 
                          Icons.check_circle_rounded, 
                          AppTheme.colors.primary,
                          AppTheme.colors.primary.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // Skill Passport Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerPassportScreen()));
                      },
                      child: _buildPassportCard(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Jobs Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Jobs', 
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Colors.black87
                          )
                        ),
                        InkWell(
                          onTap: _fetchJobs,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.refresh_rounded, size: 22, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', _filterType == 'All'),
                          const SizedBox(width: 12),
                          _buildFilterChip('Urgent', _filterType == 'Urgent'),
                          const SizedBox(width: 12),
                          _buildFilterChip('New', _filterType == 'New'),
                          const SizedBox(width: 12),
                          // Placeholder for more filters like 'Distance'
                          _buildFilterChip('Nearby', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Job List
            if (_isLoading && _jobs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: PremiumLoader()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Connection Issue',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 8),
                       Text(
                        _error!, 
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _fetchJobs(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.colors.primary,
                          foregroundColor: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              )
            else if (_filteredJobs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                 child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
                            ]
                          ),
                          child: Icon(Icons.work_off_rounded, size: 48, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No jobs found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing filters or checking back later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final job = _filteredJobs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: AvailableJobCard(jobData: job),
                    );
                  },
                  childCount: _filteredJobs.length,
                ),
              ),
              
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _onFilterChanged(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.colors.primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppTheme.colors.primary : Colors.grey.shade300,
          ),
          boxShadow: isSelected 
             ? [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] 
             : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.2), // Reduced opacity
            blurRadius: 8, // Reduced blur
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance', 
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2), 
                  borderRadius: BorderRadius.circular(20)
                ),
                child: const Row(
                  children: [
                    Text('This Week', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '₹0.00', 
            style: TextStyle(
              color: Colors.white, 
              fontSize: 34, 
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            )
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildEarningSubItem('Pending', '₹0.00', Icons.pending_outlined)),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(child: _buildEarningSubItem('Withdrawable', '₹0.00', Icons.account_balance_wallet_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningSubItem(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildPassportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors.secondary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.secondary.withValues(alpha: 0.2), // Reduced opacity
            blurRadius: 8, // Reduced blur
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Skill Passport',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'View your badge & skill stats',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)
                ),
                Text(
                  label, 
                  style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
