import 'package:flutter/material.dart';

import '../../data/models/saving_target_model.dart';
import '../../data/models/wallet_model.dart';
import '../../services/financial_service.dart';
import 'package:arta/core/extensions/wallet_type_extension.dart';

class AddSavingTargetPage extends StatefulWidget {
  final SavingTargetModel? target;

  const AddSavingTargetPage({super.key, this.target});

  @override
  State<AddSavingTargetPage> createState() => _AddSavingTargetPageState();
}

class _AddSavingTargetPageState extends State<AddSavingTargetPage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  SavingTargetUnit selectedUnit = SavingTargetUnit.money;
  List<String> selectedWallets = [];

  @override
  void initState() {
    super.initState();

    if (widget.target != null) {
      final target = widget.target!;

      titleController.text = target.title;
      amountController.text = target.unit == SavingTargetUnit.gold
          ? target.targetAmount.toStringAsFixed(2)
          : target.targetAmount.toStringAsFixed(0);

      selectedDate = target.targetDate;
      selectedUnit = target.unit;
      selectedWallets = List.from(target.walletIds);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = FinancialService.getWallets().where((wallet) {
      if (selectedUnit == SavingTargetUnit.gold) {
        return wallet.type == WalletType.gold;
      }
      return wallet.type != WalletType.gold;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.target == null ? "Tambah Target" : "Edit Target"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Form yang bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Nama Target",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<SavingTargetUnit>(
                      initialValue: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: "Jenis Target",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: SavingTargetUnit.money,
                          child: Text("Uang"),
                        ),
                        DropdownMenuItem(
                          value: SavingTargetUnit.gold,
                          child: Text("Emas"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value!;
                          selectedWallets.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: selectedUnit == SavingTargetUnit.gold
                            ? "Target Gram"
                            : "Target Nominal",
                        suffixText: selectedUnit == SavingTargetUnit.gold
                            ? "gr"
                            : "Rp",
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text("Tanggal Target"),
                      subtitle: Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: pickDate,
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Wallet",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...wallets.map((wallet) {
                      final checked = selectedWallets.contains(wallet.id);

                      return CheckboxListTile(
                        value: checked,
                        title: Text(wallet.name),
                        secondary: Icon(
                          wallet.type.icon,
                          color: wallet.type.color,
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedWallets.add(wallet.id);
                            } else {
                              selectedWallets.remove(wallet.id);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    if (selectedWallets.isEmpty) return;

                    final amount = double.tryParse(amountController.text) ?? 0;

                    final target = SavingTargetModel(
                      id:
                          widget.target?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      targetAmount: amount,
                      walletIds: selectedWallets,
                      unit: selectedUnit,
                      targetDate: selectedDate,
                    );

                    if (widget.target == null) {
                      FinancialService.addSavingTarget(target);
                    } else {
                      FinancialService.updateSavingTarget(target);
                    }

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
