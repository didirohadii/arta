import 'package:flutter/material.dart';

import '../../../core/widgets/currency_text.dart';
import '../../../services/financial_service.dart';

class TotalAssetCard extends StatelessWidget {
  const TotalAssetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final growth = FinancialService.getAssetGrowthPercentage();
    final hasGrowth = FinancialService.hasAssetGrowthHistory();

    final isPositive = growth > 0;
    final isNegative = growth < 0;

    String changeText;

    if (!hasGrowth) {
      changeText = "Belum ada data pembanding";
    } else if (isPositive) {
      changeText = "Naik dari sebelumnya";
    } else if (isNegative) {
      changeText = "Turun dari sebelumnya";
    } else {
      changeText = "Belum ada perubahan";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B5FEF), Color(0xFF7B61FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
              ),

              const SizedBox(width: 8),

              const Text(
                "Total Asset",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasGrowth)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up
                                : isNegative
                                ? Icons.trending_down
                                : Icons.trending_flat,
                            size: 16,
                            color: isPositive
                                ? Colors.greenAccent
                                : isNegative
                                ? Colors.redAccent
                                : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${growth >= 0 ? "+" : ""}${growth.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        "--",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 2),

                    Text(
                      changeText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          CurrencyText(
            amount: FinancialService.getTotalAsset(),
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),

          const SizedBox(height: 6),

          const Text(
            "Terakhir diperbarui • Hari ini",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 24),

          Container(height: 1, color: Colors.white24),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  title: "Income",
                  value: FinancialService.getTotalIncome(),
                  icon: Icons.arrow_downward,
                  iconColor: Colors.greenAccent,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _SummaryItem(
                  title: "Expense",
                  value: FinancialService.getTotalExpense(),
                  icon: Icons.arrow_upward,
                  iconColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color iconColor;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),

          const SizedBox(height: 8),

          Text(title, style: const TextStyle(color: Colors.white70)),

          const SizedBox(height: 6),

          CurrencyText(
            amount: value,
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
