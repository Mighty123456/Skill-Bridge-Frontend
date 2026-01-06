import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Verified Skill Identity',
      description:
          'Build your professional identity. Get verified, earn badges, and showcase your work history to get hired.',
      icon: Icons.verified_user_outlined,
      color: AppTheme.colors.primary,
    ),
    OnboardingContent(
      title: 'Local Work Marketplace',
      description:
          'Find skilled experts nearby or discover local job opportunities instantly with our location-based search.',
      icon: Icons.map_outlined,
      color: AppTheme.colors.secondary,
    ),
    OnboardingContent(
      title: 'Secure & Fair',
      description:
          'Experience transparent pricing, secure escrow payments, and a trusted rating system for peace of mind.',
      icon: Icons.security_outlined,
      color: AppTheme.colors.primaryDark,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, RoleSelectionScreen.routeName);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, RoleSelectionScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppTheme.colors.onSurface.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(content: _contents[index]);
                },
              ),
            ),

            // Bottom Flow
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _contents[_currentPage].color
                              : AppTheme.colors.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next Button
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _contents[_currentPage].color,
                      foregroundColor: AppTheme.colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      elevation: 4,
                      shadowColor: _contents[_currentPage].color.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      _currentPage == _contents.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const _OnboardingPage({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: content.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              content.icon,
              size: 100,
              color: content.color,
            ),
          ),
          const SizedBox(height: 64),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
