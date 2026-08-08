import 'package:flutter/material.dart';

import 'package:arta/core/extensions/wallet_type_extension.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/currency_text.dart';
import '../../core/widgets/wallet_tile.dart';
import '../../services/financial_service.dart';
import '../../data/models/wallet_model.dart'; // Menambahkan import WalletType jika diperlukan
import 'wallet_detail_page.dart';
import 'add_wallet_page.dart';
import 'widgets/add_gold_bottom_sheet.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FinancialService.refreshNotifier,
      builder: (context, _, _) {
        // 1. Pembagian wallet berdasarkan WalletType
        final allWallets = FinancialService.getWallets();

        final goldWallets = allWallets
            .where((wallet) => wallet.type == WalletType.gold)
            .toList();

        final investmentWallets = allWallets
            .where((wallet) => wallet.type == WalletType.investment)
            .toList();

        final wallets = allWallets
            .where(
              (wallet) =>
                  wallet.type != WalletType.gold &&
                  wallet.type != WalletType.investment,
            )
            .toList();

        final totalAsset = FinancialService.getTotalAsset();

        return Scaffold(
          appBar: AppBar(title: const Text("Wallet")),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWalletPage()),
              );
              if (mounted) setState(() {});
            },
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Card Total Asset
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Asset",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    CurrencyText(amount: totalAsset, fontSize: 30),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ============================
              // SECTION EMAS
              // ============================
              if (goldWallets.isNotEmpty) ...[
                const Text(
                  "Emas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    children: goldWallets.map((wallet) {
                      return Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WalletDetailPage(wallet: wallet),
                                ),
                              );
                              if (mounted) setState(() {});
                            },
                            child: WalletTile(
                              icon: wallet.type.icon,
                              color: wallet.type.color,
                              title: wallet.name,
                              amount: wallet.gram ?? 0,
                              isGold: true,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 12,
                                bottom: 8,
                              ),
                              child: TextButton.icon(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                ),
                                label: const Text("Tambah Emas"),
                                onPressed: () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) =>
                                        AddGoldBottomSheet(wallet: wallet),
                                  );
                                  if (mounted) setState(() {});
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ============================
              // SECTION INVESTASI
              // ============================
              if (investmentWallets.isNotEmpty) ...[
                const Text(
                  "Investasi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    children: investmentWallets.map((wallet) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WalletDetailPage(wallet: wallet),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                        child: WalletTile(
                          icon: wallet.type.icon,
                          color: wallet.type.color,
                          title: wallet.name,
                          amount: FinancialService.getWalletBalance(wallet.id),
                          isGold: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ============================
              // SECTION WALLET UTAMA
              // ============================
              const Text(
                "Wallet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              AppCard(
                child: wallets.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            "Belum ada Wallet",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = wallets[index];

                          // Dismissible dihapus, diganti langsung dengan InkWell
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WalletDetailPage(wallet: wallet),
                                ),
                              );
                              if (mounted) setState(() {});
                            },
                            child: WalletTile(
                              icon: wallet.type.icon,
                              color: wallet.type.color,
                              title: wallet.name,
                              amount: FinancialService.getWalletBalance(
                                wallet.id,
                              ),
                              isGold: false,
                            ),
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
}
