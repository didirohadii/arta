import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/currency_text.dart';
import '../../../services/analytics_service.dart';

class FinancialSummaryCard extends StatelessWidget {
  const FinancialSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final income = AnalyticsService.getIncome();
    final expense = AnalyticsService.getExpense();
    final balance = AnalyticsService.getBalance();
    final asset = AnalyticsService.getTotalAsset();

    final hasData = income > 0 || expense > 0 || asset > 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Keuangan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 20),

          if (!hasData)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Belum ada data keuangan.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else ...[
            _SummaryItem(title: "Total Asset", amount: asset),

            const Divider(),

            _SummaryItem(title: "Income", amount: income, color: Colors.green),

            const Divider(),

            _SummaryItem(title: "Expense", amount: expense, color: Colors.red),

            const Divider(),

            _SummaryItem(
              title: "Cash Flow",
              amount: balance,
              color: balance >= 0 ? Colors.blue : Colors.red,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final double amount;
  final Color? color;

  const _SummaryItem({required this.title, required this.amount, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title),
        const Spacer(),
        CurrencyText(amount: amount, color: color),
      ],
    );
  }
}
