import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';

class StatusTimeline extends StatelessWidget {
  final String currentStatus;

  const StatusTimeline({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Define the display labels
    final List<String> statuses = ['Open', 'Assigned', 'In Progress', 'Reviewing', 'Completed'];
    
    // Map currentStatus to index (handling backend formats like 'in_progress' or 'OPEN')
    int currentIndex = 0;
    String normalized = currentStatus.toLowerCase().trim().replaceAll('_', ' ');
    if (normalized.contains('completed')) {
       currentIndex = 4;
    } else if (normalized.contains('reviewing')) {
       currentIndex = 3;
    } else if (normalized.contains('in progress')) {
       currentIndex = 2; // In Progress
    } else if (normalized.contains('assigned')) {
       currentIndex = 1;
    } else if (normalized.contains('open')) {
       currentIndex = 0;
    } else {
       // fallback matching
       currentIndex = statuses.indexWhere((s) => s.toLowerCase() == normalized);
       if (currentIndex == -1) currentIndex = 0;
    }

    return Row(
      children: List.generate(statuses.length, (index) {
        final bool isPast = index < currentIndex;
        final bool isCurrent = index == currentIndex;
        final bool isLast = index == statuses.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0 ? Colors.transparent : (isPast || isCurrent ? AppTheme.colors.primary : Colors.grey[300]),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isPast || isCurrent ? AppTheme.colors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPast || isCurrent ? AppTheme.colors.primary : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: isPast
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : isCurrent
                            ? Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              )
                            : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isLast ? Colors.transparent : (isPast ? AppTheme.colors.primary : Colors.grey[300]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                statuses[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent || isPast ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}
