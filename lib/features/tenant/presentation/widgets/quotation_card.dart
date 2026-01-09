import 'package:flutter/material.dart';
import 'package:skillbridge_mobile/shared/themes/app_theme.dart';

class QuotationCard extends StatelessWidget {
  final String workerName;
  final double rating;
  final int jobsCompleted;
  final double price;
  final String estimatedTime;
  final bool isTopRated;
  final List<String> badges;
  final String imageUrl;
  final VoidCallback? onSelected;
  final String? notes;

  const QuotationCard({
    super.key,
    required this.workerName,
    required this.rating,
    required this.jobsCompleted,
    required this.price,
    required this.estimatedTime,
    required this.isTopRated,
    required this.badges,
    required this.imageUrl,
    this.onSelected,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isTopRated ? Border.all(color: AppTheme.colors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTopRated)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Text(
                'TOP RATED FOR THIS JOB',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 25, 
                      backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                      child: Text(workerName[0].toUpperCase(), style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(workerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(' $rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(' ($jobsCompleted jobs)', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          if (badges.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: badges.map((b) => _buildBadge(b)).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${price.toStringAsFixed(0)}', style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
                        const Text('Total Cost', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                if (notes != null && notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
                  Text(notes!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                ],
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(Icons.timer_outlined, 'Timeline', estimatedTime),
                    _buildInfoItem(Icons.verified_user_outlined, 'Guarantee', '7 Days'),
                    ElevatedButton(
                      onPressed: onSelected,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                        minimumSize: const Size(100, 40),
                        backgroundColor: AppTheme.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.colors.jobCardSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: AppTheme.colors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}
