import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:arta/core/constants/category_constants.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../services/financial_service.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionPage({super.key, this.transaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  TransactionType selectedType = TransactionType.expense;

  WalletModel? selectedWallet;
  WalletModel? transferWallet;

  String selectedCategory = "Lainnya";
  DateTime selectedDate = DateTime.now();

  List<CategoryModel> customCategories = [];

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  void _loadCustomCategories() {
    final type = selectedType == TransactionType.income ? "income" : "expense";

    customCategories = FinancialService.getCustomCategories(type);
  }

  @override
  void initState() {
    super.initState();

    final availableWallets = FinancialService.getWallets();

    if (availableWallets.isNotEmpty) {
      selectedWallet = availableWallets.first;
      transferWallet = availableWallets.last;
    }

    if (widget.transaction != null) {
      final trx = widget.transaction!;

      selectedType = trx.type;
      amountController.text = trx.amount.toInt().toString();
      noteController.text = trx.note ?? "";
      selectedCategory = trx.category;
      selectedDate = trx.date;

      if (availableWallets.isNotEmpty) {
        if (trx.type == TransactionType.income) {
          selectedWallet = availableWallets.firstWhere(
            (e) => e.id == trx.destinationWalletId,
            orElse: () => availableWallets.first,
          );
        } else if (trx.type == TransactionType.expense) {
          selectedWallet = availableWallets.firstWhere(
            (e) => e.id == trx.sourceWalletId,
            orElse: () => availableWallets.first,
          );
        } else if (trx.type == TransactionType.transfer) {
          selectedWallet = availableWallets.firstWhere(
            (e) => e.id == trx.sourceWalletId,
            orElse: () => availableWallets.first,
          );
          transferWallet = availableWallets.firstWhere(
            (e) => e.id == trx.destinationWalletId,
            orElse: () => availableWallets.last,
          );
        }
      }
    }

    _loadCustomCategories();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _addCustomCategory() async {
    final String? categoryName = await showDialog<String>(
      context: context,
      builder: (context) => const _AddCategoryDialog(),
    );

    if (categoryName == null || categoryName.trim().isEmpty || !mounted) return;

    final cleanName = categoryName.trim();
    final type = selectedType == TransactionType.income ? "income" : "expense";

    final defaultCategories = selectedType == TransactionType.income
        ? CategoryConstants.income
        : CategoryConstants.expense;

    final fetchedCategories = FinancialService.getCustomCategories(type);

    final exists = [
      ...defaultCategories,
      ...fetchedCategories.map((e) => e.name),
    ].any((cat) => cat.toLowerCase() == cleanName.toLowerCase());

    if (exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kategori tersebut sudah ada")),
      );
      return;
    }

    await FinancialService.addCustomCategorySilent(
      CategoryModel(id: const Uuid().v4(), name: cleanName, type: type),
    );

    if (!mounted) return;

    setState(() {
      _loadCustomCategories();
      selectedCategory = cleanName;
    });
  }

  void _submitData() {
    final availableWallets = FinancialService.getWallets();

    if (amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nominal belum diisi")));
      return;
    }

    if (selectedType == TransactionType.transfer &&
        selectedWallet?.id == transferWallet?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wallet asal dan tujuan tidak boleh sama"),
        ),
      );
      return;
    }

    final amount = double.tryParse(
      amountController.text.replaceAll(".", "").replaceAll(",", ""),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nominal tidak valid")));
      return;
    }

    final finalSelectedWallet = availableWallets.firstWhere(
      (w) => w.id == selectedWallet?.id,
      orElse: () => availableWallets.first,
    );

    final finalTransferWallet = availableWallets.firstWhere(
      (w) => w.id == transferWallet?.id,
      orElse: () => availableWallets.last,
    );

    final defaultCategories = selectedType == TransactionType.income
        ? CategoryConstants.income
        : CategoryConstants.expense;

    final currentCategories = [
      ...defaultCategories,
      ...customCategories.map((e) => e.name),
    ];

    final finalCategory = currentCategories.contains(selectedCategory)
        ? selectedCategory
        : currentCategories.first;

    final transaction = TransactionModel(
      id:
          widget.transaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: selectedType,
      title: selectedType == TransactionType.transfer
          ? "Transfer"
          : finalCategory,
      amount: amount,
      date: selectedDate,
      sourceWalletId: selectedType == TransactionType.income
          ? null
          : finalSelectedWallet.id,
      destinationWalletId: selectedType == TransactionType.expense
          ? null
          : selectedType == TransactionType.transfer
          ? finalTransferWallet.id
          : finalSelectedWallet.id,
      category: finalCategory,
      note: noteController.text.trim(),
    );

    if (widget.transaction == null) {
      FinancialService.addTransaction(transaction);
    } else {
      FinancialService.updateTransaction(transaction);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.transaction == null
              ? "Transaksi berhasil ditambahkan"
              : "Transaksi berhasil diperbarui",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final availableWallets = FinancialService.getWallets();

    if (availableWallets.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.transaction == null ? "Tambah Transaksi" : "Edit Transaksi",
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Belum ada wallet.\n\nTambahkan wallet terlebih dahulu sebelum membuat transaksi.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final defaultCategories = selectedType == TransactionType.income
        ? CategoryConstants.income
        : CategoryConstants.expense;

    final currentCategories = [
      ...defaultCategories,
      ...customCategories.map((e) => e.name),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? "Tambah Transaksi" : "Edit Transaksi",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Jenis Transaksi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text("Pengeluaran"),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text("Pemasukan"),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.transfer,
                  label: Text("Transfer"),
                  icon: Icon(Icons.swap_horiz),
                ),
              ],
              selected: {selectedType},
              onSelectionChanged: (value) {
                setState(() {
                  selectedType = value.first;
                  _loadCustomCategories();

                  final defaultCategories =
                      selectedType == TransactionType.income
                      ? CategoryConstants.income
                      : CategoryConstants.expense;

                  final allCategories = [
                    ...defaultCategories,
                    ...customCategories.map((e) => e.name),
                  ];

                  if (!allCategories.contains(selectedCategory)) {
                    selectedCategory = allCategories.first;
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nominal",
                prefixText: "Rp ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<WalletModel>(
              initialValue: availableWallets.firstWhere(
                (w) => w.id == selectedWallet?.id,
                orElse: () => availableWallets.first,
              ),
              decoration: InputDecoration(
                labelText: selectedType == TransactionType.transfer
                    ? "Wallet Asal"
                    : "Wallet",
                border: const OutlineInputBorder(),
              ),
              items: availableWallets.map((wallet) {
                return DropdownMenuItem(
                  value: wallet,
                  child: Text(wallet.name),
                );
              }).toList(),
              onChanged: (wallet) {
                setState(() {
                  selectedWallet = wallet;
                });
              },
            ),

            if (selectedType == TransactionType.transfer) ...[
              const SizedBox(height: 20),

              DropdownButtonFormField<WalletModel>(
                initialValue: availableWallets.firstWhere(
                  (w) => w.id == transferWallet?.id,
                  orElse: () => availableWallets.last,
                ),
                decoration: const InputDecoration(
                  labelText: "Wallet Tujuan",
                  border: OutlineInputBorder(),
                ),
                items: availableWallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet,
                    child: Text(wallet.name),
                  );
                }).toList(),
                onChanged: (wallet) {
                  setState(() {
                    transferWallet = wallet;
                  });
                },
              ),
            ],
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: currentCategories.contains(selectedCategory)
                  ? selectedCategory
                  : currentCategories.first,
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
              items: currentCategories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addCustomCategory,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Tambah kategori custom"),
              ),
            ),

            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Tanggal"),
              subtitle: Text(
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2035),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Catatan",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      // Tombol Simpan dipindah ke Bottom Navigation Bar dengan SafeArea
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _submitData,
              child: const Text("Simpan"),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Kategori"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: "Nama kategori",
          hintText: "Contoh: Orang Tua",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        FilledButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (value.isNotEmpty) {
              Navigator.pop(context, value);
            }
          },
          child: const Text("Tambah"),
        ),
      ],
    );
  }
}
