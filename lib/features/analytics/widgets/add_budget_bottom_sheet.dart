import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/budget_model.dart';
import '../../../services/financial_service.dart';
import 'package:arta/core/constants/category_constants.dart';
import 'package:arta/main.dart';

class AddBudgetBottomSheet extends StatefulWidget {
  final BudgetModel? budget;

  const AddBudgetBottomSheet({super.key, this.budget});

  @override
  State<AddBudgetBottomSheet> createState() => _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends State<AddBudgetBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final customCategoryController = TextEditingController();

  String selectedCategory = "Makan";
  final categories = CategoryConstants.expense;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      final budget = widget.budget!;

      selectedCategory = budget.category;
      amountController.text = budget.amount.toInt().toString();

      startDate = budget.startDate;
      endDate = budget.endDate;
    } else {
      // Default periode: tanggal 25 bulan ini → tanggal 24 bulan berikutnya
      final now = DateTime.now();

      if (now.day >= 25) {
        startDate = DateTime(now.year, now.month, 25);
        endDate = DateTime(now.year, now.month + 1, 24);
      } else {
        startDate = DateTime(now.year, now.month - 1, 25);
        endDate = DateTime(now.year, now.month, 24);
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    customCategoryController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );

    if (picked == null) return;

    setState(() {
      startDate = picked;

      // Otomatis membuat periode 1 bulan
      endDate = DateTime(picked.year, picked.month + 1, picked.day - 1);
    });
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime(2050),
    );

    if (picked == null) return;

    setState(() {
      endDate = picked;
    });
  }

  Future<void> addCustomCategory() async {
    customCategoryController.clear();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kategori Custom"),
          content: TextField(
            controller: customCategoryController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Nama kategori",
              hintText: "Contoh: Orang Tua",
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            FilledButton(
              onPressed: () {
                final value = customCategoryController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        selectedCategory = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 70,
      ),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            Text(
              widget.budget == null ? "Tambah Budget" : "Edit Budget",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),

            DropdownButtonFormField<String>(
              initialValue: categories.contains(selectedCategory)
                  ? selectedCategory
                  : "__custom__",
              decoration: const InputDecoration(labelText: "Kategori"),
              items: [
                ...categories.map(
                  (e) => DropdownMenuItem(value: e, child: Text(e)),
                ),
                const DropdownMenuItem(
                  value: "__custom__",
                  child: Text("+ Kategori Custom"),
                ),
              ],
              onChanged: (value) async {
                if (value == "__custom__") {
                  await addCustomCategory();
                  return;
                }

                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),

            if (!categories.contains(selectedCategory))
              Text(
                "Kategori: $selectedCategory",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),

            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nominal Budget"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Nominal wajib diisi";
                }

                final amount = double.tryParse(value);

                if (amount == null || amount <= 0) {
                  return "Nominal tidak valid";
                }

                return null;
              },
            ),

            // PERIODE MULAI
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: const Text("Mulai Periode"),
              subtitle: Text(formatDate(startDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: pickStartDate,
            ),

            // PERIODE BERAKHIR
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text("Akhir Periode"),
              subtitle: Text(formatDate(endDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: pickEndDate,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Budget berlaku dari ${formatDate(startDate)} "
                "sampai ${formatDate(endDate)}.",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  if (!endDate.isAfter(startDate)) {
                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Tanggal akhir harus setelah tanggal mulai.",
                        ),
                      ),
                    );
                    return;
                  }

                  final amount = double.parse(amountController.text);

                  // MODE TAMBAH
                  if (widget.budget == null) {
                    final exists = FinancialService.budgetExists(
                      category: selectedCategory,
                      startDate: startDate,
                      endDate: endDate,
                    );

                    if (exists) {
                      Navigator.pop(context);

                      rootScaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Budget "$selectedCategory" pada periode '
                            '${formatDate(startDate)} - ${formatDate(endDate)} '
                            'sudah tersedia.',
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(20),
                        ),
                      );

                      return;
                    }

                    final budget = BudgetModel(
                      id: const Uuid()
                          .v4(), // Hapus 'const' jika ada warning linter
                      category: selectedCategory,
                      amount: amount,
                      startDate: startDate,
                      endDate: endDate,
                    );

                    await FinancialService.addBudget(budget);

                    if (!context.mounted) return;

                    Navigator.pop(context, 'success_add');
                    return;
                  }

                  // MODE EDIT
                  final exists = FinancialService.budgetExists(
                    category: selectedCategory,
                    startDate: startDate,
                    endDate: endDate,
                    excludeId: widget.budget!.id,
                  );

                  if (exists) {
                    Navigator.pop(context);

                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Budget "$selectedCategory" pada periode '
                          '${formatDate(startDate)} - ${formatDate(endDate)} '
                          'sudah tersedia.',
                        ),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(20),
                      ),
                    );

                    return;
                  }

                  final updatedBudget = BudgetModel(
                    id: widget.budget!.id,
                    category: selectedCategory,
                    amount: amount,
                    startDate: startDate,
                    endDate: endDate,
                  );

                  await FinancialService.updateBudget(updatedBudget);

                  if (!context.mounted) return;

                  Navigator.pop(context, 'success_update');
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
