import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/currency_text.dart';
import '../../../data/models/budget_model.dart';
import '../../../services/financial_service.dart';
import 'package:arta/main.dart';
import 'add_budget_bottom_sheet.dart';

class BudgetCard extends StatefulWidget {
  const BudgetCard({super.key});

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();

    // Default filter: bulan saat ini
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);
  }

  String get monthName {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

    return months[selectedMonth.month - 1];
  }

  Future<void> changeMonth(int offset) async {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + offset,
      );
    });
  }

  Future<void> showBudgetForm(
    BuildContext context, {
    BudgetModel? budget,
  }) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddBudgetBottomSheet(budget: budget),
    );

    if (result != null) {
      await Future.delayed(const Duration(milliseconds: 150));

      String message = "";

      if (result == "success_add") {
        message = "Budget berhasil ditambahkan";
      } else if (result == "success_update") {
        message = "Budget berhasil diperbarui";
      }

      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, _) {
        final allBudgets = FinancialService.getBudgets();

        // FILTER BERDASARKAN BULAN TANGGAL AKHIR
        final budgets = allBudgets.where((budget) {
          return budget.endDate.month == selectedMonth.month &&
              budget.endDate.year == selectedMonth.year;
        }).toList();

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Budget Bulanan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => showBudgetForm(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Tambah"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // FILTER BULAN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => changeMonth(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),

                    Expanded(
                      child: Center(
                        child: Text(
                          "$monthName ${selectedMonth.year}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => changeMonth(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (budgets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      "Belum ada budget pada periode ini.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...budgets.map((budget) {
                  final spent = FinancialService.getBudgetSpent(budget);

                  final progress = FinancialService.getBudgetProgress(budget);

                  Color progressColor;

                  if (progress >= 1) {
                    progressColor = Colors.red;
                  } else if (progress >= 0.7) {
                    progressColor = Colors.orange;
                  } else {
                    progressColor = Colors.green;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                budget.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Text(
                              "${(progress * 100).clamp(0, 999).toStringAsFixed(0)}%",
                              style: TextStyle(
                                color: progressColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              padding: EdgeInsets.zero,
                              onSelected: (value) async {
                                if (value == "edit") {
                                  showBudgetForm(context, budget: budget);
                                }

                                if (value == "delete") {
                                  await FinancialService.deleteBudget(
                                    budget.id,
                                  );

                                  rootScaffoldMessengerKey.currentState
                                      ?.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Budget berhasil dihapus",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 2),
                                          margin: EdgeInsets.all(20),
                                        ),
                                      );
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Text("Hapus"),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // PERIODE
                        Text(
                          "${budget.startDate.day}/${budget.startDate.month}/${budget.startDate.year}"
                          " - "
                          "${budget.endDate.day}/${budget.endDate.month}/${budget.endDate.year}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            CurrencyText(
                              amount: spent,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            Text(
                              " / ",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            CurrencyText(
                              amount: budget.amount,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        LinearProgressIndicator(
                          value: progress.clamp(0, 1),
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          color: progressColor,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        const SizedBox(height: 8),

                        if (progress >= 1)
                          const Text(
                            "⚠ Budget terlampaui",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Row(
                            children: [
                              const Text(
                                "Sisa ",
                                style: TextStyle(color: Colors.green),
                              ),
                              CurrencyText(
                                amount: FinancialService.getBudgetRemaining(
                                  budget,
                                ),
                                color: Colors.green,
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
      },
    );
  }
}
