import 'package:flutter/material.dart';

import '../../../data/models/saving_target_model.dart';
import '../../core/widgets/currency_text.dart';
import '../../services/financial_service.dart';
import 'add_saving_target_page.dart';

class SavingTargetPage extends StatelessWidget {
  const SavingTargetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, _) {
        final targets = FinancialService.getSavingTargets();

        return Scaffold(
          appBar: AppBar(title: const Text("Target Menabung")),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSavingTargetPage()),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: targets.isEmpty
              ? const Center(child: Text("Belum ada target"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: targets.length,
                  itemBuilder: (context, index) {
                    final target = targets[index];
                    final current = FinancialService.getSavingCurrent(target);
                    final percent = FinancialService.getSavingPercent(
                      current: current,
                      target: target.targetAmount,
                    );

                    return Dismissible(
                      key: ValueKey(target.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Hapus Target"),
                            content: const Text(
                              "Yakin ingin menghapus target ini?",
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
                      },
                      onDismissed: (_) {
                        FinancialService.deleteSavingTarget(target.id);
                      },
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddSavingTargetPage(target: target),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  target.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Pembeda Tampilan Satuan Target (Emas vs Uang)
                                if (target.unit == SavingTargetUnit.gold)
                                  Row(
                                    children: [
                                      Text(
                                        "${current.toStringAsFixed(2)} gr",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const Text(" / "),
                                      Text(
                                        "${target.targetAmount.toStringAsFixed(2)} gr",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      CurrencyText(
                                        amount: current,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                      const Text(" / "),
                                      CurrencyText(
                                        amount: target.targetAmount,
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 14),

                                LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "${(percent * 100).toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
