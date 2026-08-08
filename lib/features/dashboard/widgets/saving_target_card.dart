import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/currency_text.dart';
import '../../../data/models/saving_target_model.dart';
import '../../../services/financial_service.dart';
import '../../goals/add_saving_target_page.dart';
import '../../goals/saving_target_page.dart';

class SavingTargetCard extends StatelessWidget {
  const SavingTargetCard({super.key});

  String _formatTargetDate(DateTime date) {
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

    return "${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, _) {
        final savings = FinancialService.getSavingTargets();

        // Menggunakan struktur baru Anda agar memanfaatkan lebar layar device sepenuhnya
        if (savings.isEmpty) {
          return AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.flag_circle,
                      size: 60,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Belum ada target menabung",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Mulai buat target finansial pertamamu.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddSavingTargetPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Tambah Target Menabung"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final saving = savings.first;

        final current = FinancialService.getSavingCurrent(saving);
        final target = saving.targetAmount;

        final percent = FinancialService.getSavingPercent(
          current: current,
          target: target,
        );

        final remaining = FinancialService.getSavingRemaining(
          current: current,
          target: target,
        );

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavingTargetPage()),
            );
          },
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_circle, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    const Text(
                      "Target Menabung",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "${(percent * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  saving.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (saving.unit == SavingTargetUnit.gold)
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
                            "${target.toStringAsFixed(2)} gr",
                            style: const TextStyle(color: Colors.grey),
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
                          CurrencyText(amount: target, color: Colors.grey),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.savings,
                        title: "Sisa",
                        value: saving.unit == SavingTargetUnit.gold
                            ? "${remaining.toStringAsFixed(2)} gr"
                            : "Rp ${remaining.toStringAsFixed(0)}",
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.calendar_month,
                        title: "Estimasi",
                        value: _formatTargetDate(saving.targetDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavingTargetPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      savings.length == 1
                          ? "Lihat Target"
                          : "Lihat ${savings.length} Target",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.deepPurple.withValues(alpha: 0.08),
          child: Icon(icon, color: Colors.deepPurple, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
