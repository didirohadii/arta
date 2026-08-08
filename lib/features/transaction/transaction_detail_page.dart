import 'package:flutter/material.dart';

import '../../core/widgets/currency_text.dart';
import '../../data/models/transaction_model.dart';
import '../../services/financial_service.dart';
import 'add_transaction_page.dart';
import 'package:arta/core/extensions/transaction_type_extension.dart';

class TransactionDetailPage extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late TransactionModel transaction;

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction;
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getWalletText() {
    return FinancialService.getTransactionWallet(transaction);
  }

  Future<void> _editTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(transaction: transaction),
      ),
    );

    if (!mounted) return;

    final updatedTransactions = FinancialService.getTransactions();

    final updated = updatedTransactions.where(
      (trx) => trx.id == transaction.id,
    );

    if (updated.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      transaction = updated.first;
    });
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Hapus Transaksi?"),
          content: const Text("Transaksi ini akan dihapus permanen."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Batal"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await FinancialService.deleteTransaction(transaction.id);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final type = transaction.type;

    final amountColor = type == TransactionType.income
        ? Colors.green
        : type == TransactionType.expense
        ? Colors.red
        : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        actions: [
          IconButton(
            onPressed: _editTransaction,
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Edit",
          ),
          IconButton(
            onPressed: _deleteTransaction,
            icon: const Icon(Icons.delete_outline),
            tooltip: "Hapus",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            CircleAvatar(
              radius: 34,
              backgroundColor: type.color.withValues(alpha: .12),
              child: Icon(type.icon, size: 32, color: type.color),
            ),

            const SizedBox(height: 16),

            Text(
              transaction.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            CurrencyText(
              amount: transaction.amount,
              color: amountColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),

            const SizedBox(height: 28),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _detailRow(
                      icon: Icons.swap_horiz,
                      label: type == TransactionType.transfer
                          ? "Transfer"
                          : "Sumber Dana",
                      value: _getWalletText(),
                    ),

                    const Divider(height: 24),

                    _detailRow(
                      icon: Icons.category_outlined,
                      label: "Kategori",
                      value: transaction.category.isEmpty
                          ? "-"
                          : transaction.category,
                    ),

                    const Divider(height: 24),

                    _detailRow(
                      icon: Icons.notes_outlined,
                      label: "Catatan",
                      value:
                          transaction.note == null ||
                              transaction.note!.trim().isEmpty
                          ? "-"
                          : transaction.note!.trim(),
                    ),

                    const Divider(height: 24),

                    _detailRow(
                      icon: Icons.calendar_today_outlined,
                      label: "Tanggal",
                      value: _formatDate(transaction.date),
                    ),

                    const Divider(height: 24),

                    _detailRow(
                      icon: Icons.fingerprint,
                      label: "ID Transaksi",
                      value: transaction.id,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _editTransaction,
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Edit Transaksi"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                onPressed: _deleteTransaction,
                icon: const Icon(Icons.delete_outline),
                label: const Text("Hapus Transaksi"),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
