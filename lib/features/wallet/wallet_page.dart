import 'package:flutter/material.dart';

import 'package:arta/core/extensions/wallet_type_extension.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/currency_text.dart';
import '../../core/widgets/wallet_tile.dart';
import '../../services/financial_service.dart';
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
        // Mengambil data wallet langsung dari FinancialService
        final wallets = FinancialService.getWallets();
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

              // Card Daftar Wallet
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

                          return Dismissible(
                            key: ValueKey(wallet.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              final used = FinancialService.isWalletUsed(
                                wallet.id,
                              );

                              // Proteksi jika wallet sedang digunakan di Transaksi atau Saving Target
                              if (used) {
                                final dependencies =
                                    FinancialService.getWalletDependencies(
                                      wallet.id,
                                    );

                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text(
                                      "Wallet tidak dapat dihapus",
                                    ),
                                    content: Text(
                                      "Wallet ini masih digunakan oleh:\n\n• ${dependencies.join("\n• ")}",
                                    ),
                                    actions: [
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return false;
                              }

                              // Konfirmasi hapus jika wallet kosong/tidak digunakan
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Hapus Wallet"),
                                      content: Text(
                                        "Yakin ingin menghapus ${wallet.name}?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Batal"),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Hapus"),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) {
                              FinancialService.deleteWallet(wallet.id);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddWalletPage(wallet: wallet),
                                  ),
                                );
                                if (mounted) setState(() {});
                              },
                              child: Column(
                                children: [
                                  WalletTile(
                                    icon: wallet.type.icon,
                                    color: wallet.type.color,
                                    title: wallet.name,
                                    amount: wallet.isGold
                                        ? (wallet.gram ?? 0)
                                        : FinancialService.getWalletBalance(
                                            wallet.id,
                                          ),
                                    isGold: wallet.isGold,
                                  ),

                                  if (wallet.isGold)
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
                                                  AddGoldBottomSheet(
                                                    wallet: wallet,
                                                  ),
                                            );

                                            if (mounted) setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
