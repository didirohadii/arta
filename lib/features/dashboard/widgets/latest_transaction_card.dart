import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/currency_text.dart';
import '../../../data/models/transaction_model.dart';
import '../../../services/financial_service.dart';
import 'package:arta/core/extensions/transaction_type_extension.dart';

class LatestTransactionCard extends StatelessWidget {
  const LatestTransactionCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data transaksi riil dari FinancialService dan membatasi maksimal 5 item terbaru
    final transactions = FinancialService.getTransactions().take(5).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long),
              SizedBox(width: 8),
              Text(
                "Transaksi Terbaru",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Belum ada transaksi",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...transactions.map((transaction) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: transaction.type.color.withValues(alpha: 0.15),
                    child: Icon(transaction.type.icon, color: transaction.type.color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.category,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CurrencyText(
                        amount: transaction.amount,
                        fontWeight: FontWeight.bold,
                        color: transaction.type == TransactionType.income
                            ? Colors.green
                            : transaction.type == TransactionType.expense
                            ? Colors.red
                            : Colors.blue,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
