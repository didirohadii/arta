import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../services/analytics_service.dart';
import 'package:arta/core/extensions/wallet_type_extension.dart';

class WalletDistributionCard extends StatelessWidget {
  const WalletDistributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final walletDistribution = AnalyticsService.getWalletDistribution();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Distribusi Wallet",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 18),
          if (walletDistribution.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Belum ada data wallet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...walletDistribution.entries.map((entry) {
              final wallet = entry.key;
              final percent = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(wallet.type.icon, color: wallet.type.color),
                        const SizedBox(width: 10),
                        Expanded(child: Text(wallet.name)),
                        Text(
                          "${(percent * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percent,
                      color: wallet.type.color,
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
