import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../widgets/skill_category_card.dart';
import '../widgets/worker_preview_card.dart';
import '../widgets/emergency_banner.dart';
import '../widgets/active_job_summary_card.dart';
import 'post_job_screen.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class TenantHomeScreen extends StatelessWidget {
  const TenantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PremiumAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                        'Hello, User!',
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
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user123'),
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
            _buildSectionHeader(context, 'Active Jobs', onSeeAll: () {}),
            const SizedBox(height: 16),
            const ActiveJobSummaryCard(),
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

            // Section: Verified Workers
            _buildSectionHeader(context, 'Verified Nearby', onSeeAll: () {}),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: const [
                  WorkerPreviewCard(
                    name: 'John Doe',
                    skill: 'Electrician',
                    rating: 4.8,
                    imageUrl: 'https://i.pravatar.cc/150?u=worker1',
                  ),
                  WorkerPreviewCard(
                    name: 'Jane Smith',
                    skill: 'Plumber',
                    rating: 4.9,
                    imageUrl: 'https://i.pravatar.cc/150?u=worker2',
                  ),
                  WorkerPreviewCard(
                    name: 'Mike Ross',
                    skill: 'Carpenter',
                    rating: 4.7,
                    imageUrl: 'https://i.pravatar.cc/150?u=worker3',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
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
