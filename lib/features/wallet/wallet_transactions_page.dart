import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../services/financial_service.dart';
import '../../core/widgets/currency_text.dart';
import 'package:arta/core/extensions/transaction_type_extension.dart';

class WalletTransactionsPage extends StatelessWidget {
  final WalletModel wallet;

  const WalletTransactionsPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final transactions = FinancialService.getTransactions()
        .where(
          (trx) =>
              trx.sourceWalletId == wallet.id ||
              trx.destinationWalletId == wallet.id,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Transaksi ${wallet.name}")),
      body: transactions.isEmpty
          ? const Center(child: Text("Belum ada transaksi"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final trx = transactions[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: trx.type.color.withValues(alpha: .15),
                      child: Icon(trx.type.icon, color: trx.type.color),
                    ),
                    title: Text(
                      trx.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trx.category),
                        Text(
                          "${trx.date.day}/${trx.date.month}/${trx.date.year}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: CurrencyText(
                      amount: trx.amount,
                      color: trx.type == TransactionType.income
                          ? Colors.green
                          : trx.type == TransactionType.expense
                          ? Colors.red
                          : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
