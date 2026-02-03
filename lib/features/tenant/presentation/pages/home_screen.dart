import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_loader.dart';
import '../widgets/skill_category_card.dart';
import '../widgets/emergency_banner.dart';
import '../widgets/active_job_summary_card.dart';
import 'post_job_screen.dart';
import 'tenant_notifications_screen.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

import '../../data/tenant_job_service.dart';
import '../../../auth/data/auth_service.dart';

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  List<dynamic> _activeJobs = [];
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final results = await Future.wait([
      _authService.getMe(),
      TenantJobService.getPostedJobs(status: 'active'),
    ]);

    if (mounted) {
      setState(() {
        if (results[0]['success']) {
          _user = results[0]['data']['user'];
        }
        if (results[1]['success']) {
          _activeJobs = results[1]['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PremiumAppBar(
        onNotificationTap: () => Navigator.pushNamed(context, TenantNotificationsScreen.routeName),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.colors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Identity 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'HOME DASHBOARD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.colors.primary.withValues(alpha: 0.8),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personalized Welcome Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${_user?['name']?.split(' ')[0] ?? 'User'}!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.colors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What do you need help with today?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.colors.primary.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                      backgroundImage: _user?['profileImage'] != null 
                        ? NetworkImage(_user!['profileImage']) 
                        : null,
                      child: _user?['profileImage'] == null 
                        ? Text(_user?['name']?[0] ?? 'U', style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold, fontSize: 20))
                        : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Immersive Features Section
              const EmergencyBanner(),
              const SizedBox(height: 24),
              _buildPostJobCTA(context),
              const SizedBox(height: 40),

              // Section: Active Jobs
              _buildSectionHeader(context, 'Your Active Postings', onSeeAll: () {}),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: PremiumLoader(),
                ))
              else if (_activeJobs.isEmpty)
                _buildEmptyJobsState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activeJobs.length > 3 ? 3 : _activeJobs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => ActiveJobSummaryCard(jobData: _activeJobs[index]),
                ),
              const SizedBox(height: 40),

              // Section: Categories
              _buildSectionHeader(context, 'Explore Services', onSeeAll: () {}),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: const [
                  SkillCategoryCard(icon: Icons.plumbing_rounded, label: 'Plumbing'),
                  SkillCategoryCard(icon: Icons.electric_bolt_rounded, label: 'Electric'),
                  SkillCategoryCard(icon: Icons.cleaning_services_rounded, label: 'Cleaning'),
                  SkillCategoryCard(icon: Icons.format_paint_rounded, label: 'Painting'),
                  SkillCategoryCard(icon: Icons.carpenter_rounded, label: 'Carpentry'),
                  SkillCategoryCard(icon: Icons.moped_rounded, label: 'Delivery'),
                  SkillCategoryCard(icon: Icons.yard_rounded, label: 'Gardening'),
                  SkillCategoryCard(icon: Icons.more_horiz_rounded, label: 'Others'),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyJobsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No active jobs yet',
            style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Post a job to get professional help',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.2,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.colors.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            child: const Text('See all'),
          ),
      ],
    );
  }

  Widget _buildPostJobCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.colors.primary, AppTheme.colors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, PostJobScreen.routeName),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.add_task_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post a New Job',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Get instant quotations from pros',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
