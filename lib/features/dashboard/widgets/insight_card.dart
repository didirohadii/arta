import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../services/insight_service.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = InsightService.getInsights();

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul Smart Insight
          const Text(
            "Smart Insight",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 2),

          // BONUS: Counter Jumlah Insight
          Text(
            "${insights.length} Insight tersedia",
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          // List View Scrollable di dalam Card dengan Container Berwarna
          SizedBox(
            height: 240,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: insights.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = insights[index];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: item.color.withValues(alpha: .15),
                        child: Icon(item.icon, color: item.color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
