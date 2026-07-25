import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/currency_text.dart';

class IncomeExpenseCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const IncomeExpenseCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),

            const SizedBox(height: 12),

            Text(title, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 6),

            CurrencyText(
              amount: amount,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
