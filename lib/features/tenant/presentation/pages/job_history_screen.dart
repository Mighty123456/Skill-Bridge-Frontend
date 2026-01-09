import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import 'package:skillbridge_mobile/widgets/premium_app_bar.dart';

class JobHistoryScreen extends StatelessWidget {
  const JobHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: const PremiumAppBar(title: 'Job History'),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: 8,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader();
          }
          return _buildHistoryCard(context, index - 1);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'TRANSACTIONS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.colors.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Job History',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review your past requests and settlements',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, int index) {
    final bool isCompleted = index % 3 != 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      index % 2 == 0 ? Icons.electric_bolt_rounded : Icons.plumbing_rounded, 
                      color: AppTheme.colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              index % 2 == 0 ? 'AC Servicing' : 'Kitchen Pipe Repair',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            Text(
                              '₹${450 + (index * 50)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 16,
                                color: AppTheme.colors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Requested on 1$index Jan, 2026',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusBadge(isCompleted ? 'Completed' : 'Cancelled'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFF9FAFB),
              child: Row(
                children: [
                  _buildActionIcon(Icons.description_outlined, 'Invoice'),
                  const SizedBox(width: 16),
                  _buildActionIcon(Icons.star_outline_rounded, 'Review'),
                  const Spacer(),
                  if (isCompleted) ...[
                    const Icon(Icons.verified_rounded, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text(
                      'Paid via Wallet',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isComp = status == 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isComp ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isComp ? Colors.green : Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w600, 
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
