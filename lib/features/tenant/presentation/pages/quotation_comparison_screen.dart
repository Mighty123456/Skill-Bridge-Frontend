import 'package:flutter/material.dart';
import '../widgets/quotation_card.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class QuotationComparisonScreen extends StatelessWidget {
  static const String routeName = '/quotation-comparison';
  const QuotationComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PremiumAppBar(showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Professional Page Header
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'COMPARE QUOTATIONS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const QuotationCard(
            workerName: 'Ramesh Kumar',
            rating: 4.8,
            jobsCompleted: 245,
            price: 450,
            estimatedTime: '30 mins',
            isTopRated: true,
            badges: ['Verified', 'Expert'],
            imageUrl: 'https://i.pravatar.cc/150?u=ramesh',
          ),
          SizedBox(height: 16),
          QuotationCard(
            workerName: 'Suresh Patil',
            rating: 4.5,
            jobsCompleted: 120,
            price: 500,
            estimatedTime: '45 mins',
            isTopRated: false,
            badges: ['Verified'],
            imageUrl: 'https://i.pravatar.cc/150?u=suresh',
          ),
          SizedBox(height: 16),
          QuotationCard(
            workerName: 'Amit Singh',
            rating: 4.2,
            jobsCompleted: 85,
            price: 400,
            estimatedTime: '1 hour',
            isTopRated: false,
            badges: [],
            imageUrl: 'https://i.pravatar.cc/150?u=amit',
          ),
        ],
      ),
    );
  }
}
