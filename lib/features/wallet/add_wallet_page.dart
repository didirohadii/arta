import 'package:flutter/material.dart';

import '../../data/models/wallet_model.dart';
import '../../services/financial_service.dart';
import 'package:arta/core/extensions/wallet_type_extension.dart';

class AddWalletPage extends StatefulWidget {
  final WalletModel? wallet;

  const AddWalletPage({super.key, this.wallet});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final gramController = TextEditingController();

  WalletType selectedType = WalletType.bank;

  IconData selectedIcon = Icons.account_balance;
  Color selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();

    if (widget.wallet != null) {
      final wallet = widget.wallet!;

      nameController.text = wallet.name;
      balanceController.text = wallet.initialBalance.toInt().toString();
      gramController.text = (wallet.gram ?? 0).toString();

      selectedType = wallet.type;
      selectedIcon = wallet.type.icon;
      selectedColor = wallet.type.color;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    gramController.dispose();
    super.dispose();
  }

  void updateDefaultIcon() {
    switch (selectedType) {
      case WalletType.cash:
        selectedIcon = Icons.payments;
        selectedColor = Colors.green;
        break;

      case WalletType.bank:
        selectedIcon = Icons.account_balance;
        selectedColor = Colors.blue;
        break;

      case WalletType.investment:
        selectedIcon = Icons.trending_up;
        selectedColor = Colors.orange;
        break;

      case WalletType.gold:
        selectedIcon = Icons.workspace_premium;
        selectedColor = Colors.amber;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    updateDefaultIcon();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet == null ? "Tambah Wallet" : "Edit Wallet"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Wallet",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<WalletType>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: "Tipe Wallet",
                border: OutlineInputBorder(),
              ),
              items: WalletType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Saldo Awal",
                prefixText: "Rp ",
                border: OutlineInputBorder(),
              ),
            ),

            if (selectedType == WalletType.gold) ...[
              const SizedBox(height: 20),

              TextField(
                controller: gramController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Jumlah Gram",
                  suffixText: "gr",
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nama wallet wajib diisi")),
                    );
                    return;
                  }

                  final balance = double.tryParse(balanceController.text);

                  if (balance == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Saldo tidak valid")),
                    );
                    return;
                  }

                  final gram = double.tryParse(gramController.text) ?? 0;

                  final wallet = WalletModel(
                    id:
                        widget.wallet?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),

                    name: nameController.text.trim(),

                    initialBalance: balance,

                    type: selectedType,

                    gram: selectedType == WalletType.gold ? gram : null,
                  );

                  if (widget.wallet == null) {
                    FinancialService.addWallet(wallet);
                  } else {
                    FinancialService.updateWallet(wallet);
                  }

                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
