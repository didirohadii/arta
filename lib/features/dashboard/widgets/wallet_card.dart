import 'package:flutter/material.dart';

import 'package:arta/core/extensions/wallet_type_extension.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/currency_text.dart';
import '../../../services/financial_service.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

  /// Helper untuk merapikan tampilan desimal gram
  String _formatGram(double gram) {
    if (gram % 1 == 0) {
      return "${gram.toInt()} gr";
    }
    return "${gram.toStringAsFixed(2)} gr";
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data wallet riil dari FinancialService
    final wallets = FinancialService.getWallets();
    final totalAsset = FinancialService.getTotalAsset();

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

          if (wallets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Belum ada wallet",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

          ...wallets.map((wallet) {
            // Jika emas, ambil nilai gram. Jika bukan, ambil saldo rupiah.
            final balance = wallet.isGold
                ? (wallet.gram ?? 0)
                : FinancialService.getWalletBalance(wallet.id);

            // Progress bar hanya dihitung untuk wallet rupiah
            final double percent = wallet.isGold || totalAsset == 0
                ? 0
                : balance / totalAsset;

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

                      // Tampilan angka: Gram untuk emas, Rupiah untuk dompet lain
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

                  // Progress Bar hanya ditampilkan jika bukan wallet emas
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
        ],
      ),
    );
  }
}
