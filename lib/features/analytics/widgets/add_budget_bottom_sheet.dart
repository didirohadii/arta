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

  String selectedCategory = "Makan";
  final categories = CategoryConstants.expense;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      selectedCategory = widget.budget!.category;
      amountController.text = widget.budget!.amount.toInt().toString();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
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
                  : categories.first,
              decoration: const InputDecoration(labelText: "Kategori"),
              items: categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Nominal Budget"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Nominal wajib diisi";
                }
                return null;
              },
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final now = DateTime.now();

                  if (widget.budget == null) {
                    // MODE: TAMBAH BUDGET
                    if (FinancialService.budgetExists(
                      category: selectedCategory,
                      month: now.month,
                      year: now.year,
                    )) {
                      // Jika error, langsung pop dan kasih info error
                      Navigator.pop(context);
                      rootScaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Budget untuk kategori "$selectedCategory" sudah tersedia bulan ini.',
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(20),
                        ),
                      );
                      return;
                    }

                    final budget = BudgetModel(
                      id: const Uuid().v4(),
                      category: selectedCategory,
                      amount: double.parse(amountController.text),
                      month: now.month,
                      year: now.year,
                    );

                    // LANGSUNG TUTUP SEKARANG JUGA!
                    Navigator.pop(context);

                    // Proses simpan data jalan di background
                    await FinancialService.addBudget(budget);

                    // Tembak snackbar-nya langsung kelihatan di layar utama!
                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text("Budget berhasil ditambahkan"),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                        margin: EdgeInsets.all(20),
                      ),
                    );
                  } else {
                    // MODE: EDIT BUDGET
                    if (FinancialService.budgetExists(
                      category: selectedCategory,
                      month: widget.budget!.month,
                      year: widget.budget!.year,
                      excludeId: widget.budget!.id,
                    )) {
                      Navigator.pop(context);
                      rootScaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Kategori "$selectedCategory" sudah memiliki budget pada bulan ini.',
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
                      amount: double.parse(amountController.text),
                      month: widget.budget!.month,
                      year: widget.budget!.year,
                    );

                    // LANGSUNG TUTUP SEKARANG JUGA!
                    Navigator.pop(context);

                    // Proses update data jalan di background
                    await FinancialService.updateBudget(updatedBudget);

                    // Tembak snackbar-nya langsung kelihatan di layar utama!
                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(
                        content: Text("Budget berhasil diperbarui"),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                        margin: EdgeInsets.all(20),
                      ),
                    );
                  }
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
