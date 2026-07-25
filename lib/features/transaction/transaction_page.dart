import 'package:flutter/material.dart';
import '../transaction/add_transaction_page.dart';
import '../../data/models/transaction_model.dart';
import '../../services/financial_service.dart';
import '../../core/widgets/currency_text.dart';
import 'package:arta/core/extensions/transaction_type_extension.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TransactionType? filter;
  final searchController = TextEditingController();
  String keyword = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, __, ___) {
        var transactions = FinancialService.getTransactions();

        if (filter != null) {
          transactions = transactions.where((e) => e.type == filter).toList();
        }

        if (keyword.isNotEmpty) {
          transactions = transactions.where((trx) {
            return trx.title.toLowerCase().contains(keyword) ||
                trx.category.toLowerCase().contains(keyword) ||
                FinancialService.getTransactionWallet(
                  trx,
                ).toLowerCase().contains(keyword);
          }).toList();
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Riwayat Transaksi")),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        "Income",
                        FinancialService.getTotalIncome(),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryCard(
                        "Expense",
                        FinancialService.getTotalExpense(),
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryCard(
                        "Transfer",
                        FinancialService.getTotalTransfer(),
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      keyword = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Cari transaksi...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _chip(
                      "Semua",
                      filter == null,
                      () => setState(() => filter = null),
                    ),
                    _chip(
                      "Income",
                      filter == TransactionType.income,
                      () => setState(() => filter = TransactionType.income),
                    ),
                    _chip(
                      "Expense",
                      filter == TransactionType.expense,
                      () => setState(() => filter = TransactionType.expense),
                    ),
                    _chip(
                      "Transfer",
                      filter == TransactionType.transfer,
                      () => setState(() => filter = TransactionType.transfer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text("Belum ada transaksi"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final trx = transactions[index];
                          final currentGroup = FinancialService.formatGroupDate(
                            trx.date,
                          );

                          final previousGroup = index == 0
                              ? ""
                              : FinancialService.formatGroupDate(
                                  transactions[index - 1].date,
                                );

                          final showHeader = currentGroup != previousGroup;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showHeader)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    currentGroup,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Dismissible(
                                key: ValueKey(trx.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Hapus Transaksi?"),
                                      content: const Text(
                                        "Transaksi ini akan dihapus permanen.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text("Batal"),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text("Hapus"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (_) {
                                  FinancialService.deleteTransaction(trx.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Transaksi dihapus"),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddTransactionPage(
                                            transaction: trx,
                                          ),
                                        ),
                                      );
                                      setState(() {});
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: trx.type.color.withValues(
                                        alpha: .15,
                                      ),
                                      child: Icon(trx.type.icon, color: trx.type.color),
                                    ),
                                    title: Text(
                                      trx.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          FinancialService.getTransactionWallet(
                                            trx,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
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
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: .08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CurrencyText(
              amount: amount,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String title, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(title),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
