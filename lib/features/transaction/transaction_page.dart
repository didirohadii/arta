import 'package:flutter/material.dart';
import 'transaction_detail_page.dart';
import '../../data/models/transaction_model.dart';
import '../../services/financial_service.dart';
import '../../core/widgets/currency_text.dart';
import 'package:arta/core/extensions/transaction_type_extension.dart';

enum DateFilterType { all, thisMonth, lastMonth, custom }

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TransactionType? typeFilter;
  DateFilterType dateFilter = DateFilterType.thisMonth; // Default bulan ini
  DateTimeRange? customDateRange;

  final searchController = TextEditingController();
  String keyword = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Helper filter tanggal
  bool _filterByDate(DateTime date) {
    final now = DateTime.now();
    switch (dateFilter) {
      case DateFilterType.thisMonth:
        return date.year == now.year && date.month == now.month;
      case DateFilterType.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1);
        return date.year == lastMonth.year && date.month == lastMonth.month;
      case DateFilterType.custom:
        if (customDateRange == null) return true;
        final start = customDateRange!.start;
        final end = customDateRange!.end.add(const Duration(days: 1));
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end);
      case DateFilterType.all:
        return true;
    }
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange:
          customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );

    if (picked != null) {
      setState(() {
        customDateRange = picked;
        dateFilter = DateFilterType.custom;
      });
    }
  }

  String _getDateFilterLabel() {
    switch (dateFilter) {
      case DateFilterType.thisMonth:
        return "Bulan Ini";
      case DateFilterType.lastMonth:
        return "Bulan Lalu";
      case DateFilterType.custom:
        if (customDateRange == null) return "Rentang Tanggal";
        final start = customDateRange!.start;
        final end = customDateRange!.end;
        return "${start.day}/${start.month} - ${end.day}/${end.month}";
      case DateFilterType.all:
        return "Semua Waktu";
    }
  }

  void _showDateFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Pilih Periode Waktu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text("Bulan Ini"),
                  trailing: dateFilter == DateFilterType.thisMonth
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() => dateFilter = DateFilterType.thisMonth);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("Bulan Lalu"),
                  trailing: dateFilter == DateFilterType.lastMonth
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() => dateFilter = DateFilterType.lastMonth);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(
                    dateFilter == DateFilterType.custom
                        ? "Rentang Custom (${_getDateFilterLabel()})"
                        : "Rentang Tanggal Custom...",
                  ),
                  trailing: dateFilter == DateFilterType.custom
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickCustomDateRange();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.all_inclusive),
                  title: const Text("Semua Waktu"),
                  trailing: dateFilter == DateFilterType.all
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() => dateFilter = DateFilterType.all);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, __, ___) {
        var transactions = FinancialService.getTransactions();

        // 1. Filter Tanggal
        transactions = transactions
            .where((e) => _filterByDate(e.date))
            .toList();

        // 2. Filter Tipe Transaksi
        if (typeFilter != null) {
          transactions = transactions
              .where((e) => e.type == typeFilter)
              .toList();
        }

        // 3. Filter Keyword Pencarian
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
              // Summary Cards
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

              // Search Bar
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

              // Satu Baris Chip Gabungan (Waktu + Tipe Transaksi)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Chip Filter Tanggal (ActionChip)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: const Icon(Icons.calendar_month, size: 16),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_getDateFilterLabel()),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                        onPressed: _showDateFilterBottomSheet,
                      ),
                    ),

                    // Chip Filter Tipe Transaksi
                    _chip(
                      "Semua Tipe",
                      typeFilter == null,
                      () => setState(() => typeFilter = null),
                    ),
                    _chip(
                      "Income",
                      typeFilter == TransactionType.income,
                      () => setState(() => typeFilter = TransactionType.income),
                    ),
                    _chip(
                      "Expense",
                      typeFilter == TransactionType.expense,
                      () =>
                          setState(() => typeFilter = TransactionType.expense),
                    ),
                    _chip(
                      "Transfer",
                      typeFilter == TransactionType.transfer,
                      () =>
                          setState(() => typeFilter = TransactionType.transfer),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // List Transaksi
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
                              Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TransactionDetailPage(
                                          transaction: trx,
                                        ),
                                      ),
                                    );

                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: trx.type.color.withValues(
                                      alpha: .15,
                                    ),
                                    child: Icon(
                                      trx.type.icon,
                                      color: trx.type.color,
                                    ),
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
                                      Text(
                                        "Catatan: ${trx.note?.trim().isNotEmpty == true ? trx.note!.trim() : "-"}",
                                      ),
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
