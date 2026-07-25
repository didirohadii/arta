import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';
import '../../data/models/wallet_model.dart';
import '../../services/financial_service.dart';

// 1. IMPORT FILE KONSTANTA KATEGORI BARU
import 'package:arta/core/constants/category_constants.dart';

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

  // Default kategori kita set ke "Lainnya" karena ada di kedua list (income & expense)
  String selectedCategory = "Lainnya";
  DateTime selectedDate = DateTime.now();

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // (CATATAN: List 'categories' statis yang lama sudah DIHAPUS dari sini)

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
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableWallets = FinancialService.getWallets();

    // Guard: Jika user belum punya wallet sama sekali
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

    // 2. AMBIL LIST KATEGORI SECARA DINAMIS BERDASARKAN JENIS TRANSAKSI
    final currentCategories = selectedType == TransactionType.income
        ? CategoryConstants.income
        : CategoryConstants.expense;

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

            // Dropdown Wallet Utama / Wallet Asal
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

              // Dropdown Wallet Tujuan
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

            // 3. DROPDOWN KATEGORI YANG SUDAH DISESUAIKAN
            DropdownButtonFormField<String>(
              // Proteksi crash: Jika selectedCategory lama tidak ada di list kategori yang baru,
              // otomatis ganti valuenya ke item pertama list baru (misal: "Makan" atau "Gaji")
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
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  if (amountController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nominal belum diisi")),
                    );
                    return;
                  }

                  if (selectedType == TransactionType.transfer &&
                      selectedWallet?.id == transferWallet?.id) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Wallet asal dan tujuan tidak boleh sama",
                        ),
                      ),
                    );
                    return;
                  }

                  final amount = double.tryParse(
                    amountController.text
                        .replaceAll(".", "")
                        .replaceAll(",", ""),
                  );

                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nominal tidak valid")),
                    );
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

                  // 4. VALIDASI AKHIR KATEGORI SEBELUM DISIMPAN
                  final finalCategory =
                      currentCategories.contains(selectedCategory)
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
