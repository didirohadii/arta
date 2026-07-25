import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../services/analytics_service.dart';

class CategoryExpenseCard extends StatelessWidget {
  const CategoryExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = AnalyticsService.getExpenseByCategory();

    if (data.isEmpty) {
      return const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pengeluaran Berdasarkan Kategori",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                "Belum ada data pengeluaran.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    final max = data.first.amount;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pengeluaran Berdasarkan Kategori",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ...data.map((item) {
            final percent = item.amount / max;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.category,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),

                      CurrencyText(
                        amount: item.amount,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
