import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/saving_target_model.dart'; // Import ini wajib ditambahkan
import '../../../../services/financial_service.dart';

class SavingProgressCard extends StatelessWidget {
  const SavingProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final savingTargets = FinancialService.getSavingTargets();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress Target",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 18),

          if (savingTargets.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Belum ada target menabung.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...savingTargets.map((target) {
              // 1. Hitung saldo saat ini (current)
              final current = FinancialService.getSavingCurrent(target);

              // 2. Hitung persentase
              final percent = FinancialService.getSavingPercent(
                current: current,
                target: target.targetAmount,
              );

              // 3. Format label teks berdasarkan satuan (Emas/Gram vs Uang/Rupiah)
              final labelAmount = target.unit == SavingTargetUnit.gold
                  ? "${current.toStringAsFixed(2)} gr / ${target.targetAmount.toStringAsFixed(2)} gr"
                  : "Rp ${current.toStringAsFixed(0)} / Rp ${target.targetAmount.toStringAsFixed(0)}";

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      target.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(20),
                            backgroundColor: Colors.white10,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          "${(percent * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      labelAmount,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
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
