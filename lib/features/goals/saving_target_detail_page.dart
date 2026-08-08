import 'package:flutter/material.dart';

import '../../data/models/saving_target_model.dart';
import '../../services/financial_service.dart';
import '../../core/widgets/currency_text.dart';
import 'add_saving_target_page.dart';

class SavingTargetDetailPage extends StatelessWidget {
  final SavingTargetModel target;

  const SavingTargetDetailPage({super.key, required this.target});

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, _) {
        final current = FinancialService.getSavingCurrent(target);

        final percent = FinancialService.getSavingPercent(
          current: current,
          target: target.targetAmount,
        );

        final remaining = (target.targetAmount - current).clamp(
          0,
          double.infinity,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text("Detail Target"),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "edit") {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddSavingTargetPage(target: target),
                      ),
                    );
                  }

                  if (value == "delete") {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Target?"),
                        content: Text(
                          "Yakin ingin menghapus target "
                          "\"${target.title}\"?",
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
                      await FinancialService.deleteSavingTarget(target.id);

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
                        Icon(Icons.edit_outlined),
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

          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        target.unit == SavingTargetUnit.gold
                            ? "Target Emas"
                            : "Target Uang",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (target.unit == SavingTargetUnit.gold)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${current.toStringAsFixed(2)} gr",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "/ ${target.targetAmount.toStringAsFixed(2)} gr",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CurrencyText(
                              amount: current,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "/",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CurrencyText(
                              amount: target.targetAmount,
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),

                      const SizedBox(height: 18),

                      LinearProgressIndicator(
                        value: percent.clamp(0, 1),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "${(percent * 100).clamp(0, 100).toStringAsFixed(1)}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _infoRow(
                        context,
                        "Terkumpul",
                        target.unit == SavingTargetUnit.gold
                            ? "${current.toStringAsFixed(2)} gr"
                            : null,
                        target.unit == SavingTargetUnit.money ? current : null,
                      ),

                      const Divider(height: 24),

                      _infoRow(
                        context,
                        "Target",
                        target.unit == SavingTargetUnit.gold
                            ? "${target.targetAmount.toStringAsFixed(2)} gr"
                            : null,
                        target.unit == SavingTargetUnit.money
                            ? target.targetAmount
                            : null,
                      ),

                      const Divider(height: 24),

                      _infoRow(
                        context,
                        "Sisa",
                        target.unit == SavingTargetUnit.gold
                            ? "${remaining.toStringAsFixed(2)} gr"
                            : null,
                        target.unit == SavingTargetUnit.money
                            ? remaining.toDouble()
                            : null,
                      ),

                      const Divider(height: 24),

                      _infoRowText(
                        context,
                        "Target tercapai",
                        _formatDate(target.targetDate),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Wallet yang digunakan",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ...target.walletIds.map((walletId) {
                        final wallets = FinancialService.getWallets();

                        final wallet = wallets.where((w) => w.id == walletId);

                        if (wallet.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.account_balance_wallet),
                          ),
                          title: Text(wallet.first.name),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String? text,
    double? amount,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (text != null)
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (amount != null)
          CurrencyText(amount: amount, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _infoRowText(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
