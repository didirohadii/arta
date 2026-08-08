import 'package:flutter/material.dart';

import 'package:arta/core/extensions/wallet_type_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/currency_text.dart';
import '../../../services/financial_service.dart';
import '../../main/main_page.dart'; 

class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

  String _formatGram(double gram) {
    if (gram % 1 == 0) {
      return "${gram.toInt()} gr";
    }

    return "${gram.toStringAsFixed(2)} gr";
  }

  @override
  Widget build(BuildContext context) {
    final wallets = FinancialService.getWallets();
    final totalAsset = FinancialService.getTotalAsset();

    if (wallets.isEmpty) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined),
                SizedBox(width: 8),
                Text(
                  "Wallet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Belum ada wallet",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined),
              SizedBox(width: 8),
              Text(
                "Wallet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tampilkan maksimal 5 wallet secara vertikal
          ...wallets.take(5).map((wallet) {
            final balance = wallet.isGold
                ? (wallet.gram ?? 0)
                : FinancialService.getWalletBalance(wallet.id);

            final double percent = wallet.isGold || totalAsset == 0
                ? 0
                : (balance / totalAsset).clamp(0, 1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: wallet.type.color.withValues(
                          alpha: .15,
                        ),
                        child: Icon(
                          wallet.type.icon,
                          color: wallet.type.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          wallet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      wallet.isGold
                          ? Text(
                              _formatGram(balance),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )
                          : CurrencyText(
                              amount: balance,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                    ],
                  ),

                  if (!wallet.isGold) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 7,
                        backgroundColor: Colors.grey.shade200,
                        color: wallet.type.color,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Jika jumlah wallet > 5, tampilkan tombol navigasi tab
          if (wallets.length > 5) ...[
            const SizedBox(height: 4),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Mengubah index notifier ke 1 (tab Wallet) tanpa Navigator.push
                  mainPageIndexNotifier.value = 1;
                },
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text("Lihat semua wallet"),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
