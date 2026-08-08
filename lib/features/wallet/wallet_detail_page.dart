import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../services/financial_service.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/currency_text.dart';
import 'package:arta/core/extensions/transaction_type_extension.dart';
import 'add_wallet_page.dart';
import 'wallet_transactions_page.dart'; // Sesuaikan lokasi file WalletTransactionsPage jika ada

class WalletDetailPage extends StatelessWidget {
  final WalletModel wallet;

  const WalletDetailPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, __) {
        final walletTransactions = FinancialService.getTransactions()
            .where(
              (trx) =>
                  trx.sourceWalletId == wallet.id ||
                  trx.destinationWalletId == wallet.id,
            )
            .toList();

        final latestTransactions = walletTransactions.take(3).toList();

        double income = 0;
        double expense = 0;
        double transferIn = 0;
        double transferOut = 0;

        for (final trx in walletTransactions) {
          if (trx.type == TransactionType.income &&
              trx.destinationWalletId == wallet.id) {
            income += trx.amount;
          }

          if (trx.type == TransactionType.expense &&
              trx.sourceWalletId == wallet.id) {
            expense += trx.amount;
          }

          if (trx.type == TransactionType.transfer) {
            if (trx.destinationWalletId == wallet.id) {
              transferIn += trx.amount;
            }

            if (trx.sourceWalletId == wallet.id) {
              transferOut += trx.amount;
            }
          }
        }

        final balance = FinancialService.getWalletBalance(wallet.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(wallet.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "edit") {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddWalletPage(wallet: wallet),
                      ),
                    );
                  }

                  if (value == "delete") {
                    final used = FinancialService.isWalletUsed(wallet.id);

                    if (used) {
                      final dependencies =
                          FinancialService.getWalletDependencies(wallet.id);

                      if (!context.mounted) return;

                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Wallet tidak dapat dihapus"),
                          content: Text(
                            "Wallet ini masih digunakan oleh:\n\n"
                            "• ${dependencies.join("\n• ")}",
                          ),
                          actions: [
                            FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );

                      return;
                    }

                    if (!context.mounted) return;

                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Wallet?"),
                        content: Text(
                          "Yakin ingin menghapus wallet ${wallet.name}?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Batal"),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Hapus"),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await FinancialService.deleteWallet(wallet.id);

                      if (!context.mounted) return;

                      Navigator.pop(context);
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: "edit",
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 10),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "delete",
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text("Hapus"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ============================
                // SALDO
                // ============================
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.isGold ? "Emas" : "Saldo",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),

                      if (wallet.isGold)
                        Text(
                          "${wallet.gram ?? 0} gram",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        CurrencyText(
                          amount: balance,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),

                      if (wallet.isGold) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Emas dikelola melalui halaman Wallet.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ============================
                // RINGKASAN
                // ============================
                if (!wallet.isGold)
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          context,
                          title: "Income",
                          amount: income,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          context,
                          title: "Expense",
                          amount: expense,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                if (!wallet.isGold) const SizedBox(height: 10),

                if (!wallet.isGold)
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          context,
                          title: "Transfer Masuk",
                          amount: transferIn,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summaryCard(
                          context,
                          title: "Transfer Keluar",
                          amount: transferOut,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                // ============================
                // TRANSAKSI TERBARU
                // ============================
                const SizedBox(height: 24),

                Row(
                  children: [
                    const Text(
                      "Transaksi Terbaru",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (walletTransactions.length > 3)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WalletTransactionsPage(wallet: wallet),
                            ),
                          );
                        },
                        child: const Text("Lihat semua transaksi"),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                if (latestTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "Belum ada transaksi",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...latestTransactions.map(
                    (trx) => _buildTransactionTile(context, trx),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required double amount,
    required Color color,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          CurrencyText(
            amount: amount,
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel trx) {
    final isIncome =
        trx.type == TransactionType.income &&
        trx.destinationWalletId == wallet.id;

    final isExpense =
        trx.type == TransactionType.expense && trx.sourceWalletId == wallet.id;

    final isTransferIn =
        trx.type == TransactionType.transfer &&
        trx.destinationWalletId == wallet.id;

    final color = isIncome
        ? Colors.green
        : isExpense
        ? Colors.red
        : isTransferIn
        ? Colors.blue
        : Colors.orange;

    final prefix = isIncome
        ? "+"
        : isExpense
        ? "-"
        : isTransferIn
        ? "+"
        : "-";

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .15),
          child: Icon(trx.type.icon, color: color),
        ),
        title: Text(
          trx.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trx.category),
            Text(trx.note?.trim().isNotEmpty == true ? trx.note! : "-"),
            Text(
              "${trx.date.day}/${trx.date.month}/${trx.date.year}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Text(
          "$prefix Rp ${trx.amount.toStringAsFixed(0)}",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
