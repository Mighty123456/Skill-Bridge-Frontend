import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

class AvailableJobCard extends StatelessWidget {
  final String title;
  final String location;
  final String urgency;
  final String estimatedPrice;
  final String postedTime;
  final String distance;
  final String remainingTime;

  const AvailableJobCard({
    super.key,
    required this.title,
    required this.location,
    required this.urgency,
    required this.estimatedPrice,
    required this.postedTime,
    required this.distance,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmergency = urgency == 'Emergency';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isEmergency ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isEmergency 
                ? Colors.red.withValues(alpha: 0.05) 
                : Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEmergency ? Colors.red : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEmergency) const Icon(Icons.flash_on, color: Colors.white, size: 12),
                        if (isEmergency) const SizedBox(width: 4),
                        Text(
                          urgency.toUpperCase(),
                          style: TextStyle(
                            color: isEmergency ? Colors.white : Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.orange, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          remainingTime,
                          style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(postedTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(width: 8),
              Text('($distance)', style: TextStyle(color: AppTheme.colors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budget Range', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(estimatedPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/job-bid');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Send Quote'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

